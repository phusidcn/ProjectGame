//
//  LevelComplete.swift
//  DemoObjectDetection
//
//  Created by Huynh Lam Phu Si on 7/21/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import Foundation
import UIKit

class CompleteView: UIViewController {
    public static var fisrtLevelIndex: Int = 0
    public static var lastLevelIndex: Int = 8
    public var currentLevelIndex: Int = 0
    @IBOutlet var nextLevelButton: UIButton?
    @IBOutlet var replayButton: UIButton?
    @IBOutlet var mainMenuButton: UIButton?
    @IBOutlet var settingButton: UIButton?
    @IBOutlet var levelSelectButton: UIButton?
    
    @IBAction func tapNextLevelButton(_ sender: UIButton) {
        currentLevelIndex += 1
    }
    
    @IBAction func tapReplayButton(_ sender: UIButton) {
        
    }
    
    @IBAction func tapMainMenuButton(_ sender: UIButton) {
        MainMenuView.sharedInstance.modalPresentationStyle = .fullScreen
        self.present(MainMenuView.sharedInstance, animated: true, completion: nil)
    }
    
    @IBAction func tapSettingButton(_ sender: UIButton) {
        SettingView.sharedInstance.modalPresentationStyle = .fullScreen
        self.present(SettingView.sharedInstance, animated: true, completion: nil)
    }
    
    @IBAction func tapLevelSelectButton(_ sender: UIButton) {
        LevelView.sharedInstance.modalPresentationStyle = .fullScreen
        self.present(LevelView.sharedInstance, animated: true, completion: nil)
    }
}
