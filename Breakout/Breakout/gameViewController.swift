//
//  gameViewController.swift
//  Breakout
//
//  Created by Mark on 7/17/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

class gameViewController: UIViewController,UpdateScoreDelegate {
    
    //Model
    var gameSetting = GameUserSetting()
    
    //Breakout View
    @IBOutlet weak var BreakoutView: breakOutView! {
        didSet {
            print("gameview is set")
            BreakoutView.delegate = self
            BreakoutView.addGestureRecognizer(UITapGestureRecognizer(target: BreakoutView, action: #selector(BreakoutView.pushBall(_:))))
            updateGameUI()
            
        }
    }
    
    @IBOutlet weak var Score: UILabel!
    
    //interpret model info to reflect changes in views, a maping
    private var speed = [GameUserSetting.BallSpeed.Slow:CGFloat(0.04),
                         .Medium:CGFloat(0.07),.Fast:CGFloat(0.1)]
    private var size = [GameUserSetting.PaddleSize.Small:CGFloat(30), .Medium: CGFloat(50), .Large: CGFloat(70)]
    
    private var layout = [GameUserSetting.BricksLayout.Loose: 5, .Dense: 10]
    
    //update UI
    private func updateGameUI() {
        BreakoutView.numOfBalls = gameSetting.numOfBalls
        BreakoutView.paddleWidth = size[gameSetting.paddleSize]!
        BreakoutView.numberOfBricks = gameSetting.numOfBricks
        BreakoutView.bricksPerRow = layout[gameSetting.bricksLayout]!
        BreakoutView.pushForce = speed[gameSetting.ballSpeed]!
    }
  
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("viewdidAppear is called")
        BreakoutView.animating = true
        gameSetting = DataCenterViewController.model
        updateGameUI()
        BreakoutView.updateUISettings()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewdidDisappear is called")
        BreakoutView.animating = false
    }
    
    private var isPreviousPortrait: Bool = true
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIDevice.currentDevice().orientation.isLandscape && isPreviousPortrait {
            isPreviousPortrait = false
            BreakoutView.resizeUI()
        } else if UIDevice.currentDevice().orientation.isPortrait && !isPreviousPortrait {
            isPreviousPortrait = true
            BreakoutView.resizeUI()
        }
    }
    
    func update(currentScore: Int) {
        Score.text = "\(currentScore)"
    }
}
