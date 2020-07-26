//
//  MainMenuVC.swift
//  DemoObjectDetection
//
//  Created by Huynh Lam Phu Si on 7/1/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    static var sharedInstance: GameViewController {
        let vc = GameViewController()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    var levelView: LevelView? {
        let view = LevelView(frame: UIScreen.main.bounds)
        view.isHidden = true
        return view
    }
    
    var gameView: GameView {
        let view = GameView(frame: UIScreen.main.bounds, options: nil)
        view.isHidden = true
        return view
    }
    
    var mainMenuView: MainMenuView {
        view.isHidden = false
        return view
    }
    
    var gameController: GameController?
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.gameView.contentScaleFactor = min(1.3, self.gameView.contentScaleFactor)
            self.gameView.preferredFramesPerSecond = 60
        }
        
        mainMenuView.delegate = self
        levelView?.delegate = self
        
        gameView.controller = self
        gameView.allowsCameraControl = true
        self.gameController = GameController(scnView: gameView, viewController: self)
        gameView.backgroundColor = UIColor.black
        
        let rect = UIScreen.main.bounds
        levelView?.frame = CGRect(x: rect.width, y: 0, width: rect.width, height: rect.height)
        gameView.frame = CGRect(x: 2 * rect.width, y: 0, width: rect.width, height: rect.height)
        mainMenuView.frame = rect
        mainMenuView.isHidden = false
        self.view.addSubview(self.mainMenuView)
        self.view.addSubview(self.levelView!)
        //self.view.addSubview(self.gameView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

extension GameViewController: MainMenuDelegate {
    func tapToPlay(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            let rect = UIScreen.main.bounds
            self.mainMenuView.frame = CGRect(x: -rect.width, y: 0, width: rect.width, height: rect.height)
            self.mainMenuView.isHidden = true
            self.levelView?.frame = rect
            self.levelView?.isHidden = false
            self.gameView.frame = CGRect(x: rect.width, y: 0, width: rect.width, height: rect.height)
            self.gameView.isHidden = true
        }, completion: nil)
    }
    
    func tapToSetting(_ sender: UIButton) {
        
    }
}

extension GameViewController: LevelViewDelegate {
    func tapToLevel(_ sender: UIButton) {
        
    }

}
