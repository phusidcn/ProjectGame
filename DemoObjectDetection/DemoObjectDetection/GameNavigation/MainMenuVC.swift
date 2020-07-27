//
//  MainMenuVC.swift
//  DemoObjectDetection
//
//  Created by Huynh Lam Phu Si on 7/1/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import UIKit

class MainMenuVC: UIViewController {
    
    static var sharedInstance: MainMenuVC {
        let vc = MainMenuVC()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func tapToPlayButton(_ sender: UIButton!) {
        //LevelVC.sharedInstance.modalPresentationStyle = .fullScreen
        self.present(LevelVC.sharedInstance, animated: true, completion: nil)
    }
    
    @IBAction func tapToSetting(_ sender: UIButton!) {

    }

}
