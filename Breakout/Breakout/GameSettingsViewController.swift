//
//  GameSettingsViewController.swift
//  Breakout
//
//  Created by Mark on 7/28/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

class GameSettingsViewController: UIViewController {
    
    @IBOutlet weak var GameSettingsControllerContainer: UIView!
    
    @IBOutlet weak var UISettingsControllerContainer: UIView!
    
    private struct Storyboard {
        static let Baisc = "Basic Settings"
        static let UI = "UI Settings"
    }
    
    @IBAction func switchSettings(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.4, animations: { [unowned self] in
                self.GameSettingsControllerContainer.alpha = 1
                self.UISettingsControllerContainer.alpha = 0
                })
        } else {
            UIView.animate(withDuration: 0.4, animations: { [unowned self] in
                self.GameSettingsControllerContainer.alpha = 0
                self.UISettingsControllerContainer.alpha = 1
                
                })
        }
    }
    

    
}
