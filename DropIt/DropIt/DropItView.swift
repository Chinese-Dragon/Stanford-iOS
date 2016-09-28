//
//  DropItView.swift
//  DropIt
//
//  Created by Mark on 7/15/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit
import CoreMotion

class DropItView: NamedBezierPathsView, UIDynamicAnimatorDelegate
{
    private lazy var animitor: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        return animator
    }()
 
    //Collection of behaviors
    private let dropBehavior = FallingObjectBehavior()
    
    var animating:Bool = false {
        didSet {
            if animating {
                animitor.addBehavior(dropBehavior)
                updateRealGravity()
            } else {
                animitor.removeBehavior(dropBehavior)
                
            }
        }
    }
    
    //CMmotion
    private let motionManager = CMMotionManager()
    
    var realGravity: Bool = false {
        didSet {
            updateRealGravity()
        }
    }
    
    private func updateRealGravity() {
        if realGravity {
            if motionManager.accelerometerAvailable && !motionManager.accelerometerActive {
                motionManager.accelerometerUpdateInterval = 0.25
                motionManager.startAccelerometerUpdatesToQueue(
                    NSOperationQueue.mainQueue())
                { [unowned self] (data, error) in
                    if self.dropBehavior.dynamicAnimator != nil {
                        if var dx = data?.acceleration.x, var dy = data?.acceleration.y {
                            switch UIDevice.currentDevice().orientation {
                            case .Portrait: dy = -dy
                            case .PortraitUpsideDown: break
                            case .LandscapeRight: swap(&dx,&dy)
                            case .LandscapeLeft: swap(&dx, &dy); dy = -dy
                            default: dx = 0; dy = 0
                            }
                            self.dropBehavior.gravity.gravityDirection = CGVector(dx: dx, dy: dy)
                        }
                    } else {
                        self.motionManager.stopAccelerometerUpdates()
                    }
                }
            }
        } else {
            motionManager.stopAccelerometerUpdates()
        }
    }
    
    private let dropsPerRow = 10
    
    
    private var dropSize: CGSize {
        let size = bounds.size.width / CGFloat(dropsPerRow)
        return CGSize(width: size, height: size)
    }
    
    private struct PathNames {
        static let MiddleBarrier = "Middle Barrier"
        static let Attachment = "Attachment"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(ovalInRect: CGRect(center: bounds.mid, size: dropSize))
        bezierPaths[PathNames.MiddleBarrier] = path
        dropBehavior.addBarrier(path, named: PathNames.MiddleBarrier)
    }
    
    private var attachment: UIAttachmentBehavior? {
        //happens before the newvalue is set
        willSet {
            if attachment != nil {
                animitor.removeBehavior(attachment!)
                bezierPaths[PathNames.Attachment] = nil
            }
        }
        didSet {
            if attachment != nil {
                animitor.addBehavior(attachment!)
                attachment!.action = { [unowned self] in
                    //closure that will be executed immediately everytime attchement behavior acts
                    if let attchedDrop = self.attachment!.items.first as? UIView {
                        self.bezierPaths[PathNames.Attachment] = UIBezierPath.lineFrom(self.attachment!.anchorPoint, to: attchedDrop.center)
                    }
                }
            }
        }
    }
    
    private var lastDrop: UIView?
    
    func addDrop() {
        print(bounds.width)
        var frame = CGRect(origin: CGPointZero, size: dropSize)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        
        let drop = UIView(frame: frame)
        drop.backgroundColor = UIColor.random
        
        addSubview(drop)
        dropBehavior.addItem(drop)
        lastDrop = drop
    }
    
    
    func grabDrop(recognizer: UIPanGestureRecognizer) {
        //Where is the current touch point in screen
        let gesturePoint = recognizer.locationInView(self)
        switch recognizer.state {
        case .Began:
            //create the attchment
            if let dropToAttachTo = lastDrop where dropToAttachTo.superview != nil {
                attachment = UIAttachmentBehavior(item: dropToAttachTo, attachedToAnchor: gesturePoint)
            }
            lastDrop = nil
        case .Changed:
            //change the attchment's anchor point
            attachment?.anchorPoint = gesturePoint
            
        default:
            attachment = nil
        }
    }
    private func removeCompleteRow()
    {
        var dropsToRemove = [UIView]()
        
        var hitTestRect = CGRect(origin: bounds.lowerLeft, size: dropSize)
        
        repeat {
            hitTestRect.origin.x = bounds.minX
            hitTestRect.origin.y -= dropSize.height
            var dropsTested = 0
            var dropsFound = [UIView]()
            while dropsTested < dropsPerRow {
                //check if there is a view
                if let hitView = hitTest(hitTestRect.mid) where hitView.superview == self {
                    dropsFound.append(hitView)
                } else {
                    break
                }
                hitTestRect.origin.x += dropSize.width
                dropsTested += 1
            }
            if dropsTested == dropsPerRow {
                dropsToRemove += dropsFound
            }
        } while dropsToRemove.count == 0 && hitTestRect.origin.y > bounds.minY
        
        for drop in dropsToRemove {
            dropBehavior.removeItem(drop)
            drop.removeFromSuperview()
        }
    }
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        removeCompleteRow()
    }

}
