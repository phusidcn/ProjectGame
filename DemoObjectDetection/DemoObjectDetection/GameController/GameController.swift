    /*
    //  GameComtroller.swift
    //  Created by thi nguyen on 3/2/20.
    //  Copyright © 2020 Busline Ticked. All rights reserved.
    */

import GameController
import GameplayKit
import SceneKit
import ObjectsDetectionKit

    public let velocity: Float = 0.5
    
// Collision bit masks
struct Bitmask: OptionSet {
    let rawValue: Int
    static let character = Bitmask(rawValue: 1 << 0)
    static let collision = Bitmask(rawValue: 1 << 1) // the ground and walls
    static let collectable = Bitmask(rawValue: 1 << 4) // the collectables (gems and key)
}

    typealias ExtraProtocols = SCNSceneRendererDelegate & SCNPhysicsContactDelegate
        


enum ParticleKind: Int {
    case collect = 0
    case collectBig
 
}

enum AudioSourceKind: Int {
    case collect = 0
    case collectBig
    case totalCount
}
class GameController: NSObject, ExtraProtocols {

// Global settings
    static let DefaultCameraTransitionDuration = 1.0
    static let NumberOfFiends = 100
    static let CameraOrientationSensitivity: Float = 0.05

    public var scene: SCNScene?
    private weak var sceneRenderer: SCNSceneRenderer?
    private var objectRecognition: VisionObjectRecognition?

    // Overlays
    private var overlay: Overlay?
    private let controllerQueue: DispatchQueue = DispatchQueue(label: "com.controller.sync")
    // Character
    public var character: Character?


    //triggers
    private var lastTrigger: SCNNode?
    private var firstTriggerDone: Bool = false

   

    

    //collected objects
    private var collectedKeys: Int = 0
    private var collectedGems: Int = 0
    private var keyIsVisible: Bool = false



    // audio
    private var audioSources = [SCNAudioSource](repeatElement(SCNAudioSource(), count: AudioSourceKind.totalCount.rawValue))

    // GameplayKit
    private var gkScene: GKScene?

    // Game controller
    private var gamePadCurrent: GCController?
    private var gamePadLeft: GCControllerDirectionPad?
    private var gamePadRight: GCControllerDirectionPad?

    // update delta time
    private var lastUpdateTime = TimeInterval()

// MARK: -
// MARK: Setup



    func setupCharacter() {
        character = Character(scene: scene!)

        // keep a pointer to the physicsWorld from the character because we will need it when updating the character's position
        character!.physicsWorld = scene!.physicsWorld
        scene!.rootNode.addChildNode(character!.node!)
    }

