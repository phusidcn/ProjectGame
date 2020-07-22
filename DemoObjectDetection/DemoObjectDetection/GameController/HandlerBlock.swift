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
    
    enum moveType {
        case walk
        case jump
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
    
    func stopMove() {
        semaphore.wait(timeout: .now() + .milliseconds(500))
        self.characterDirection = float2(x: 0, y: 0)
        print("position new \(character?.characterNode.worldPosition)")
        semaphore.wait(timeout: .now() + .milliseconds(500))
    }
    
    func walkAction(userStep: UserStep) {
        //let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        let repeatTime = repeatNumberOf(action: userStep)
        switch userStep.action {
        case .Walk_Up:
            move(direction: .forward)
        case .Walk_Down:
            move(direction: .backward)
        case .Walk_Left:
            move(direction: .left)
        case .Walk_Right:
            move(direction: .right)
        default:
            break
        }
        stopMove()
        for _ in 0 ..< repeatTime - 1 {
            move(direction: .forward)
            stopMove()
        }
    }
    
    func jumpAction(userStep: UserStep) {
        let repeatTime = repeatNumberOf(action: userStep)
        
        character?.isJump = true
        switch userStep.action {
        case .Jump_Up:
            move(direction: .forward)
        case .Jump_Down:
            move(direction: .backward)
        case .Jump_Left:
            move(direction: .left)
        case .Jump_Right:
            move(direction: .right)
        default:
            break
        }
        semaphore.wait(timeout: .now() + .milliseconds(500))
        character?.isJump = false
        print("position new \(character?.characterNode.worldPosition)")
        self.characterDirection = float2(x: 0, y: 0)
        semaphore.wait(timeout: .now() + .milliseconds(500))
        
        for _ in 0 ..< repeatTime - 1 {
            character?.isJump = true
            move(direction: .forward)
            semaphore.wait(timeout: .now() + .milliseconds(500))
            character?.isJump = false
            print("position new \(character?.characterNode.worldPosition)")
            self.characterDirection = float2(x: 0, y: 0)
            semaphore.wait(timeout: .now() + .milliseconds(500))
        }
    }
    
    func repeatSequence(actions: [UserStep], times: Int) {
        for _ in 0 ..< times {
            for i in 0 ..< actions.count {
                switch actions[i].action {
                case .Walk_Right, .Walk_Left, .Walk_Down, .Walk_Up:
                    walkAction(userStep: actions[i])
                case .Jump_Right, .Jump_Left, .Jump_Down, .Jump_Up:
                    jumpAction(userStep: actions[i])
                default:
                    break
                }
            }
        }
    }
    
    func actionSequenceDidChange(actions: [UserStep]) {
        let needToExecute: Bool = actions.contains(where: {userstep in
            return userstep.action == .Pressed
        })
        if needToExecute {
            for i in 0 ..< actions.count {
                switch actions[i].action {
                case .Walk_Up, .Walk_Down, .Walk_Left, .Walk_Right:
                    walkAction(userStep: actions[i])
                case .Jump_Up, .Jump_Down, .Jump_Left, .Jump_Right:
                    jumpAction(userStep: actions[i])
                case .Repeat:
                    repeatSequence(actions: Array(actions[(i + 1) ..< actions.count]), times: repeatNumberOf(action: actions[i]))
                    return
                default:
                    break
                }
            }
        }
    }
}
