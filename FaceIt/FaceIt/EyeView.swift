//
//  EyeView.swift
//  FaceIt
//
//  Created by CS193p Instructor.
//  Copyright © 2015 Stanford University. All rights reserved.
//

import UIKit

class EyeView: UIView
{
    var lineWidth: CGFloat = 5.0 { didSet { setNeedsDisplay() } }
    var color: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    var scale: CGFloat = 1.0 {didSet {setNeedsDisplay(); }}
    
    var _eyesOpen: Bool = true { didSet { setNeedsDisplay() } }
    
    var eyesOpen: Bool {
        get {
            return _eyesOpen
        }
        set {
            UIView.transitionWithView(
                self,
                duration: animationState.duration,
                options: [.TransitionFlipFromTop,.CurveLinear],
                animations: {
                    //things that need change
                    self._eyesOpen = newValue
                },
                completion: nil
            )
        }
    }
   
    private struct animationState {
        static let duration = 0.4
    }

    override func drawRect(rect: CGRect)
    {
        var path: UIBezierPath!
        
        if eyesOpen {
            path = UIBezierPath(ovalInRect: bounds.insetBy(dx: scale*lineWidth/2, dy: scale*lineWidth/2))

        } else {
            path = UIBezierPath()
            path.moveToPoint(CGPoint(x: bounds.minX, y: bounds.midY))
            path.addLineToPoint(CGPoint(x: bounds.maxX, y: bounds.midY))
        }
        
        path.lineWidth = lineWidth
        color.setStroke()
        path.stroke()
    }
}
