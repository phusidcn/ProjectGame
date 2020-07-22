//
//  Charecter.swift
//  DemoObjectDetection
//
//  Created by thi nguyen on 4/19/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import Foundation
import SceneKit
import simd

func planeIntersect(planeNormal: float3, planeDist: Float, rayOrigin: float3, rayDirection: float3) -> Float {
    return (planeDist - simd_dot(planeNormal, rayOrigin)) / simd_dot(planeNormal, rayDirection)
}

enum DirectionRotate {
    case forward
    case backward
    case left
    case right
}



class Character: NSObject {
    
    static private let speedFactor: CGFloat = 2.0
    static internal let stepsCount = 10

    static private let initialPosition = float3(0.0, 0.0, 0.0)
    
    // some constants
    static private let gravity = Float(0.004)
    static private let jumpImpulse = Float(0.1)
    static private let minAltitude = Float(-10)
    static private let enableFootStepSound = true
    static private let collisionMargin = Float(0.04)
    static private let modelOffset = float3(0, -collisionMargin, 0)
    static private let collisionMeshBitMask = 8
    
    // collision
    private var collisionDirection : SCNNode?
    private var forwardCollision : SCNNode?
    private var backwardCollision : SCNNode?
    private var leftCollision : SCNNode?
    private var rightCollision : SCNNode?
    
    enum GroundType: Int {
        case grass
        case rock
        case water
        case inTheAir
        case count
    }
    
    // Character handle
    public var characterNode: SCNNode!
    internal var characterOrientation: SCNNode!
    public var model: SCNNode!
    
    // Physics
    private var characterCollisionShape: SCNPhysicsShape?
    private var collisionShapeOffsetFromModel = float3.zero
    private var downwardAcceleration: Float = 0
    
    // Jump
    private var controllerJump: Bool = false
    private var jumpState: Int = 0
    private var groundNode: SCNNode?
    private var groundNodeLastPosition = float3.zero
    var baseAltitude: Float = 0
    private var targetAltitude: Float = 0
    
    // void playing the step sound too often
    private var lastStepFrame: Int = 0
    private var frameCounter: Int = 0
    
    // Direction
    private var previousUpdateTime: TimeInterval = 0
    private var controllerDirection = float2.zero
    
    // states
    private var attackCount: Int = 0
    private var lastHitTime: TimeInterval = 0
    
    private var shouldResetCharacterPosition = false
    
    // Particle systems
    private var jumpDustParticle: SCNParticleSystem!
 


    private var fireEmitterBirthRate: CGFloat = 0.0
    private var smokeEmitterBirthRate: CGFloat = 0.0
    private var whiteSmokeEmitterBirthRate: CGFloat = 0.0

    // Sound effects
    internal var aahSound: SCNAudioSource!
    internal var ouchSound: SCNAudioSource!
    internal var hitSound: SCNAudioSource!
   
    internal var catchFireSound: SCNAudioSource!
    internal var jumpSound: SCNAudioSource!
    internal var steps = [SCNAudioSource](repeating: SCNAudioSource(), count: Character.stepsCount )
    
    internal(set) var offsetedMark: SCNNode?
    
    private var fontNode : SCNNode?
    
    // actions
    var isJump: Bool = false
    var direction = float2()
    var physicsWorld: SCNPhysicsWorld?
    
    // MARK: - Initialization
    init(scene: SCNScene) {
        super.init()

        loadCharacter()
        setupCollisions()
//        loadParticles()
        loadSounds()
        loadAnimations()
    }
    
    public func moveByPosition(direction: DirectionRotate) {
       
        let turnAction =  createActionRotate(direction: direction)
        var nodeDirection : SCNNode {
            switch direction {
            case .backward:
                return backwardCollision!
            case . forward:
                 return forwardCollision!
            case .left:
                 return leftCollision!
            case .right:
                 return rightCollision!
            }
        }
        
  
        let moveAction = SCNAction.move(to: nodeDirection.worldPosition, duration: 0.5)
        let actionGroup = SCNAction.group([turnAction, moveAction])
        isWalking = true
        characterNode.runAction(actionGroup, completionHandler: {[weak self] in
            if let wSelf = self {
                wSelf.isWalking = false
            }
        })
    }
    
