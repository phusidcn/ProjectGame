//
//  MainMenuView.swift
//  AdventureOfBamboo
//
//  Created by Huynh Lam Phu Si on 7/26/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import UIKit

protocol MainMenuDelegate: AnyObject {
    func tapToPlay(_ sender: UIButton)
    func tapToSetting(_ sender: UIButton)
}

class MainMenuView: UIView {
    
    public weak var delegate: MainMenuDelegate?

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet var settingButton: [UIButton]!
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func tapToPlay(_ sender: UIButton) {
        self.delegate?.tapToPlay(sender)
    }
    @IBAction func tapToSetting(_ sender: UIButton) {
        self.delegate?.tapToSetting(sender)
    }
}
