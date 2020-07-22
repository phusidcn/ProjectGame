    /*
    //  GameComtroller.swift
    //  Created by thi nguyen on 3/2/20.
    //  Copyright © 2020 Busline Ticked. All rights reserved.
    */

import GameController
import GameplayKit
import SceneKit
import ObjectsDetectionKit

    public let velocity: Float = 1
    
// Collision bit masks
struct Bitmask: OptionSet {
    let rawValue: Int
    static let character = Bitmask(rawValue: 1 << 0)
    static let collision = Bitmask(rawValue: 1 << 1) // the ground and walls
    static let collectable = Bitmask(rawValue: 1 << 4) // the collectables (gems and key)
}

    typealias ExtraProtocols = SCNSceneRendererDelegate & SCNPhysicsContactDelegate & PadOverlayDelegate & ButtonOverlayDelegate
        


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
    struct Config {
        let ALTITUDE = 1.00
    }
        func padOverlayVirtualStickInteractionDidStart(_ padNode: ViewPadOverlay) {
            
            if padNode == overlay!.controlOverlay!.leftPad {
                characterDirection = float2(Float(padNode.stickPosition.x), -Float(padNode.stickPosition.y))
            }
            if padNode == overlay!.controlOverlay!.rightPad {
                cameraDirection = float2( -Float(padNode.stickPosition.x), Float(padNode.stickPosition.y))
            }
        }
        
        
    
        func converDirectionToOXY(direction: DirectionRotate) -> vector_float2 {
           switch direction {
                      case .backward:
                          return vector_float2(0, -1)
                      case . forward:
                          return vector_float2(0 , 1)
                      case .left:
                          return vector_float2(1,0)
                      case .right:
                          return vector_float2(0,1)
                      }
        }
       
   
    
//        func move1Step(direction : DirectionRotate) {
//            switch direction {
//            case .backward:
//                <#code#>
//            default:
//                <#code#>
//            }
//        }
        

        func padOverlayVirtualStickInteractionDidChange(_ padNode: ViewPadOverlay) {
            if padNode == overlay!.controlOverlay!.leftPad {
//                characterDirection = float2(Float(padNode.stickPosition.x), -Float(padNode.stickPosition.y))
            }
            if padNode == overlay!.controlOverlay!.rightPad {
//                cameraDirection = float2( -Float(padNode.stickPosition.x), Float(padNode.stickPosition.y))
            }
        }

        func padOverlayVirtualStickInteractionDidEnd(_ padNode: ViewPadOverlay) {
            if padNode == overlay!.controlOverlay!.leftPad {
                characterDirection = [0, 0]
            }
            if padNode == overlay!.controlOverlay!.rightPad {
                cameraDirection = [0, 0]
            }
        }

        func willPress(_ button: ButtonOverlay) {
            if button == overlay!.controlOverlay!.buttonA {
                character?.isJump = true
                characterDirection = converDirectionToOXY(direction: .forward)
//                character?.moveByPosition(simd3: leftCollision!.worldPosition  , direction: .left)
            }
            if button == overlay!.controlOverlay!.buttonB {
                characterDirection = converDirectionToOXY(direction: .backward)

            }
        }

        func didPress(_ button: ButtonOverlay) {
            if button == overlay!.controlOverlay!.buttonA {
                characterDirection = [0, 0]
                controllerJump(false)
            } else {
                characterDirection = [0, 0]

//                print("right!.charector truoc", character?.characterNode!.worldPosition)
//                print("right!.position truoc", collisionDirection!.worldPosition)
//
//                let vector = SCNVector3(1, 0, 0)
//                character?.jumpByPosition(direction: .backward)
//
////                updatePositionAndOrientationOf(collisionDirection!, withPosition: character!.characterNode.worldPosition, relativeTo: character!.characterNode)
////                let turnLeft = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: -90), z: 0, duration: 0.5, usesShortestUnitArc: true)
////                      collisionDirection?.runAction(turnLeft)
//                let moveRightAction = SCNAction.moveBy(x: 1.0, y: 0, z: 0, duration: 0.2)
//                collisionDirection?.position = character!.characterNode.position
////                rightCollision = collisionDirection?.childNode(withName: "rightNode", recursively: true)
//                print("right!.position", collisionDirection!.worldPosition)

            }
        }
        

