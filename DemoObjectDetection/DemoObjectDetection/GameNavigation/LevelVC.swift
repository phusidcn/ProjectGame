//
//  LevelVC.swift
//  DemoObjectDetection
//
//  Created by Huynh Lam Phu Si on 7/1/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import UIKit
import SCLAlertView

class LevelVC: UIViewController {
    let alert = AlertSettingVolume()
    static var sharedInstance: LevelVC {
        let vc = LevelVC()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .flipHorizontal
        return vc
    }
    let mutablevolumeStream = VolumeStreamImpl.shared
    @IBOutlet var levelButtons: [UIButton]?
    @IBOutlet var starImage: [UIImageView]?
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var returnButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadProgress()
    }
    
    func reloadProgress() {
        if levelButtons == nil || starImage == nil {
            return
        }
        levelButtons?.forEach() { button in
            button.isEnabled = false
        }
        levelButtons?[0].isEnabled = true
        let result = GameStorage.loadGame()
        if result {
            for i in 0 ..< GameStorage.points.count {
                if GameStorage.points[i] > 0 {
                    levelButtons?[i].setBackgroundImage(UIImage(named: "Level\(i + 1)_played"), for: .normal)
                    switch GameStorage.starsNumber[i] {
                    case 1:
                        starImage?[i].image = UIImage(named: "OneStar")
                    case 2:
                        starImage?[i].image = UIImage(named: "TwoStar")
                    case 3:
                        starImage?[i].image = UIImage(named: "ThreeStar")
                    default:
                        break
                    }
                    levelButtons?[i].isEnabled = true
                    if i + 1 < GameStorage.numberOfLevel {
                        levelButtons?[i + 1].isEnabled = true
                    }
                }
            }
        }
    }
    @IBAction func tapToReturnButton(_ sender: UIButton) {
        self.present(MainMenuVC.sharedInstance, animated: true, completion: nil)
    }
    
    
    @IBAction func tapToLevelButton(_ sender: UIButton) {
        let gameVC = GameViewController()
        gameVC.levelNumber = sender.tag - 1
        gameVC.modalPresentationStyle = .fullScreen
        gameVC.modalTransitionStyle = .crossDissolve
        self.present(gameVC, animated: true, completion: nil)
    }
    
    @IBAction func tapSettingBtn(_ sender: Any) {
        alert.showSetting()
    }
    
    
}

class AlertSettingVolume {
    let mutablevolumeStream = VolumeStreamImpl.shared
     func showSetting() {
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: 600, kWindowHeight: 100,
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false
        )
        
        // Initialize SCLAlertView using custom Appearance
        let alert = SCLAlertView(appearance: appearance)
        
        // Creat the subview
        let subview = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 70  ))
        let x = (subview.frame.width - 300) / 2
        
        // Add textfield 1
        let slider = UISlider()
        slider.frame = CGRect(x: x, y: 10, width: 300, height: 20)
        
        subview.addSubview(slider)
        slider.addTarget(self, action: #selector(sliderValueDidChange(sender:)), for: .valueChanged)
        //        subview.addSubview(textfield1)
        
        
        slider.value = mutablevolumeStream.volume.valueVolume
        // Add the subview to the alert's UI property
        alert.customSubview = subview
        alert.addButton("Reset level") { [weak self] in
           GameStorage.resetSaveGame()
            DispatchQueue.main.async {
                LevelVC.sharedInstance.reloadProgress()
            }
            print("Reset level")
        }
        
        // Add Button with Duration Status and custom Colors
        alert.addButton("apply", backgroundColor: UIColor.brown, textColor: UIColor.blue) { [weak self] in
             self?.mutablevolumeStream.updateVolume(value: slider.value)
        }
        
        alert.showInfo("Setting", subTitle: "")
        
        
        // Initialize SCLAlertView using custom Appearance
        
        // create background
        
        // add button
        
        
        // silder
    }
    
    @objc func sliderValueDidChange(sender : UISlider)  {
        mutablevolumeStream.updateVolume(value: sender.value)
    }
}