    public func jumpByPosition(direction : DirectionRotate) {
           model.animationPlayer(forKey: "jump")?.play()
           let duration = 0.4
           let bounceUpAction =  SCNAction.moveBy(x: 0, y: 3.0, z: 0, duration: duration * 0.5)
            let bounceDownAction = SCNAction.moveBy(x: 0, y: -1.0, z: 0, duration: duration * 0.5)
            bounceUpAction.timingMode = .easeOut
            bounceDownAction.timingMode = .easeIn
           
           let turnAction =  createActionRotate(direction: direction)
           var nodeDirection : SCNNode {
               switch direction {
               case .backward:
                   return backwardCollision!
               case . forward:
                    return forwardCollision!
               case .left:
                    return leftCollision!
               case .right:
                    return rightCollision!
               }
           }
           
            jumpState = 0
           let moveForwardAction = SCNAction.move(to: nodeDirection.worldPosition, duration: duration)
            let bounceAction = SCNAction.sequence([bounceUpAction, bounceDownAction])
           let actionJumpFontGroup = SCNAction.group([turnAction, bounceAction, moveForwardAction])
           characterNode.runAction(actionJumpFontGroup, completionHandler: { [weak self] in
            self?.jumpState = 1
               self?.model.animationPlayer(forKey: "jump")?.stop()
           })
          }
    
 
    
    func createActionRotate(direction: DirectionRotate) -> SCNAction {
        let duration = 0.2
        switch direction {
        case .forward:
            return  SCNAction.rotateBy(x: 0, y: convertToRadians(angle: 0), z: 0, duration: duration)
        case .backward:
            return  SCNAction.rotateBy(x: 0, y: convertToRadians(angle: 180), z: 0, duration: duration)
        
        case .left:
            return SCNAction.rotateBy(x: 0, y: convertToRadians(angle: 90), z: 0, duration: duration)
        case .right:
            return SCNAction.rotateBy(x: 0, y: convertToRadians(angle: -90), z: 0, duration: duration)
        }
    }
    
    
    
    
   
    
     func setupCollisions() {
            // load the collision mesh from another scene and merge into main scene
            let collisionsScene = SCNScene.init(named:"Art.scnassets/character/Collision.scn")

            collisionDirection =  collisionsScene?.rootNode.childNode(withName: "Collision", recursively: true)
    //        collisionDirection?.position = character!.characterNode.position
            
            forwardCollision = collisionDirection?.childNode(withName: "fontNode", recursively: true)
            backwardCollision = collisionDirection?.childNode(withName: "backNode", recursively: true)
            leftCollision = collisionDirection?.childNode(withName: "leftNode", recursively: true)
            rightCollision = collisionDirection?.childNode(withName: "rightNode", recursively: true)
            collisionDirection?.position = characterNode.position


            self.characterNode?.addChildNode(collisionDirection!)
        }

    private func loadCharacter() {
       
        let scene = SCNScene( named: "Art.scnassets/character/pig.scn")!
        model = scene.rootNode.childNode( withName: "Pig_rootNode", recursively: true)
        model.simdPosition = Character.modelOffset

        fontNode = model.childNode(withName: "font", recursively: true)
        
        
        characterNode = SCNNode()
        characterNode.name = "character"
        characterNode.simdPosition = Character.initialPosition
        print("characterNode", characterNode.simdPosition)


        characterOrientation = SCNNode()
        characterNode.addChildNode(characterOrientation)
        characterOrientation.addChildNode(model)

        let collider = model.childNode(withName: "collider", recursively: true)!
        collider.physicsBody?.collisionBitMask = Int(([.collectable ] as Bitmask).rawValue)

        // Setup collision shape
        let (min, max) = model.boundingBox
        let collisionCapsuleRadius = CGFloat(max.x - min.x) * CGFloat(0.4)
        let collisionCapsuleHeight = CGFloat(max.y - min.y)

        let collisionGeometry = SCNCapsule(capRadius: collisionCapsuleRadius, height: collisionCapsuleHeight)
        characterCollisionShape = SCNPhysicsShape(geometry: collisionGeometry, options:[.collisionMargin: Character.collisionMargin])
        collisionShapeOffsetFromModel = float3(0, Float(collisionCapsuleHeight) * 0.51, 0.0)
    }

//    private func loadParticles() {
//        var particleScene = SCNScene( named: "Art.scnassets/character/jump_dust.scn")!
//        let particleNode = particleScene.rootNode.childNode(withName: "particle", recursively: true)!
//        jumpDustParticle = particleNode.particleSystems!.first!
//
//        particleScene = SCNScene( named: "Art.scnassets/particles/burn.scn")!
//        let burnParticleNode = particleScene.rootNode.childNode(withName: "particles", recursively: true)!
//
//        let particleEmitter = SCNNode()
//        characterOrientation.addChildNode(particleEmitter)
//
//
//        particleEmitter.position = SCNVector3Make(0, 0.05, 0)
//       }

   

