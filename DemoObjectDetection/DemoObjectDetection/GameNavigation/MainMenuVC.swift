//
//  MainMenuVC.swift
//  DemoObjectDetection
//
//  Created by Huynh Lam Phu Si on 7/1/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import Foundation
import FileProvider
import FileProviderUI
import SCLAlertView

class MainMenuVC: UIViewController {
    let alert = AlertSettingVolume()

    static var sharedInstance: MainMenuVC {
        let vc = MainMenuVC()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .partialCurl
        return vc
    }

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    var mutablevolumeStream = VolumeStreamImpl.shared
    override func viewDidLoad() {
         var coveringWindow: UIWindow?
        super.viewDidLoad()

    }
    
    @IBAction func tapToPlayButton(_ sender: UIButton!) {
        self.present(LevelVC.sharedInstance, animated: true, completion: nil)
    }
    
    @IBAction func tapToSetting(_ sender: UIButton!) {
        alert.showSetting()
    }
    
 

}
