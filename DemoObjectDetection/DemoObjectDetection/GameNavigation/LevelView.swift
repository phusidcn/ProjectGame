//
//  LevelSelection.swift
//  DemoObjectDetection
//
//  Created by Huynh Lam Phu Si on 7/21/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import Foundation
import UIKit

class LevelView: UIViewController {
    static var sharedInstance: LevelView {
        return LevelView()
    }
    @IBOutlet var level1Button: UIButton?
    @IBOutlet var level2Button: UIButton?
    @IBOutlet var level3Button: UIButton?
    @IBOutlet var level4Button: UIButton?
    @IBOutlet var level5Button: UIButton?
    @IBOutlet var level6Button: UIButton?
    @IBOutlet var level7Button: UIButton?
    @IBOutlet var level8Button: UIButton?
    @IBOutlet var backButton: UIButton?
    
    @IBAction func tapToLevel1(_ sender: UIButton?) {
        
    }
    
    @IBAction func tapToLevel2(_ sender: UIButton?) {
        
    }
    
    @IBAction func tapToLevel3(_ sender: UIButton?) {
        
    }
    
    @IBAction func tapToLevel4(_ sender: UIButton?) {
        
    }
    
    @IBAction func tapToLevel5(_ sender: UIButton?) {
        
    }
    
    @IBAction func tapToLevel6(_ sender: UIButton?) {
        
    }
    
    @IBAction func tapToLevel7(_ sender: UIButton?) {
        
    }
    
    @IBAction func tapToLevel8(_ sender: UIButton?) {
        
    }
    
    @IBAction func tapToBackButton(_ sender: UIButton?) {
        MainMenuView.sharedInstance.modalPresentationStyle = .fullScreen
        self.present(MainMenuView.sharedInstance, animated: true, completion: nil)
    }
}