    private func loadAnimations() {
        let idleAnimation = Character.loadAnimation(fromSceneNamed: "Art.scnassets/character/pig_idle.scn")
        model.addAnimationPlayer(idleAnimation, forKey: "idle")
        idleAnimation.play()

        let walkAnimation = Character.loadAnimation(fromSceneNamed: "Art.scnassets/character/pig_walk.scn")
        walkAnimation.speed = Character.speedFactor
        walkAnimation.stop()

        if Character.enableFootStepSound {
            walkAnimation.animation.animationEvents = [
                SCNAnimationEvent(keyTime: 0.1, block: { _, _, _ in self.playFootStep() }),
                SCNAnimationEvent(keyTime: 0.6, block: { _, _, _ in self.playFootStep() })
            ]
        }
        model.addAnimationPlayer(walkAnimation, forKey: "walk")

        let jumpAnimation = Character.loadAnimation(fromSceneNamed: "Art.scnassets/character/pig_jump.scn")
        jumpAnimation.animation.isRemovedOnCompletion = false
        jumpAnimation.stop()
        jumpAnimation.animation.animationEvents = [SCNAnimationEvent(keyTime: 0, block: { _, _, _ in self.playJumpSound() })]
        model.addAnimationPlayer(jumpAnimation, forKey: "jump")

        
    }

    var node: SCNNode! {
        return characterNode
    }
        
    func queueResetCharacterPosition() {
        shouldResetCharacterPosition = true
    }
    
    // MARK: Audio
    
    func playFootStep() {
        if groundNode != nil && isWalking {
            // Play a random step sound.
            let randSnd: Int = Int(Float(arc4random()) / Float(RAND_MAX) * Float(Character.stepsCount))
            let stepSoundIndex: Int = min(Character.stepsCount - 1, randSnd)
            characterNode.runAction(SCNAction.playAudio( steps[stepSoundIndex], waitForCompletion: false))
        }
    }
    
    func playJumpSound() {
        characterNode!.runAction(SCNAction.playAudio(jumpSound, waitForCompletion: false))
    }
    
   
    
    var isDying: Bool = false {
        didSet {
            if isDying == oldValue {
                return
            }
            //walk faster when burning
            let oldSpeed = walkSpeed
            walkSpeed = oldSpeed
            
            if isDying {
                model.runAction(SCNAction.sequence([
                    SCNAction.playAudio(catchFireSound, waitForCompletion: false),
                    SCNAction.playAudio(ouchSound, waitForCompletion: false),
                    SCNAction.repeatForever(SCNAction.sequence([
                        SCNAction.fadeOpacity(to: 0.01, duration: 0.1),
                        SCNAction.fadeOpacity(to: 1.0, duration: 0.1)
                        ]))
                    ]))
                
            } else {
                model.removeAllAudioPlayers()
                model.removeAllActions()
                model.opacity = 1.0
                model.runAction(SCNAction.playAudio(aahSound, waitForCompletion: false))
                
            }
        }
    }
    
    
    private var directionAngle: CGFloat = 0.0 {
        didSet {
            characterOrientation.runAction(
                SCNAction.rotateTo(x: 0.0, y: directionAngle, z: 0.0, duration: 0.1, usesShortestUnitArc:true))
        }
    }
    
