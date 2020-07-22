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
                    case .Walk_Up:
                        character?.moveByPosition(direction: .forward)
                    case .Walk_Down:
                        character?.moveByPosition(direction: .backward)
                    case .Walk_Left:
                        character?.moveByPosition(direction: .left)
                    case .Walk_Right:
                        character?.moveByPosition(direction: .right)
                    case .Jump_Up:
                        character?.jumpByPosition(direction: .forward)
                    case .Jump_Down:
                        character?.jumpByPosition(direction: .backward)
                    case .Jump_Left:
                        character?.jumpByPosition(direction: .left)
                    case .Jump_Right:
                        character?.jumpByPosition(direction: .right)
                    default:
                        break
                    }
                }
            })
        }
        print("==================================================")
    }
}
