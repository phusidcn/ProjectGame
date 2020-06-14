//
//  ObjectsRecognitionProtocol.swift
//  ObjectsDetectionKit
//
//  Created by Huynh Lam Phu Si on 4/9/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import Foundation
import AVFoundation
import Vision

public enum ActionType {
    case Walk_Up
    case Walk_Down
    case Walk_Left
    case Walk_Right
    case Jump_Up
    case Jump_Down
    case Jump_Left
    case Jump_Right
    case Hand_Up
    case Hand_Left
    case Hand_Down
    case Hand_Right
    case Repeat
    case Stars
    case Pressed
    case UnPress
}

public enum NumberType {
    case one
    case two
    case three
    case four
    case five
    case none
}

public struct UserStep {
    public var action: ActionType
    public var number: NumberType
    public var isDanger: Bool
    public var position: CGRect
    
    public init(action: ActionType, position: CGRect, number: NumberType = .none, isDanger: Bool = false) {
        self.action = action
        self.number = number
        self.isDanger = isDanger
        self.position = position
    }
}

extension UserStep: Equatable {
    public static func ==(lhs: UserStep, rhs: UserStep) -> Bool {
        return lhs.action == rhs.action && lhs.isDanger == rhs.isDanger && lhs.position == rhs.position && lhs.number == rhs.number 
    }
}

public protocol ObjectsRecognitionDelegate {
    func actionSequenceDidChange(actions: [UserStep])
    func actionSquenceDidChange(OfPlayer1 actions1: [UserStep], AndPlayer2 action2:[UserStep])
}

public extension ObjectsRecognitionDelegate {
    func actionSequenceDidChange(actions: [UserStep]) {}
    func actionSquenceDidChange(OfPlayer1 actions1: [UserStep], AndPlayer2 action2:[UserStep]) {}
}
