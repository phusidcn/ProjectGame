//
//  ViewController.swift
//  DemoObjectDetection
//
//  Created by Huynh Lam Phu Si on 4/19/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import UIKit
import ObjectsDetectionKit

class ViewController: UIViewController {
    let blockRecognition: VisionObjectRecognition = VisionObjectRecognition()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        blockRecognition.setupAVCapture()
        do {
            try blockRecognition.setupVision()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blockRecognition.startCaptureSession()
    }
}

