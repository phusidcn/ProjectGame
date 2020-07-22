//
//  MainMenu.swift
//  DemoObjectDetection
//
//  Created by Huynh Lam Phu Si on 7/21/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import Foundation
import UIKit

class MainMenuView: UIViewController {
    static var sharedInstance: MainMenuView {
        return MainMenuView()
    }
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var background: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet var playButton: UIButton?
    @IBOutlet var settingButton: UIButton?
    
    @IBAction func tapToPlayButton(_ sender: UIButton!) {
        LevelView.sharedInstance.modalPresentationStyle = .fullScreen
        self.present(LevelView.sharedInstance, animated: true, completion: nil)
    }
    
    @IBAction func tapToSetting(_ sender: UIButton!) {
        SettingView.sharedInstance.modalPresentationStyle = .fullScreen
        self.present(SettingView.sharedInstance, animated: true, completion: nil)
    }
}
