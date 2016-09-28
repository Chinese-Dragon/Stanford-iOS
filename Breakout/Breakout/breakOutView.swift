//
//  breakOutView.swift
//  Breakout
//
//  Created by Mark on 7/17/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

protocol UpdateScoreDelegate: NSObjectProtocol {
    func update(currentScore:Int)
}

class breakOutView: UIView, UICollisionBehaviorDelegate
{
    var bricksPerRow: Int = 5
    var numberOfBricks: Int = 20
    var paddleWidth: CGFloat = 50.0
    var numOfBalls: Int = 1
    var pushForce: CGFloat = 0.04
    var ballWidth: CGFloat = 12
    
    weak var delegate: UpdateScoreDelegate?
    
    private var score: Int = 0
    
    //boundaries names
    private struct boundaryNames {
        static let bricks = "brick"
        static let paddle = "paddle"
    }
    
    //Subview Tags
    private struct SubviewTags {
        static let brickTag = 10
        static let paddleTag = 11
        static let ballTag = 12
    }
    
    //my animator
    private lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self)
        return animator
    }()
    
    //check if do animating
    var animating: Bool = false {
        didSet {
            if animating {
                animator.addBehavior(breakouBehavior)
            } else {
                animator.removeBehavior(breakouBehavior)
            }
        }
    }
    
    //Collection of behaviors
    private lazy var breakouBehavior: BreakoutBehavior = {
        let behavior = BreakoutBehavior(game: self)
        return behavior
    }()
    
    //
    private var isLandscape = false
    
    //Settings of bricks
    private var brickSize: CGSize {
        get {
            var width: CGFloat
            if !isLandscape {
                width = (bounds.size.width * 0.8) / CGFloat(bricksPerRow)
            } else {
                width = (bounds.size.width * 0.8) / CGFloat(bricksPerRow * 2)
            }
            return CGSize(width: width, height: width / 2 )
        }
    }
    
    private var paddleMid: CGPoint {
        get {
            return CGPoint(x: self.bounds.midX, y: self.bounds.maxY * 0.9)
        }
    }
    private var paddleSize: CGSize {
        get {
            return CGSize(width: paddleWidth, height: paddleWidth / 5)
        }
    }
    
    private var ballSize: CGSize {
        get {
            return CGSize(width: ballWidth, height: ballWidth)
        }
    }
    
    private var bricksSpacing: CGFloat {
        get {
            var spacing: CGFloat
            if !isLandscape {
                spacing = (bounds.size.width * 0.2) / CGFloat(bricksPerRow + 1)
            } else {
                spacing = (bounds.size.width * 0.2) / CGFloat((bricksPerRow * 2) + 1)
            }
            return spacing
        }
    }
    
    private func addBricks() {
        for i in 0...(numberOfBricks - 1) {
            var frame = CGRect(origin: CGPoint(x: bounds.minX, y: bounds.minY), size: brickSize)
            if i < bricksPerRow {
                frame.origin.x = (CGFloat(i) * (brickSize.width + bricksSpacing)) + bricksSpacing
            } else {
                frame.origin.x = (CGFloat(i % bricksPerRow) * (brickSize.width + bricksSpacing)) + bricksSpacing
                frame.origin.y = (ceil(CGFloat(i / bricksPerRow)) * (brickSize.height + bricksSpacing))
            }
            let brick = UIView(frame: frame)
            brick.backgroundColor = UIColor.random
            brick.tag = SubviewTags.brickTag
            
            addSubview(brick)
            breakouBehavior.addBoundary(path: UIBezierPath(rect: brick.frame), named: "boundaryNames.bricks\(i)")
        }
    }
    
    private func addPaddle() {
        let frame = CGRect(center: paddleMid, size: paddleSize)
        let paddle = UIView(frame: frame)
        paddle.backgroundColor = UIColor.purple
        paddle.tag = SubviewTags.paddleTag
        paddle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.movePaddle)))
        
        addSubview(paddle)
        breakouBehavior.addBoundary(path: UIBezierPath(rect: paddle.frame), named: boundaryNames.paddle)
    }
    
    private func addBalls() {
        let frame = CGRect(center: CGPoint(x:paddleMid.x,y:paddleMid.y - paddleSize.height), size: ballSize)
        let ball = UIView(frame: frame)
        ball.backgroundColor = UIColor.black
        ball.tag = SubviewTags.ballTag
        
        addSubview(ball)
        breakouBehavior.addItem(item: ball)
    }
    
    func movePaddle(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        if let view = recognizer.view {
            let translationX = translation.x
            view.center.x += translationX
            breakouBehavior.addBoundary(path: UIBezierPath(rect: view.frame), named: boundaryNames.paddle)
        }
        //to keep the translation not cumulating
        recognizer.setTranslation(CGPoint.zero, in: self)
    }
    
    func pushBall(recognizer: UITapGestureRecognizer) {
        for behavior in breakouBehavior.childBehaviors {
            if let push = behavior as? UIPushBehavior {
                push.active = true
                push.setAngle(CGFloat(-M_PI/3), magnitude: pushForce)
                push.action = { [unowned push] in
                    push.active = false
                }
                
            }
        }
    }
    
    func updateUISettings() {
        for view in self.subviews {
            view.removeFromSuperview()
            if view.tag == SubviewTags.ballTag {
                breakouBehavior.removeItem(item: view)
            }
        }
        addBricks()
        addPaddle()
        addBalls()
        print("start new game")
    }
    
    func resizeUI() {
        var currentBricks = [UIView]()
        
        for subview in subviews {
            if subview.tag == SubviewTags.brickTag {
                currentBricks.append(subview)
            } else if subview.tag == SubviewTags.paddleTag {
                subview.frame = CGRect(center: paddleMid, size: paddleSize)
                breakouBehavior.addBoundary(path: UIBezierPath(rect: subview.frame), named: boundaryNames.paddle)
            } else if subview.tag == SubviewTags.ballTag {
                subview.removeFromSuperview()
                breakouBehavior.removeItem(item: subview)
                addBalls()
            }
        }
        
        var _bricksPerRow: Int
        if UIDevice.current.orientation.isLandscape {
            _bricksPerRow = bricksPerRow * 2
            isLandscape = true
            postionBricks(bricksPerRow: _bricksPerRow, bricks: currentBricks)
        } else {
            _bricksPerRow = bricksPerRow
            isLandscape = false
            postionBricks(bricksPerRow: _bricksPerRow, bricks: currentBricks)
        }
    }
    
    private func postionBricks(bricksPerRow: Int, bricks: [UIView]) {
        if bricks.count > 0 {
            for i in 0...(bricks.count-1) {
                bricks[i].frame = CGRect(origin: CGPoint(x: bounds.minX, y: bounds.minY), size: brickSize)
                if i < bricksPerRow {
                    bricks[i].frame.origin.x = (CGFloat(i) * (brickSize.width + bricksSpacing)) + bricksSpacing
                } else {
                    bricks[i].frame.origin.x = (CGFloat(i % bricksPerRow) * (brickSize.width + bricksSpacing)) + bricksSpacing
                    bricks[i].frame.origin.y = (ceil(CGFloat(i / bricksPerRow)) * (brickSize.height + bricksSpacing))
                }
                breakouBehavior.addBoundary(path: UIBezierPath(rect: bricks[i].frame), named: "boundaryNames.bricks\(i)")
            }
        }
    }
  
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        if let contacted = item as? UIView , contacted.tag == SubviewTags.ballTag && "\(identifier)".contains(boundaryNames.bricks) {
            if let path = behavior.boundary(withIdentifier: identifier!),let hitView = hitTest(p: path.bounds.mid) , hitView.superview == self && hitView.tag == SubviewTags.brickTag {
                if hitView.alpha == 1.0{
                    UIView.animate(
                        withDuration: 0.2,
                        delay: 0.2,
                        options: [UIViewAnimationOptions.curveLinear],
                        animations: {hitView.alpha = 0.0},
                        completion: {
                            if $0 {
                                self.score += 1
                                if let gameController = self.delegate as? gameViewController {
                                    gameController.update(currentScore: self.score)
                                }
                                // or just
                                // self.delegate?.update(self.score)
                                hitView.removeFromSuperview();
                                behavior.removeBoundary(withIdentifier: identifier!)
                                if self.viewWithTag(SubviewTags.brickTag) == nil{
                                    print("there are no bricks left")
                                }
                            }
                        }
                    )
                }
                
            }
            
        } else if let contacted = item as? UIView , contacted.tag == SubviewTags.ballTag && identifier == nil{
            if ceil(p.y) > paddleMid.y {
                contacted.removeFromSuperview()
                breakouBehavior.removeItem(item: contacted)
                print("you lost")
            }
        }
    }
    
}
