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
        return vc
    }

    @IBOutlet var levelButtons: [UIButton]!
    @IBOutlet weak var settingButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //GameStorage.resetSaveGame()
        let result = GameStorage.loadGame()
        if result {
            for i in 0 ..< GameStorage.points.count {
                if GameStorage.points[i] > 0 {
                    for button in self.levelButtons {
                        if button.tag == i + 1 {
                            button.setBackgroundImage(UIImage(named: "Level\(i)_played"), for: .normal)
                            break
                        }
                    }
                }
            }
        }
    }

    @IBAction func tapToLevelButton(_ sender: UIButton) {
        //print("tap \(sender.tag) level")
        let gameVC = GameViewController()
        gameVC.levelNumber = sender.tag
        gameVC.modalPresentationStyle = .fullScreen
        self.present(gameVC, animated: true, completion: nil)
    }

}
