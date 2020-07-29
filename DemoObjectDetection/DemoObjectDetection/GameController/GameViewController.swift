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

public enum TargetPerLevel: Int {
    case Level1 = 3
    case Level2 = 4
    case Level3 = 5
    case Level4 = 6
    case Level5 = 7
    case Level6 = 8
    case Level7 = 9
    case Level8 = 10
}

class GameViewController: UIViewController {
    
    public weak var delegate: SmartDelegate?
    public var levelNumber: Int = 1 {
        didSet {
            if levelNumber == 1 { numberOfApple = .Level1}
            if levelNumber == 2 { numberOfApple = .Level2}
            if levelNumber == 3 { numberOfApple = .Level3}
            if levelNumber == 4 { numberOfApple = .Level4}
            if levelNumber == 5 { numberOfApple = .Level5}
            if levelNumber == 6 { numberOfApple = .Level6}
            if levelNumber == 7 { numberOfApple = .Level7}
            if levelNumber == 8 { numberOfApple = .Level8}
        }
    }
    private var numberOfApple: TargetPerLevel = .Level1
    
    var gameView: GameView {
        return self.view as! GameView
    }
    
    override func loadView() {
        super.loadView()
        self.view = GameView(frame: UIScreen.main.bounds, options: nil)
        let label = UILabel.init(frame: CGRect(x: 50, y: 50, width: 550, height: 50))
        label.text = "test thu roi"
        self.view.addSubview(label)
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
        gameController = GameController(scnView: gameView, viewController: self, targetNumber: self.numberOfApple.rawValue, level: "\(levelNumber)")
        gameController?.inGameDelegate = self
        self.delegate = gameController

        // Configure the view
        gameView.backgroundColor = UIColor.black
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.gameView.setUp()
    }

}

extension GameViewController: InGameDelegate {
    func backToLevel() {
        self.present(LevelVC.sharedInstance, animated: true, completion: nil)
    }
    
    func backToMenu() {
        self.present(MainMenuVC.sharedInstance, animated: true, completion: nil)
    }
}
