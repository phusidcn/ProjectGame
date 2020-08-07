//
//  GameViewController.swift
//  DemoObjectDetection
//
//  Created by Huynh Lam Phu Si on 7/22/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import UIKit
import SceneKit
import SCLAlertView
protocol SmartDelegate: class {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
}

public let targetPerLevel = [3, 4, 6, 10, 12, 13, 13, 16]
public let twoStar = [3, 5, 10, 20, 25, 30, 40, 50]
public let threeStar = [6, 15, 20, 40, 45, 60, 80, 90]

//public enum TargetPerLevel: Int {
//    case Level1 = 3
//    case Level2 = 4
//    case Level3 = 6
//    case Level4 = 10
//    case Level5 = 12
//    case Level6 = 13
//    case Level7 = 15
//    case Level8 = 16
//}
//
//public enum twoStar: Int {
//    case Level1 = 3
//    case Level2 = 5
//    case Level3 = 10
//    case Level4 = 20
//    case Level5 = 25
//    case Level6 = 30
//    case Level7 = 40
//    case Level8 = 50
//}
//
//public enum threeStar: Int {
//    case Level1 = 6
//    case Level2 = 15
//    case Level3 = 20
//    case Level4 = 40
//    case Level5 = 45
//    case Level6 = 60
//    case Level7 = 80
//    case Level8 = 90
//}

class GameViewController: UIViewController {
    let alert = AlertSettingVolume()

    public weak var delegate: SmartDelegate?
    public var levelNumber: Int = 0
    
    var gameView: GameView {
        return self.view as! GameView
    }
    
    override func loadView() {
        super.loadView()
        self.view = GameView(frame: UIScreen.main.bounds, options: nil)
       
        let button = UIButton()
        button.setImage(UIImage.init(named: "SettingButton"), for: .normal)
        button.frame = CGRect(x: 600, y: 50, width: 100, height: 100)
        button.addTarget(self, action: #selector(showSetting), for: .touchUpInside)
        self.view.addSubview(button)
        
    }
    
    @objc func showSetting() {
        alert.showSetting()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.touchesBegan(touches, with: event)
    }
    
    @objc func sliderTouch(sender: UISlider) {
        print("value: \(sender.value)")
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
        gameController = GameController(scnView: gameView, viewController: self, targetNumber: targetPerLevel[levelNumber], level: "\(levelNumber)")
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
