//
//  BlinkingFaceViewController.swift
//  FaceIt
//
//  Created by Mark on 7/14/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

class BlinkingFaceViewController: FaceViewController
{
    var blinking: Bool = false {
        didSet {
            startBlink()
        }
    }
    
    fileprivate struct BlinkRate {
        static let ClosedDuration = 0.4
        static let OpenedDuration = 2.0
    }
    
    func startBlink() {
        if blinking {
            faceView.eyesOpen = false
            //wait a momeny and open my eye
            Timer.scheduledTimer(
                timeInterval: BlinkRate.ClosedDuration,
                target: self,
                selector: #selector(BlinkingFaceViewController.endBlink),
                userInfo: nil,
                repeats: false)
        }
    }
    
    func endBlink() {
        faceView.eyesOpen = true
        Timer.scheduledTimer(
            timeInterval: BlinkRate.OpenedDuration,
            target: self,
            selector: #selector(BlinkingFaceViewController.startBlink),
            userInfo: nil,
            repeats: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        blinking = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        blinking = false
    }
}
