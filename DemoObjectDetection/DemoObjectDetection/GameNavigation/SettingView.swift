//
//  SettingView.swift
//  DemoObjectDetection
//
//  Created by Huynh Lam Phu Si on 7/21/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import Foundation
import UIKit

class SettingView: UIViewController {
    static var sharedInstance: SettingView {
        return SettingView()
    }
    @IBOutlet var muteSoundButton: UIButton?
    @IBOutlet var mainMenuButton: UIButton?
    
    @IBAction func tapToMuteSoundButton(_ sender: UIButton) {
        
    }
    
    @IBAction func tapToMainMenuButton(_ sender: UIButton) {
        MainMenuView.sharedInstance.modalPresentationStyle = .fullScreen
        self.present(MainMenuView.sharedInstance, animated: true, completion: nil)
    }
}