// Global settings
    let semaphore = DispatchSemaphore(value: 0)
    static let DefaultCameraTransitionDuration = 1.0
    static let NumberOfFiends = 100
    static let CameraOrientationSensitivity: Float = 0.05

    public var scene: SCNScene?
    private weak var sceneRenderer: SCNSceneRenderer?
    private var objectRecognition: VisionObjectRecognition?

    // Overlays
    private var overlay: HUB?
    private let controllerQueue: DispatchQueue = DispatchQueue(label: "com.controller.sync")
    // Character
    public var character: Character?


    //triggers
    private var lastTrigger: SCNNode?
    private var firstTriggerDone: Bool = false

   
    // handle camera
    
    private var _cameraYHandle : SCNNode?
    private var _cameraXHandle : SCNNode?

    

    //collected objects
    private var collectedKeys: Int = 0
    private var collectedGems: Int = 0
    private var keyIsVisible: Bool = false
    
    // collision
    private var collisionDirection : SCNNode?
    private var forwardCollision : SCNNode?
    private var backwardCollision : SCNNode?
    private var leftCollision : SCNNode?
    private var rightCollision : SCNNode?
//
    private var _direction = CGPoint()
    private var _panningTouch = UITouch()
    private var _padTouch = UITouch()
   
    private var _directionCacheValid : Bool = false

    private var vc: UIViewController?

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
    private var _lockCamera : Bool = false

// MARK: -
// MARK: Setup
    
    func updatePositionAndOrientationOf(_ node: SCNNode, withPosition position: SCNVector3, relativeTo referenceNode: SCNNode) {
        let referenceNodeTransform = matrix_float4x4(referenceNode.transform)

        // Setup a translation matrix with the desired position
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.x = position.x
        translationMatrix.columns.3.y = position.y
        translationMatrix.columns.3.z = position.z

        // Combine the configured translation matrix with the referenceNode's transform to get the desired position AND orientation
        let updatedTransform = matrix_multiply(referenceNodeTransform, translationMatrix)
        node.transform = SCNMatrix4(updatedTransform)
    }

    func handleCamera() {
        _cameraXHandle = SCNNode()
        _cameraYHandle = SCNNode()
        _cameraYHandle?.addChildNode(_cameraXHandle!)
        
        scene?.rootNode.addChildNode(_cameraYHandle!)
        
        _cameraXHandle?.position = SCNVector3Make(0, 1.0,0);
        
        let pov = self.sceneRenderer!.pointOfView;
        
        
        pov!.eulerAngles = SCNVector3Make(0, 0, 0);
        pov!.position = SCNVector3Make(0,0,10.0);
        
        _cameraYHandle!.rotation = SCNVector4Make(0, 0, 0, Float(.pi/2 + M_PI_4*3));
        _cameraXHandle!.rotation = SCNVector4Make(0, 0, 0, Float(-M_PI_4*0.125));
        _cameraXHandle!.addChildNode(pov!)
        
        _lockCamera = true
        SCNTransaction.begin()
        SCNTransaction.completionBlock = { [weak self]  in
            self?._lockCamera = false }
        
        let cameraYAnimation = CABasicAnimation.init(keyPath: "rotation.w")
        let i = (M_PI*2) - Double(_cameraYHandle!.rotation.w)
        cameraYAnimation.fromValue =  i;
        cameraYAnimation.toValue = 0.0;
        cameraYAnimation.isAdditive = true;
        cameraYAnimation.beginTime = CACurrentMediaTime()+3; // wait a little bit before stating
        cameraYAnimation.fillMode = .both;
        cameraYAnimation.duration = 5.0;
        cameraYAnimation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        _cameraYHandle?.addAnimation(cameraYAnimation, forKey: nil)
        
        let cameraXAnimation = CABasicAnimation.init(keyPath: "rotation.w")
               let x = (-M_PI*2) - Double(_cameraYHandle!.rotation.w)
               cameraYAnimation.fromValue =  x;
               cameraYAnimation.toValue = 0.0;
               cameraYAnimation.isAdditive = true;
               cameraYAnimation.beginTime = CACurrentMediaTime()+3; // wait a little bit before stating
               cameraYAnimation.fillMode = .both;
               cameraYAnimation.duration = 5.0;
               cameraYAnimation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
               _cameraXHandle?.addAnimation(cameraXAnimation, forKey: nil)
        SCNTransaction.commit()
        
//        let lookAtConstraint
        
     
        
//        _lockCamera = true;
    }
    
    
    
    func panCamera(dir :CGSize) {
        if (_lockCamera == true) {
               return;
           }
        _cameraXHandle = SCNNode()
        _cameraYHandle = SCNNode()
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.0
        
        _cameraYHandle!.removeAllActions()
        _cameraXHandle!.removeAllActions()
        
        if (_cameraYHandle!.rotation.y < 0) {
            _cameraYHandle!.rotation = SCNVector4Make(0, 1, 0, -_cameraYHandle!.rotation.w);
        }
        if (_cameraXHandle!.rotation.x < 0) {
            _cameraXHandle!.rotation = SCNVector4Make(1, 0, 0, -_cameraXHandle!.rotation.w);
        }
        SCNTransaction.commit()
        
        // Update the camera position with some inertia.
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        let F = 0.005
        _cameraYHandle!.rotation = SCNVector4(0, 1, 0, _cameraYHandle!.rotation.y * (_cameraYHandle!.rotation.w -
            Float(dir.width) * 0.005))
        
        _cameraXHandle!.rotation = SCNVector4(1, 0, 0, max(.pi, min(0.13, _cameraXHandle!.rotation.w + Float(dir.height) * 0.005)))
        

        
        SCNTransaction.commit()

    }

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
        let collisionsScene = SCNScene.init(named:"Art.scnassets/character/Collision.scn")

        collisionDirection =  collisionsScene?.rootNode.childNode(withName: "Collision", recursively: true)
        collisionDirection?.position = SCNVector3(x: 0, y: -1.563998, z: 0)
