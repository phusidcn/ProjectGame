//
//  GameViewController.swift
//  DemoObjectDetection
//
//  Created by Huynh Lam Phu Si on 7/22/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import UIKit
import SceneKit
protocol SmartDelegate: class {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
}

class GameViewController: UIViewController {
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
         //1.3x on iPads
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.gameView.contentScaleFactor = min(1.3, self.gameView.contentScaleFactor)
            self.gameView.preferredFramesPerSecond = 60
        }
        self.gameView.controller = self
        self.gameView.allowsCameraControl = true
        gameController = GameController(scnView: gameView, viewController: self, targetNumber: 3, level: "Art.scnassets/level2.scn")
        self.delegate = gameController

        // Configure the view
        gameView.backgroundColor = UIColor.black
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.gameView.setUp()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
