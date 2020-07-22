//
//  Charecter+Behavior.swift
//  DemoObjectDetection
//
//  Created by thi nguyen on 4/19/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import SceneKit

extension Character {
    
    

    
    // MARK: utils
    

    class func loadAnimation(fromSceneNamed sceneName: String) -> SCNAnimationPlayer {
        let scene = SCNScene( named: sceneName )!
        // find top level animation
        var animationPlayer: SCNAnimationPlayer! = nil
        scene.rootNode.enumerateChildNodes { (child, stop) in
            if !child.animationKeys.isEmpty {
                print("child.animationKeys", child.animationKeys[0])
                
                animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])
                stop.pointee = true
            }
        }
        return animationPlayer
    }
    
    internal func handleSlidingAtContact(_ closestContact: SCNPhysicsContact, position start: float3, velocity: float3)
           -> (computedVelocity: simd_float3, colliderPositionAtContact: simd_float3) {
           let originalDistance: Float = simd_length(velocity)

           let colliderPositionAtContact = start + Float(closestContact.sweepTestFraction) * velocity

           // Compute the sliding plane.
           let slidePlaneNormal = float3(closestContact.contactNormal)
           let slidePlaneOrigin = float3(closestContact.contactPoint)
           let centerOffset = slidePlaneOrigin - colliderPositionAtContact

           // Compute destination relative to the point of contact.
           let destinationPoint = slidePlaneOrigin + velocity

           // We now project the destination point onto the sliding plane.
           let distPlane = simd_dot(slidePlaneOrigin, slidePlaneNormal)

           // Project on plane.
           var t = planeIntersect(planeNormal: slidePlaneNormal, planeDist: distPlane,
                                  rayOrigin: destinationPoint, rayDirection: slidePlaneNormal)

           let normalizedVelocity = velocity * (1.0 / originalDistance)
           let angle = simd_dot(slidePlaneNormal, normalizedVelocity)

           var frictionCoeff: Float = 0.3
           if fabs(angle) < 0.9 {
               t += 10E-3
               frictionCoeff = 1.0
           }
           let newDestinationPoint = (destinationPoint + t * slidePlaneNormal) - centerOffset

           let computedVelocity = frictionCoeff * Float(1.0 - closestContact.sweepTestFraction)
               * originalDistance * simd_normalize(newDestinationPoint - start)

           return (computedVelocity, colliderPositionAtContact)
       }
    
    internal func loadSounds() {
           aahSound = SCNAudioSource( named: "audio/aah_extinction.mp3")!
           aahSound.volume = 1.0
           aahSound.isPositional = false
           aahSound.load()

           catchFireSound = SCNAudioSource(named: "audio/panda_catch_fire.mp3")!
           catchFireSound.volume = 5.0
           catchFireSound.isPositional = false
           catchFireSound.load()

           ouchSound = SCNAudioSource(named: "audio/ouch_firehit.mp3")!
           ouchSound.volume = 2.0
           ouchSound.isPositional = false
           ouchSound.load()

           hitSound = SCNAudioSource(named: "audio/hit.mp3")!
           hitSound.volume = 2.0
           hitSound.isPositional = false
           hitSound.load()

           jumpSound = SCNAudioSource(named: "audio/jump.m4a")!
           jumpSound.volume = 0.2
           jumpSound.isPositional = false
           jumpSound.load()

       

           for i in 0..<Character.stepsCount {
               steps[i] = SCNAudioSource(named: "audio/Step_rock_0\(UInt32(i)).mp3")!
               steps[i].volume = 0.5
               steps[i].isPositional = false
               steps[i].load()
           }
       }
    
    

}