//        collisionDirection?.position = character!.characterNode.position
        
        forwardCollision = collisionDirection?.childNode(withName: "fontNode", recursively: true)
        backwardCollision = collisionDirection?.childNode(withName: "backNode", recursively: true)
        leftCollision = collisionDirection?.childNode(withName: "leftNode", recursively: true)
        rightCollision = collisionDirection?.childNode(withName: "rightNode", recursively: true)
        

        self.scene?.rootNode.addChildNode(collisionDirection!)
    }
    
    func updatePositionCollision () {
//        updatePositionAndOrientationOf(collisionDirection!, withPosition: character!.characterNode.worldPosition, relativeTo: character!.characterNode)
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

    init(scnView: SCNView, viewController: ViewController) {
        super.init()
        viewController.delegate = self
        self.vc = viewController
        
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
        overlay = HUB(size: scnView.bounds.size, controller: self)
        scnView.overlaySKScene = overlay

        //load the main scene
        self.scene = SCNScene(named: "Art.scnassets/scene.scn")
        //setup physics
//        setupPhysics()

        

        //load the character
        
        setupCharacter()
        
        //setup collisions

        
//        setupCollisions()

        let light = scene!.rootNode.childNode(withName: "DirectLight", recursively: true)!.light
        light!.shadowCascadeCount = 3  // turn on cascade shadows
        light!.shadowMapSize = CGSize(width: CGFloat(512), height: CGFloat(512))
        light!.maximumShadowDistance = 20
        light!.shadowCascadeSplittingFactor = 0.5
        

        //assign the scene to the view
        sceneRenderer!.scene = self.scene

        //setup audio
        setupAudio()

        //handleCamera()


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
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        updatePositionCollision()
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
//
    func touchs(touch : UITouch, isInRect: CGRect) -> Bool {

        return true;
        

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

    
    






    
 
    
