//
//  Ultils.swift
//  DemoObjectDetection
//
//  Created by thi nguyen on 7/19/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//


import Foundation
import CoreGraphics
import SceneKit

let DegreesPerRadians = Float(Double.pi/180)
let RadiansPerDegrees = Float(180/Double.pi)

func convertToRadians(angle:Float) -> Float {
    return angle * DegreesPerRadians
}

func convertToRadians(angle:CGFloat) -> CGFloat {
    return CGFloat(CGFloat(angle) * CGFloat(DegreesPerRadians))
}

func convertToDegrees(angle:Float) -> Float {
    return angle * RadiansPerDegrees
}

func convertToDegrees(angle:CGFloat) -> CGFloat {
    return CGFloat(CGFloat(angle) * CGFloat(RadiansPerDegrees))
}

func convertVector2Direction(vector1 : vector_float2 , vector2: vector_float2, handler: (DirectionRotate) -> ()) {
    let x = vector2.x - vector1.x
    let  y = vector2.y - vector1.y
    print("position new")
    if x > 0 && y > -0.01 && y < 0.01 {
       handler(.left)
    } else if x < 0  && y > -0.01 && y < 0.01 {
        handler(.right)
//        return .right
    }
    
    if y > 0 && (x > -0.01 && x < 0.01) {
        handler(.forward)
        
    } else if y < 0 && x > -0.01 && x < 0.01 {
        handler(.backward)
    }
    
//    handler(.backward)
    
}

func convertVector2Direction(node1: SCNNode , node2: SCNNode, handler: (DirectionRotate) -> ()){
    let vector1 = vector_float2(node1.worldPosition.x, node1.worldPosition.z)
    let vector2 = vector_float2(node2.worldPosition.x, node2.worldPosition.z)
    convertVector2Direction(vector1: vector1, vector2: vector2, handler: handler)
}
