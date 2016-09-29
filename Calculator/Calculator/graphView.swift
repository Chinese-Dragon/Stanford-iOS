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
    var graphColor: UIColor = UIColor.brown {didSet{setNeedsDisplay()}}
    @IBInspectable
    var lineWidth: CGFloat = 5.0 {didSet{setNeedsDisplay()}}
    @IBInspectable
    var lineColor: UIColor = UIColor.red {didSet{setNeedsDisplay()}}
    
    var graphType = "" // default
    
    var programInfo = [AnyObject]() {
        didSet{
        }
    }
   
    fileprivate var originPoint: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    fileprivate enum FunctionType {
        case linear(([AnyObject],CGPoint) -> UIBezierPath)
        case quadratic(([AnyObject]) -> UIBezierPath)
        case power(([AnyObject]) -> UIBezierPath)
        case sinusoidal(([AnyObject]) -> UIBezierPath)
    }
    
    func changeScale(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed,.ended:
            PtPerUnit *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    
    fileprivate var functions: Dictionary<String,FunctionType> = [
        "Linear": FunctionType.linear(){ (program: [AnyObject], center: CGPoint) -> UIBezierPath in
            let path = UIBezierPath(arcCenter: center, radius: CGFloat(50), startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
            
            return path
        },
        "Quadratic": FunctionType.quadratic(){(program: [AnyObject]) -> UIBezierPath in
            let path = UIBezierPath()
            
            return path
        },
        "Power": FunctionType.power(){(program: [AnyObject]) -> UIBezierPath in
            let path = UIBezierPath()
            
            return path
        },
        "Sinusoidal": FunctionType.sinusoidal(){(program: [AnyObject]) -> UIBezierPath in
            let path = UIBezierPath()
            
            return path
        }
    ]
    
    override func draw(_ rect: CGRect){
        let path = UIBezierPath() // default empty path
        /*
        AxesDrawer(color: graphColor, contentScaleFactor: contentScaleFactor).drawAxesInRect(bounds, origin: originPoint, pointsPerUnit: PtPerUnit)
        if let fuc = functions[graphType] {
            switch fuc {
                case .linear(let linearFuc):
                    path = linearFuc(programInfo, originPoint)
                case .power(let powerFuc): break
                case .quadratic(let quadraticFuc): break
                case .sinusoidal(let sinFuc): break
            }
        }
         */
        
        path.lineWidth = lineWidth
        lineColor.set()
        path.stroke()
    }
    
    


}