    func setupPhysics() {
        //make sure all objects only collide with the character
        self.scene?.rootNode.enumerateHierarchy({(_ node: SCNNode, _ _: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.physicsBody?.collisionBitMask = Int(Bitmask.character.rawValue)
        })
    }

    func setupCollisions() {
        // load the collision mesh from another scene and merge into main scene
        let collisionsScene = SCNScene( named: "Art.scnassets/collision.scn" )
        collisionsScene!.rootNode.enumerateChildNodes { (_ child: SCNNode, _ _: UnsafeMutablePointer<ObjCBool>) in
            child.opacity = 0.0
            self.scene?.rootNode.addChildNode(child)
        }
    }


    func loadParticleSystems(atPath path: String) -> [SCNParticleSystem] {
        let url = URL(fileURLWithPath: path)
        let directory = url.deletingLastPathComponent()

        let fileName = url.lastPathComponent
        let ext: String = url.pathExtension

        if ext == "scnp" {
            return [SCNParticleSystem(named: fileName, inDirectory: directory.relativePath)!]
        } else {
            var particles = [SCNParticleSystem]()
            let scene = SCNScene(named: fileName, inDirectory: directory.relativePath, options: nil)
            scene!.rootNode.enumerateHierarchy({(_ node: SCNNode, _ _: UnsafeMutablePointer<ObjCBool>) -> Void in
                if node.particleSystems != nil {
                    particles += node.particleSystems!
                }
            })
            return particles
        }
    }





    // MARK: - Audio

    func playSound(_ audioName: AudioSourceKind) {
        scene!.rootNode.addAudioPlayer(SCNAudioPlayer(source: audioSources[audioName.rawValue]))
    }

    func setupAudio() {
        // Get an arbitrary node to attach the sounds to.
        let node = scene!.rootNode

        // ambience
        if let audioSource = SCNAudioSource(named: "audio/ambience.mp3") {
            audioSource.loops = true
            audioSource.volume = 0.8
            audioSource.isPositional = false
            audioSource.shouldStream = true
            node.addAudioPlayer(SCNAudioPlayer(source: audioSource))
        }
        // volcano
        if let volcanoNode = scene!.rootNode.childNode(withName: "particles_volcanoSmoke_v2", recursively: true) {
            if let audioSource = SCNAudioSource(named: "audio/volcano.mp3") {
                audioSource.loops = true
                audioSource.volume = 5.0
                volcanoNode.addAudioPlayer(SCNAudioPlayer(source: audioSource))
            }
        }

        // other sounds
        audioSources[AudioSourceKind.collect.rawValue] = SCNAudioSource(named: "audio/collect.mp3")!
        audioSources[AudioSourceKind.collectBig.rawValue] = SCNAudioSource(named: "audio/collectBig.mp3")!
       

        // adjust volumes
        audioSources[AudioSourceKind.collect.rawValue].isPositional = false
        audioSources[AudioSourceKind.collectBig.rawValue].isPositional = false

        audioSources[AudioSourceKind.collect.rawValue].volume = 4.0
        audioSources[AudioSourceKind.collectBig.rawValue].volume = 4.0
    }

    // MARK: - Init

    init(scnView: SCNView) {
        super.init()
        
        objectRecognition = VisionObjectRecognition()
        objectRecognition?.delegate = self
        objectRecognition?.setupAVCapture()
        do {
            try objectRecognition?.setupVision()
        } catch let error {
            print(error)
        }
        
        sceneRenderer = scnView
        sceneRenderer!.delegate = self
        
        // Uncomment to show statistics such as fps and timing information
        //scnView.showsStatistics = true
        
        // setup overlay
        overlay = Overlay(size: scnView.bounds.size, controller: self)
        scnView.overlaySKScene = overlay

        //load the main scene
        self.scene = SCNScene(named: "Art.scnassets/scene.scn")

        //setup physics
//        setupPhysics()

        //setup collisions
        setupCollisions()

        //load the character
        setupCharacter()

        let light = scene!.rootNode.childNode(withName: "DirectLight", recursively: true)!.light
        light!.shadowCascadeCount = 3  // turn on cascade shadows
        light!.shadowMapSize = CGSize(width: CGFloat(512), height: CGFloat(512))
        light!.maximumShadowDistance = 20
        light!.shadowCascadeSplittingFactor = 0.5
        

        //assign the scene to the view
        sceneRenderer!.scene = self.scene

        //setup audio
        setupAudio()



        //register ourself as the physics contact delegate to receive contact notifications
        sceneRenderer!.scene!.physicsWorld.contactDelegate = self
        objectRecognition?.startCaptureSession()
    }

    func resetPlayerPosition() {
        character!.queueResetCharacterPosition()
    }

    // MARK: - cinematic

    func startCinematic() {

    }

    func stopCinematic() {
        character!.node!.isPaused = false
    }

    // MARK: - particles


    func collect(_ collectable: SCNNode) {
        if collectable.physicsBody != nil {

            //the Key
            if collectable.name == "key" {
                if !self.keyIsVisible { //key not visible yet
                    return
                }

                // play sound
                playSound(AudioSourceKind.collect)
                self.overlay?.didCollectKey()

                self.collectedKeys += 1
            }

            //the gems
            else if collectable.name == "CollectableBig" {
                self.collectedGems += 1

                // play sound
                playSound(AudioSourceKind.collect)

                // update the overlay
                self.overlay?.collectedGemsCount = self.collectedGems

            
            }

            collectable.physicsBody = nil //not collectable anymore

            // particles

            collectable.removeFromParentNode()
        }
    }

    // MARK: - Controlling the character

    func controllerJump(_ controllerJump: Bool) {
        character!.isJump = controllerJump
    }

    func controllerAttack() {
        if !self.character!.isAttacking {
            self.character!.attack()
        }
    }

    var characterDirection: vector_float2 {
        get {
            return character!.direction
        }
        set {
            var direction = newValue
            print(newValue)
            let l = simd_length(direction)
            if l > 1.0 {
                direction *= 1 / l
            }
            character!.direction = direction
        }
    }

    var cameraDirection = vector_float2.zero {
        didSet {
            let l = simd_length(cameraDirection)
            if l > 1.0 {
                cameraDirection *= 1 / l
            }
            cameraDirection.y = 0
        }
    }
    
    // MARK: - Update

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // compute delta time
        if lastUpdateTime == 0 {
            lastUpdateTime = time
        }
        let deltaTime: TimeInterval = time - lastUpdateTime
        lastUpdateTime = time

        // update characters
        character!.update(atTime: time, with: renderer)

     
    }

    // MARK: - contact delegate

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        // collectables
        if contact.nodeA.physicsBody!.categoryBitMask == Bitmask.collectable.rawValue {
            collect(contact.nodeA)
        }
        if contact.nodeB.physicsBody!.categoryBitMask == Bitmask.collectable.rawValue {
            collect(contact.nodeB)
        }
    }

    // MARK: - Congratulating the Player

    func showEndScreen() {
        // Play the congrat sound.
        guard let victoryMusic = SCNAudioSource(named: "audio/Music_victory.mp3") else { return }
        victoryMusic.volume = 0.5

        self.scene?.rootNode.addAudioPlayer(SCNAudioPlayer(source: victoryMusic))

        self.overlay?.showEndScreen()
    }

 
}

    // MARK: - GameController

    
    






    
 
    
