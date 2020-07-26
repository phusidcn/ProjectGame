//
//  LevelView.swift
//  AdventureOfBamboo
//
//  Created by Huynh Lam Phu Si on 7/26/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import UIKit
protocol LevelViewDelegate: AnyObject {
    func tapToLevel(_ sender: UIButton)
}

class LevelView: UIView {
    public weak var delegate: LevelViewDelegate?
    
    @IBOutlet var levelButton: [UIButton]!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBAction func tapToButton(_ sender: UIButton) {
        self.delegate?.tapToLevel(sender)
    }
    
    
}
