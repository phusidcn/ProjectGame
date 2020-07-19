//
//  HandlerBlock.swift
//  DemoObjectDetection
//
//  Created by thi nguyen on 4/10/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import GameplayKit
import SceneKit
import ObjectsDetectionKit

extension GameController: ObjectsRecognitionDelegate {
    
    func convert(action: UserStep) -> float2 {
        switch action.action {
        case .Hand_Down:
            return float2(x: 0, y: 0)
        case .Hand_Up:
            return float2(x: 0, y: 0)
        case .Hand_Left:
            return float2(x: 0, y: 0)
        case .Hand_Right:
            return float2(x: 0, y: 0)
        case .Jump_Down:
            return float2(x: 0, y: velocity)
        case .Jump_Up:
            return float2(x: 0, y: -velocity)
        case .Jump_Left:
            return float2(x: -velocity, y: 0)
        case .Jump_Right:
            return float2(x: velocity, y: 0)
        case .Walk_Up:
            return float2(x: 0, y: -velocity)
        case .Walk_Down:
            return float2(x: 0, y: velocity)
        case .Walk_Left:
            return float2(x: -velocity, y: 0)
        case .Walk_Right:
            return float2(x: velocity, y: 0)
        default:
            return float2(x: 0, y: 0)
        }
    }
    
    func repeatNumberOf(action: UserStep) -> Int {
        switch action.number {
        case .one:
            return 1
        case .two:
            return 2
        case .three:
            return 3
        case .four:
            return 4
        case .five:
            return 5
        default:
            return 1
        }
    }
    
    func walkAction(userStep: UserStep) {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        let navigation = convert(action: userStep)
        self.characterDirection = navigation
        semaphore.wait(timeout: .now() + .milliseconds(500))
        self.characterDirection = float2(x: 0, y: 0)
        semaphore.wait(timeout: .now() + .milliseconds(500))
    }
    
    func jumpAction(userStep: UserStep) {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        let navigation = convert(action: userStep)
        character?.isJump = true
        self.characterDirection = navigation
        semaphore.wait(timeout: .now() + .milliseconds(700))
        character?.isJump = false
        self.characterDirection = float2(x: 0, y: 0)
        semaphore.wait(timeout: .now() + .milliseconds(500))
    }
    
    func actionSequenceDidChange(actions: [UserStep]) {
        let needToExecute: Bool = actions.contains(where: {userstep in
            return userstep.action == .Pressed
        })
        if needToExecute {
            actions.forEach({userStep in
                let repeatTime = repeatNumberOf(action: userStep)
                print("\(userStep.action) \(userStep.number)")
                for _ in 0 ..< repeatTime {
                    switch userStep.action {
                    case .Walk_Up, .Walk_Down, .Walk_Left, .Walk_Right:
                        walkAction(userStep: userStep)
                    case .Jump_Up, .Jump_Down, .Jump_Left, .Jump_Right:
                        jumpAction(userStep: userStep)
                    default:
                        break
                    }
                }
            })
        }
        print("==================================================")
    }
}