    func update(atTime time: TimeInterval, with renderer: SCNSceneRenderer) {
        frameCounter += 1
        
        if shouldResetCharacterPosition {
            shouldResetCharacterPosition = false
            resetCharacterPosition()
            return
        }
        
        var characterVelocity = float3.zero
        
        // setup
        var groundMove = float3.zero
        
        // did the ground moved?
        if groundNode != nil {
            let groundPosition = groundNode!.simdWorldPosition
            groundMove = groundPosition - groundNodeLastPosition
        }
        
        characterVelocity = float3(groundMove.x, 0, groundMove.z)
        
        let direction = characterDirection(withPointOfView:renderer.pointOfView)
        
        if previousUpdateTime == 0.0 {
            previousUpdateTime = time
        }
        
        
        let deltaTime = time - previousUpdateTime
        let characterSpeed = CGFloat(deltaTime) * Character.speedFactor * walkSpeed
        let virtualFrameCount = Int(deltaTime / (1 / 60.0))
        previousUpdateTime = time
        
        // move
        if !direction.allZero() {
            characterVelocity = direction * Float(characterSpeed)
            var runModifier = Float(1.0)
           
            walkSpeed = CGFloat(runModifier * simd_length(direction))
            
            // move character
            directionAngle = CGFloat(atan2f(direction.x, direction.z))
            
            isWalking = true
        } else {
//            isWalking = false
        }
        
        // put the character on the ground
        let up = float3(0, 1, 0)
        var wPosition = characterNode.simdWorldPosition
//        collisionDirection?.simdWorldPosition = wPosition
        print("collisionDirection", collisionDirection?.childNode(withName: "backNode", recursively: true)?.simdWorldPosition)
        // gravity
        downwardAcceleration -= Character.gravity
        wPosition.y += downwardAcceleration
        let HIT_RANGE = Float(0.2)
        var p0 = wPosition
        var p1 = wPosition
        
        p0.y = wPosition.y + up.y * HIT_RANGE
        p1.y = wPosition.y - up.y * HIT_RANGE
        
        let options: [String: Any] = [
            SCNHitTestOption.backFaceCulling.rawValue: false,
            SCNHitTestOption.categoryBitMask.rawValue: Character.collisionMeshBitMask,
            SCNHitTestOption.ignoreHiddenNodes.rawValue: false]
        
        let hitFrom = SCNVector3(p0)
        let hitTo = SCNVector3(p1)
        let hitResult = renderer.scene!.rootNode.hitTestWithSegment(from: hitFrom, to: hitTo, options: options).first
        
        let wasTouchingTheGroup = groundNode != nil
        groundNode = nil
        var touchesTheGround = false
        let wasBurning = isDying
        
        if let hit = hitResult {
            let ground = float3(hit.worldCoordinates)
            if wPosition.y <= ground.y + Character.collisionMargin {
                wPosition.y = ground.y + Character.collisionMargin
                if downwardAcceleration < 0 {
                   downwardAcceleration = 0
                }
                groundNode = hit.node
                touchesTheGround = true
                
                //touching lava?x
                isDying = groundNode?.name == "COLL_lava"
            }
        } else {
            if wPosition.y < Character.minAltitude {
                wPosition.y = Character.minAltitude
                //reset
                queueResetCharacterPosition()
            }
        }
        
        groundNodeLastPosition = (groundNode != nil) ? groundNode!.simdWorldPosition: float3.zero
        
        //jump -------------------------------------------------------------
        if jumpState == 0 {
            if isJump && touchesTheGround {
                downwardAcceleration += Character.jumpImpulse
                jumpState = 1
                
                model.animationPlayer(forKey: "jump")?.play()
            }
        } else {
            if jumpState == 1 && !isJump {
                jumpState = 2
            }
            
            if downwardAcceleration > 0 {
                for _ in 0..<virtualFrameCount {
                    downwardAcceleration *= jumpState == 1 ? 0.99: 0.2
                }
            }
            
            if touchesTheGround {
                if !wasTouchingTheGroup {
                    model.animationPlayer(forKey: "jump")?.stop(withBlendOutDuration: 0.1)
                    
                    // trigger jump particles if not touching lava
                    if isDying {
                        model.childNode(withName: "dustEmitter", recursively: true)?.addParticleSystem(jumpDustParticle)
                    } else {
                        // jump in lava again
                        if wasBurning {
                            characterNode.runAction(SCNAction.sequence([
                                SCNAction.playAudio(catchFireSound, waitForCompletion: false),
                                SCNAction.playAudio(ouchSound, waitForCompletion: false)
                                ]))
                        }
                    }
                }
                
                if !isJump {
                    jumpState = 0
                }
            }
        }
        
        if touchesTheGround && !wasTouchingTheGroup && !isDying && lastStepFrame < frameCounter - 10 {
            // sound
            lastStepFrame = frameCounter
            characterNode.runAction(SCNAction.playAudio(steps[0], waitForCompletion: false))
        }
        
        if wPosition.y < characterNode.simdPosition.y {
            wPosition.y = characterNode.simdPosition.y
        }
        //------------------------------------------------------------------
        
        // progressively update the elevation node when we touch the ground
        if touchesTheGround {
            targetAltitude = wPosition.y
        }
        baseAltitude *= 0.95
        baseAltitude += targetAltitude * 0.05
//        collisionDirection?.simdWorldPosition.y = -1.7

        characterVelocity.y += downwardAcceleration
        if simd_length_squared(characterVelocity) > 10E-4 * 10E-4 {
            let startPosition = characterNode!.presentation.simdWorldPosition + collisionShapeOffsetFromModel
            slideInWorld(fromPosition: startPosition, velocity: characterVelocity)
        }
    }
    
