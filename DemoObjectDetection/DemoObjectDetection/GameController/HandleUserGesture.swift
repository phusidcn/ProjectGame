//
//  HandleUserGesture.swift
//  DemoObjectDetection
//
//  Created by Huynh Lam Phu Si on 7/21/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class GameView: SCNView {
    
    private var _direction: CGPoint? = nil
    private var panningTouch: UITouch? = nil
    public weak var controller: GameViewController?
    var defaultFov: Double = 1.0
    
    func setUp() {
        defaultFov = self.pointOfView?.camera?.xFov ?? 0
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector((self.pinchWithGestureRecognizer(_:))))
        pinch.delegate = self
        pinch.cancelsTouchesInView = false
        self.addGestureRecognizer(pinch)
    }

    func touch(_ touch: UITouch, inRect rect: CGRect) -> Bool {
        let bounds = self.bounds
        let affineRect = rect.applying(CGAffineTransform(scaleX: bounds.size.width, y:bounds.size.height))
        return affineRect.contains(touch.location(in: self))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        panningTouch = touches.first
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if panningTouch != nil {
            let p0 = panningTouch?.previousLocation(in: self)
            let p1 = panningTouch?.location(in: self)
            if let p0 = p0, let p1 = p1 {
                self.controller?.gameController?.panCamera(dir: CGSize(width: p1.x - p0.x, height: p0.y - p1.y))
            }
        }
        super.touchesMoved(touches, with: event)
    }
    
    func commonTouchEnded(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = panningTouch, touches.contains(touch) {
            panningTouch = nil
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.commonTouchEnded(touches, withEvent: event)
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.commonTouchEnded(touches, withEvent: event)
        super.touchesCancelled(touches, with: event)
    }
    
    @objc func pinchWithGestureRecognizer(_ recognizer: UIPinchGestureRecognizer?) {
        //print(recognizer?.state.rawValue ?? "")
        SCNTransaction.begin()
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        var fov = defaultFov
        var constraintFactor: Double = 0
        if let recognizer = recognizer, recognizer.state == .ended || recognizer.state == .cancelled {
            print("zoom out")
            SCNTransaction.animationDuration = 0.5
        } else {
            SCNTransaction.animationDuration = 0.1
            if let recognizer = recognizer, recognizer.scale > 1.0 {
                print("zoomin")
                let scale: CGFloat = 1 + ((recognizer.scale - 1) * 0.75)
                fov = fov / Double(scale)
                constraintFactor = Double(min(1, (scale - 1) * 0.75))
            }
        }
        self.pointOfView?.camera?.xFov = fov
        self.pointOfView?.constraints?[0].influenceFactor = CGFloat(constraintFactor)
        SCNTransaction.commit()
        
    }
}

extension GameView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) {
            return true
        }
        return true
    }
}

extension GameController: SmartDelegate {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
