//
//  BasicSettingsTableViewController.swift
//  Breakout
//
//  Created by Mark on 7/28/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

class BasicSettingsTableViewController: UITableViewController {

    
    @IBAction func ballSpeed(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            DataCenterViewController.model.ballSpeed = .Slow
        case 1:
            DataCenterViewController.model.ballSpeed = .Medium
        case 2:
            DataCenterViewController.model.ballSpeed = .Fast
        default:
            break
        }
    }

    @IBAction func changeNumOfBricks(sender: UISlider) {
        numberOfBricks.text = "\(Int(sender.value))"
        DataCenterViewController.model.numOfBricks = Int(sender.value)
    }
  
  
    @IBOutlet weak var numberOfBricks: UILabel!
    
    @IBOutlet weak var numOfBall: UILabel!
    
    @IBAction func changeNumberOfBall(sender: UIStepper) {
        numOfBall.text = "\(Int(sender.value))"
        DataCenterViewController.model.numOfBalls = Int(sender.value)
    }
    
    @IBAction func paddleSize(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            DataCenterViewController.model.paddleSize = .Small
        case 1:
            DataCenterViewController.model.paddleSize = .Medium
        case 2:
            DataCenterViewController.model.paddleSize = .Large
        default:
            break
        }
    }

    @IBAction func paddleLayout(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            DataCenterViewController.model.bricksLayout = .Loose
        case 1:
            DataCenterViewController.model.bricksLayout = .Dense
        default:
            break
        }
    }

    @IBAction func turnOnGyro(sender: UISwitch) {
    }
}
