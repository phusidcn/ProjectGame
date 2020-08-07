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
        character?.isJump = false
        self.characterDirection = float2(x: 0, y: 0)
        print("position new \(character?.characterNode.worldPosition)")
        semaphore.wait(timeout: .now() + .milliseconds(500))
    }

    func stopMoveAndCheckEncounter(currntAction: UserStep, elseSteps: [UserStep]) -> Bool {
        stopMove()
        if currntAction.isDanger == true && self.stateCharacter == .encounter {
            doActionSequence(elseSteps)
            self.stateCharacter = .none
            return true
        }
        return false
    }
    
    func walkAction(userStep: UserStep, elseSteps: [UserStep]) {
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
        if stopMoveAndCheckEncounter(currntAction: userStep, elseSteps: elseSteps) {
            return
        }
        for _ in 0 ..< repeatTime - 1 {
            move(direction: .forward)
            if stopMoveAndCheckEncounter(currntAction: userStep, elseSteps: elseSteps) {
                return
            }
        }
    }
    
    func jumpAction(userStep: UserStep, elseSteps: [UserStep]) {
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
        if stopMoveAndCheckEncounter(currntAction: userStep, elseSteps: elseSteps) {
            return
        }
        
        for _ in 0 ..< repeatTime - 1 {
            character?.isJump = true
            move(direction: .forward)
            if stopMoveAndCheckEncounter(currntAction: userStep, elseSteps: elseSteps) {
                return
            }
        }
    }

    func doActionSequence(_ actions: [UserStep]) {
        for i in 0 ..< actions.count {
            switch actions[i].action {
            case .Walk_Down, .Walk_Left, .Walk_Right, .Walk_Up:
                walkAction(userStep: actions[i], elseSteps: [])
            case .Jump_Down, .Jump_Left, .Jump_Right, .Jump_Up:
                jumpAction(userStep: actions[i], elseSteps: [])
            case .Repeat:
                repeatSequence(actions: Array(actions[i ..< actions.count]), times: repeatNumberOf(action: actions[i]), isDanger: false, elseSteps: [])
                return
            default:
                break
            }
        }
    }
    
    func repeatSequence(actions: [UserStep], times: Int, isDanger: Bool, elseSteps: [UserStep]) {
        for _ in 0 ..< times + 1 {
            for i in 0 ..< actions.count {
                switch actions[i].action {
                case .Walk_Right, .Walk_Left, .Walk_Down, .Walk_Up:
                    walkAction(userStep: actions[i], elseSteps: [])
                case .Jump_Right, .Jump_Left, .Jump_Down, .Jump_Up:
                    jumpAction(userStep: actions[i], elseSteps: [])
                default:
                    break
                }
            }
        }
    }
    
    func acceptToMove(steps: [UserStep]) -> Bool {
        var isAcceptToMove = true
        if steps.count > 1 {
            var move1: UserStep
            var move2: UserStep
            for i in 0 ..< steps.count {
                move1 = steps[i]
                if i + 1 == steps.count {
                    break
                }
                move2 = steps[i + 1]
                if move2.action == .Pressed || move2.action == .UnPress {
                    break
                }
                if abs(move1.position.origin.y - move1.position.height - move2.position.origin.y) > 40 {
                    isAcceptToMove = false
                    break
                }
            }
        }
        return isAcceptToMove
    }
    
    func actionSequenceDidChange(actions: [UserStep], elseActions: [UserStep]) {
        var needToExecute = false
        needToExecute = actions.contains(where: {userstep in
            return userstep.action == .Pressed
        })
        for action in actions {
            print(action.position)
        }
        
        if needToExecute && acceptToMove(steps: actions) && acceptToMove(steps: elseActions) {
            self.streak = false
            self.streakIndicator = 0
            var stepIndex = 0
            while stepIndex < actions.count {
                switch actions[stepIndex].action {
                case .Walk_Right, .Walk_Left, .Walk_Up, .Walk_Down:
                    walkAction(userStep: actions[stepIndex], elseSteps: elseActions)
                case .Jump_Right, .Jump_Left, .Jump_Down, .Jump_Up:
                    jumpAction(userStep: actions[stepIndex], elseSteps: elseActions)
                case .Repeat:
                    repeatSequence(actions: Array(actions[stepIndex ..< actions.count]), times: repeatNumberOf(action: actions[stepIndex]), isDanger: actions[stepIndex].isDanger, elseSteps: elseActions)
                    return
                default:
                    break
                }
                stepIndex += 1
            }
        }
    }
}
