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
    
    enum MoveType {
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
    
    func move(type: MoveType, number: Int) {
        for _ in 0 ..< number {
            self.semaphore.wait(timeout: .now() + .milliseconds(1100))
            switch type {
            case .walk:
                character?.moveByPosition(direction: .forward)
            case .jump:
                character?.jumpByPosition(direction: .forward)
            }
        }
    }
    
    func doAction(_ action: UserStep) {
        let range = repeatNumberOf(action: action)
        switch action.action {
        case .Walk_Up:
            character?.moveByPosition(direction: .forward)
            move(type: .walk, number: range - 1)
        case .Walk_Down:
            character?.moveByPosition(direction: .backward)
            move(type: .walk, number: range - 1)
        case .Walk_Left:
            character?.moveByPosition(direction: .left)
            move(type: .walk, number: range - 1)
        case .Walk_Right:
            character?.moveByPosition(direction: .right)
            move(type: .walk, number: range - 1)
        case .Jump_Up:
            character?.jumpByPosition(direction: .forward)
            move(type: .jump, number: range - 1)
        case .Jump_Down:
            character?.jumpByPosition(direction: .backward)
            move(type: .jump, number: range - 1)
        case .Jump_Left:
            character?.jumpByPosition(direction: .left)
            move(type: .jump, number: range - 1)
        case .Jump_Right:
            character?.jumpByPosition(direction: .right)
            move(type: .jump, number: range - 1)
        default:
            break
        }
    }
    
    func repeatActionSequence(_ actions: [UserStep], time: Int) {
        for i in 0 ..< actions.count {
            doAction(actions[i])
        }
    }
    
    func actionSequenceDidChange(actions: [UserStep]) {
        let needToExecute: Bool = actions.contains(where: {userstep in
            return userstep.action == .Pressed
        })
        if needToExecute {
            for i in 0 ..< actions.count {
                if actions[i].action == .Repeat {
                    repeatActionSequence(Array(actions.suffix(actions.count - i)), time: repeatNumberOf(action: actions[i]))
                    break
                } else if actions[i].action == .Pressed || actions[i].action == .UnPress {
                    break
                } else {
                    doAction(actions[i])
                }
            }
        }
    }
    
    
}
