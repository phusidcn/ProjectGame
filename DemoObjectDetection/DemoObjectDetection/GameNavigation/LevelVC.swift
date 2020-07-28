//
//  LevelVC.swift
//  DemoObjectDetection
//
//  Created by Huynh Lam Phu Si on 7/1/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import UIKit

class LevelVC: UIViewController {
    static var sharedInstance: LevelVC {
        let vc = LevelVC()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .flipHorizontal
        return vc
    }

    @IBOutlet var levelButtons: [UIButton]!
    @IBOutlet weak var settingButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        levelButtons.forEach() { button in
            button.isEnabled = false
        }
        //GameStorage.resetSaveGame()
        levelButtons[0].isEnabled = true
        let result = GameStorage.loadGame()
        if result {
            for i in 0 ..< GameStorage.points.count {
                if GameStorage.points[i] > 0 {
                    levelButtons[i].setBackgroundImage(UIImage(named: "Level\(i)_played"), for: .normal)
                    levelButtons[i].isEnabled = true
                    if i + 1 < GameStorage.numberOfLevel {
                        levelButtons[i + 1].isEnabled = true
                    }
                }
//                if GameStorage.points[i] > 0 {
//                    for button in self.levelButtons {
//                        if button.tag == i + 1 {
//                            button.setBackgroundImage(UIImage(named: "Level\(i)_played"), for: .normal)
//                            button.isEnabled = true
//                            break
//                        }
//                    }
//                }
            }
        }
        
    }

    @IBAction func tapToLevelButton(_ sender: UIButton) {
        let gameVC = GameViewController()
        gameVC.levelNumber = sender.tag
        gameVC.modalPresentationStyle = .fullScreen
        gameVC.modalTransitionStyle = .crossDissolve
        self.present(gameVC, animated: true, completion: nil)
    }

}