    // MARK: - Animating the character
    
    var isAttacking: Bool {
        return attackCount > 0
    }
    
    func attack() {
        attackCount += 1
        model.animationPlayer(forKey: "spin")?.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.attackCount -= 1
        }
//        spinParticleAttach.addParticleSystem(spinCircleParticle)
    }
    
    var isWalking: Bool = false {
        didSet {
            if oldValue != isWalking {
                // Update node animation.
                if isWalking {
                    model.animationPlayer(forKey: "walk")?.play()
                } else {
                    model.animationPlayer(forKey: "walk")?.stop(withBlendOutDuration: 0.2)
                }
            }
        }
    }
    
    var walkSpeed: CGFloat = 1.0 {
        didSet {
            let burningFactor: CGFloat = isDying ? 2: 1
            model.animationPlayer(forKey: "walk")?.speed = Character.speedFactor * walkSpeed * burningFactor
        }
    }
    
    func characterDirection(withPointOfView pointOfView: SCNNode?) -> float3 {
        let controllerDir = self.direction
        if controllerDir.allZero() {
            return float3.zero
        }
        
        var directionWorld = float3.zero
        if let pov = pointOfView {
            let p1 = pov.presentation.simdConvertPosition(float3(controllerDir.x, 0.0, controllerDir.y), to: nil)
            let p0 = pov.presentation.simdConvertPosition(float3.zero, to: nil)
            directionWorld = p1 - p0
            directionWorld.y = 0
            if simd_any(directionWorld != float3.zero) {
                let minControllerSpeedFactor = Float(0.2)
                let maxControllerSpeedFactor = Float(1.0)
                let speed = simd_length(controllerDir) * (maxControllerSpeedFactor - minControllerSpeedFactor) + minControllerSpeedFactor
                directionWorld = speed * simd_normalize(directionWorld)
            }
        }
        return directionWorld
    }
    
    func resetCharacterPosition() {
        characterNode.simdPosition = Character.initialPosition
        downwardAcceleration = 0
    }
    
    // MARK: enemy if have
    
}
    
    // MARK: - physics contact
extension Character {
    func slideInWorld(fromPosition start: float3, velocity: float3) {
           let maxSlideIteration: Int = 4
           var iteration = 0
           var stop: Bool = false

           var replacementPoint = start

           var start = start
           var velocity = velocity
           let options: [SCNPhysicsWorld.TestOption: Any] = [
               SCNPhysicsWorld.TestOption.collisionBitMask: Bitmask.collision.rawValue,
               SCNPhysicsWorld.TestOption.searchMode: SCNPhysicsWorld.TestSearchMode.closest]
           while !stop {
               var from = matrix_identity_float4x4
               from.position = start

               var to: matrix_float4x4 = matrix_identity_float4x4
               to.position = start + velocity

               let contacts = physicsWorld!.convexSweepTest(
                   with: characterCollisionShape!,
                   from: SCNMatrix4(from),
                   to: SCNMatrix4(to),
                   options: options)
               if !contacts.isEmpty {
                   (velocity, start) = handleSlidingAtContact(contacts.first!, position: start, velocity: velocity)
                   iteration += 1

                   if simd_length_squared(velocity) <= (10E-3 * 10E-3) || iteration >= maxSlideIteration {
                       replacementPoint = start
                       stop = true
                   }
               } else {
                   replacementPoint = start + velocity
                   stop = true
               }
           }
           characterNode!.simdWorldPosition = replacementPoint - collisionShapeOffsetFromModel
       }

}
   


