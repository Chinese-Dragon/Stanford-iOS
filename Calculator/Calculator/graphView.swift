//
//  graphView.swift
//  Calculator
//
//  Created by Mark on 6/13/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

@IBDesignable
class graphView: UIView {

    @IBInspectable
    var PtPerUnit: CGFloat = 50 {didSet{setNeedsDisplay()}}
    @IBInspectable
    var graphColor: UIColor = UIColor.brownColor() {didSet{setNeedsDisplay()}}
    @IBInspectable
    var lineWidth: CGFloat = 5.0 {didSet{setNeedsDisplay()}}
    @IBInspectable
    var lineColor: UIColor = UIColor.redColor() {didSet{setNeedsDisplay()}}
    
    var graphType = "" // default
    
    var programInfo = [AnyObject]() {
        didSet{
        }
    }
   
    private var originPoint: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private enum FunctionType {
        case Linear(([AnyObject],CGPoint) -> UIBezierPath)
        case Quadratic(([AnyObject]) -> UIBezierPath)
        case Power(([AnyObject]) -> UIBezierPath)
        case Sinusoidal(([AnyObject]) -> UIBezierPath)
    }
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Changed,.Ended:
            PtPerUnit *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    
    private var functions: Dictionary<String,FunctionType> = [
        "Linear": FunctionType.Linear(){ (program: [AnyObject], center: CGPoint) -> UIBezierPath in
            let path = UIBezierPath(arcCenter: center, radius: CGFloat(50), startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
            
            return path
        },
        "Quadratic": FunctionType.Quadratic(){(program: [AnyObject]) -> UIBezierPath in
            let path = UIBezierPath()
            
            return path
        },
        "Power": FunctionType.Power(){(program: [AnyObject]) -> UIBezierPath in
            let path = UIBezierPath()
            
            return path
        },
        "Sinusoidal": FunctionType.Sinusoidal(){(program: [AnyObject]) -> UIBezierPath in
            let path = UIBezierPath()
            
            return path
        }
    ]
    
    override func drawRect(rect: CGRect){
        var path = UIBezierPath() // default empty path
        
        AxesDrawer(color: graphColor, contentScaleFactor: contentScaleFactor).drawAxesInRect(bounds, origin: originPoint, pointsPerUnit: PtPerUnit)
        if let fuc = functions[graphType] {
            switch fuc {
                case .Linear(let linearFuc):
                    path = linearFuc(programInfo, originPoint)
                case .Power(let powerFuc): break
                case .Quadratic(let quadraticFuc): break
                case .Sinusoidal(let sinFuc): break
            }
        }
        
        path.lineWidth = lineWidth
        lineColor.set()
        path.stroke()
    }
    
    


}
