//
//  FallingObjectBehavior.swift
//  DropIt
//
//  Created by Mark on 7/15/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

class FallingObjectBehavior: UIDynamicBehavior
{
    //all childern dynamic behaviors
    let gravity = UIGravityBehavior()
    
    fileprivate let collider: UICollisionBehavior =  {
        let collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = true
        return collider
    }()
    
    fileprivate let itemBehavior: UIDynamicItemBehavior = {
       let dib = UIDynamicItemBehavior()
        dib.allowsRotation = false
        dib.elasticity = 0.2
        return dib
    }()
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(itemBehavior)
    }
    
    func addBarrier(_ path: UIBezierPath, named name: String) {
        collider.removeBoundary(withIdentifier: name as NSCopying)
        collider.addBoundary(withIdentifier: name as NSCopying, for: path)
        
    }
    
    func addItem(_ item: UIDynamicItem) {
        gravity.addItem(item)
        collider.addItem(item)
        itemBehavior.addItem(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        gravity.removeItem(item)
        collider.removeItem(item)
        itemBehavior.removeItem(item)
    }
}
