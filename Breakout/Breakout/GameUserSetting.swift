//
//  GameUserSetting.swift
//  Breakout
//
//  Created by Mark on 7/29/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import Foundation

class GameUserSetting
{
    enum BallSpeed {
        case Slow
        case Medium
        case Fast
    }
    
    enum PaddleSize {
        case Small
        case Medium
        case Large
    }
    
    enum BricksLayout {
        case Loose
        case Dense
    }
    
    var ballSpeed: BallSpeed = .Slow
    var paddleSize: PaddleSize = .Small
    var bricksLayout: BricksLayout = .Loose
    var numOfBalls: Int = 1
    var numOfBricks: Int = 20
    var gyroscope: Bool = false
    var randomColor: Bool = true
}