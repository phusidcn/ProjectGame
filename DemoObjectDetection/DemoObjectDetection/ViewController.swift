/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The app's main view controller.
 */

import SceneKit
import UIKit

protocol SmartDelegate: class {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
}

class ViewController: UIViewController {
    public weak var delegate: SmartDelegate?
    var gameView: GameView {
        return self.view as! GameView
    }
    
    override func loadView() {
        super.loadView()
        self.view = GameView(frame: UIScreen.main.bounds, options: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.touchesBegan(touches, with: event)
    }
    
    var gameController: GameController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.3x on iPads
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.gameView.contentScaleFactor = min(1.3, self.gameView.contentScaleFactor)
            self.gameView.preferredFramesPerSecond = 60
        }
        self.gameView.controller = self
        self.gameView.allowsCameraControl = true
        gameController = GameController(scnView: gameView, viewController: self)
        self.delegate = gameController

        // Configure the view
        gameView.backgroundColor = UIColor.black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.gameView.setUp()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
            
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    override var shouldAutorotate: Bool { return true }
}



