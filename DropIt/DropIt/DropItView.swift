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
    fileprivate lazy var animitor: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        return animator
    }()
 
    //Collection of behaviors
    fileprivate let dropBehavior = FallingObjectBehavior()
    
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
    fileprivate let motionManager = CMMotionManager()
    
    var realGravity: Bool = false {
        didSet {
            updateRealGravity()
        }
    }
    
    fileprivate func updateRealGravity() {
        if realGravity {
            if motionManager.isAccelerometerAvailable && !motionManager.isAccelerometerActive {
                motionManager.accelerometerUpdateInterval = 0.25
                motionManager.startAccelerometerUpdates(
                    to: OperationQueue.main)
                { [unowned self] (data, error) in
                    if self.dropBehavior.dynamicAnimator != nil {
                        if var dx = data?.acceleration.x, var dy = data?.acceleration.y {
                            switch UIDevice.current.orientation {
                            case .portrait: dy = -dy
                            case .portraitUpsideDown: break
                            case .landscapeRight: swap(&dx,&dy)
                            case .landscapeLeft: swap(&dx, &dy); dy = -dy
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
    
    fileprivate let dropsPerRow = 10
    
    
    fileprivate var dropSize: CGSize {
        let size = bounds.size.width / CGFloat(dropsPerRow)
        return CGSize(width: size, height: size)
    }
    
    fileprivate struct PathNames {
        static let MiddleBarrier = "Middle Barrier"
        static let Attachment = "Attachment"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(ovalIn: CGRect(center: bounds.mid, size: dropSize))
        bezierPaths[PathNames.MiddleBarrier] = path
        dropBehavior.addBarrier(path, named: PathNames.MiddleBarrier)
    }
    
    fileprivate var attachment: UIAttachmentBehavior? {
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
    
    fileprivate var lastDrop: UIView?
    
    func addDrop() {
        print(bounds.width)
        var frame = CGRect(origin: CGPoint.zero, size: dropSize)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        
        let drop = UIView(frame: frame)
        drop.backgroundColor = UIColor.random
        
        addSubview(drop)
        dropBehavior.addItem(drop)
        lastDrop = drop
    }
    
    
    func grabDrop(_ recognizer: UIPanGestureRecognizer) {
        //Where is the current touch point in screen
        let gesturePoint = recognizer.location(in: self)
        switch recognizer.state {
        case .began:
            //create the attchment
            if let dropToAttachTo = lastDrop , dropToAttachTo.superview != nil {
                attachment = UIAttachmentBehavior(item: dropToAttachTo, attachedToAnchor: gesturePoint)
            }
            lastDrop = nil
        case .changed:
            //change the attchment's anchor point
            attachment?.anchorPoint = gesturePoint
            
        default:
            attachment = nil
        }
    }
    fileprivate func removeCompleteRow()
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
                if let hitView = hitTest(hitTestRect.mid) , hitView.superview == self {
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
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        removeCompleteRow()
    }

}
