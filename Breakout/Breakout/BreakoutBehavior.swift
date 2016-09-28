//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Mark on 7/17/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior {
    
     var breakout: breakOutView?
    
    convenience init(game: breakOutView) {
        self.init()
        self.breakout = game
        collider.collisionDelegate = breakout
    }
    
    override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
        addChildBehavior(pushBehavior)
    }
    
    //all children dynamic behaviors

    
    private let collider : UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = true
        collider.action = {
            
        }
        return collider
    }()
    
    private let ballBehavior: UIDynamicItemBehavior = {
        let dib = UIDynamicItemBehavior()
        dib.allowsRotation = false
        dib.elasticity = 1.0
        dib.friction = 0.0
        dib.resistance = 0.0
        return dib
    }()
    
    private let pushBehavior = UIPushBehavior(items: [], mode: .instantaneous)
    
    func addBoundary(path: UIBezierPath, named name: String) {
        collider.removeBoundary(withIdentifier: name as NSCopying)
        collider.addBoundary(withIdentifier: name as NSCopying, for: path)
    }
    
    func addItem(item: UIDynamicItem) {
        collider.addItem(item)
        ballBehavior.addItem(item)
        pushBehavior.addItem(item)
    }
    
    func removeItem(item: UIDynamicItem) {
        collider.removeItem(item)
        ballBehavior.removeItem(item)
        pushBehavior.removeItem(item)
    }
    

    
}
