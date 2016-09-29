//
//  FaceView.swift
//  FaceIt
//
//  Created by Mark on 6/10/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

@IBDesignable
class FaceView: UIView {
    
    //if we are using IBInspectable we need give the type
    @IBInspectable
    var _scale: CGFloat = 1.0 {didSet {leftEye.scale = scale;rightEye.scale = scale;setNeedsDisplay(); }}
    
    var scale: CGFloat {
        get {
            return _scale
        }
        set {
            UIView.transition(
                with: self,
                duration: 0.2,
                options: [.curveLinear,.transitionCrossDissolve],
                animations: {
                    self._scale = newValue
                },
                completion: nil
            )
        }
    }
    
    @IBInspectable
    var _mouthCurvature: Double = -1.0 {didSet {setNeedsDisplay()}} //1 full smile, -1 full frown
    
    var mouthCurvature: Double {
        get {
            return _mouthCurvature
        }
        set {
            UIView.transition(
                with: self,
                duration: 0.2,
                options: [.curveLinear,.transitionCrossDissolve],
                animations: {
                    self._mouthCurvature = newValue
                },
                completion: nil
            )
        }
    }
    @IBInspectable
    //We are not drawing eyes anymore in faceview
    var eyesOpen: Bool = true {didSet {leftEye.eyesOpen = eyesOpen; rightEye.eyesOpen = eyesOpen}}
    @IBInspectable
    var eyeBrowTilt: Double = -0.5 {didSet {setNeedsDisplay()}}// -1 full furrpw, 1 fully relaxed
    @IBInspectable
    var color:UIColor = UIColor.orange {didSet {setNeedsDisplay(); leftEye.color = color; rightEye.color = color }}
    @IBInspectable
    var lineWidth: CGFloat = 3.0 {didSet {setNeedsDisplay(); leftEye.lineWidth = lineWidth; rightEye.lineWidth = lineWidth}}
    
    func changeScale(_ recognizer: UIPinchGestureRecognizer)
    {
        switch recognizer.state {
        case .changed,.ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    } 
    
    fileprivate var skullRadius: CGFloat
    {
         return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    fileprivate var skullCenter: CGPoint
    {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    fileprivate struct Ratios
    {
        static let SkullRadiusToEyeOffset: CGFloat = 3
        static let SkullRadiusToEyeRadius: CGFloat = 10
        static let SkullRadiusToMouthWidth: CGFloat = 1
        static let SkullRadiusToMouthHeight: CGFloat = 3
        static let SkullRadiusToMouthOffset: CGFloat = 3
        static let SkullRadiusToBrowOffset: CGFloat = 5
    }
    
    fileprivate  enum Eye
    {
        case left
        case right
    }
    
    fileprivate func pathForCircleCenteredAtPoint(_ midPoint: CGPoint, withRadius radius: CGFloat) -> UIBezierPath
    {
        let path = UIBezierPath(arcCenter: midPoint,
                            radius: radius,
                            startAngle: CGFloat(0.0),
                            endAngle: CGFloat(2*M_PI),
                            clockwise: false)
        path.lineWidth = lineWidth
        return path
    }
    
    fileprivate func getEyeCenter(_ eye: Eye) -> CGPoint
    {
        let eyeOffset = skullRadius / Ratios.SkullRadiusToEyeOffset
        var eyeCenter = skullCenter
        eyeCenter.y -= eyeOffset
        switch eye {
        case .left: eyeCenter.x -= eyeOffset
        case .right: eyeCenter.x += eyeOffset
        }
        return eyeCenter
    }
    
    // Instead, we are using EyeView to add to FaceView'
    //During initilization phrase self is not full initilized so we cannot use self and call its method
    //lazy means when someone call the variable it then will be initilized
    fileprivate lazy var leftEye: EyeView = self.createEye()
    fileprivate lazy var rightEye: EyeView = self.createEye()
    
    fileprivate func createEye() -> EyeView {
        print("i am called")
        let eye = EyeView()
        eye.isOpaque = false
        eye.color = color
        eye.lineWidth = lineWidth
        self.addSubview(eye)
        return eye
    }
    
    fileprivate func positionEye(_ eye: EyeView, center: CGPoint) {
        let size = skullRadius / Ratios.SkullRadiusToEyeRadius * 2
        eye.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: size, height: size))
        eye.center = center
    }
    
    //When system wants view to lay their subviews out
    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews is called")
        positionEye(leftEye, center: getEyeCenter(.left))
        positionEye(rightEye, center: getEyeCenter(.right))
    }
 
    fileprivate func pathForBrow(_ eye: Eye) -> UIBezierPath
    {
        var tilt = eyeBrowTilt
        switch eye {
        case .left: tilt *= -1.0
        case .right: break
        }
        var browCenter = getEyeCenter(eye)
        browCenter.y -= skullRadius / Ratios.SkullRadiusToBrowOffset
        let eyeRadius = skullRadius / Ratios.SkullRadiusToEyeRadius
        let tiltOffset = CGFloat(max(-1,min(tilt,1))) * eyeRadius / 2
        let browStart = CGPoint(x: browCenter.x - eyeRadius, y: browCenter.y - tiltOffset)
        let browEnd = CGPoint(x: browCenter.x + eyeRadius, y: browCenter.y + tiltOffset)
        let path = UIBezierPath()
        path.move(to: browStart)
        path.addLine(to: browEnd)
        path.lineWidth = lineWidth
        return path
    }
    
    fileprivate func pathForMouth() -> UIBezierPath
    {
        let mouthWidth = skullRadius / Ratios.SkullRadiusToMouthWidth
        let mouthHeight = skullRadius / Ratios.SkullRadiusToMouthHeight
        let mouthOffset = skullRadius / Ratios.SkullRadiusToMouthOffset
        
        let mouthRect = CGRect(x: skullCenter.x - mouthWidth / 2, y: skullCenter.y + mouthOffset, width: mouthWidth, height: mouthHeight)
        
        let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.minY)
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.minY)
        let cp1 = CGPoint(x: mouthRect.minX + mouthRect.width / 3, y: mouthRect.minY + smileOffset)
        let cp2 = CGPoint(x: mouthRect.maxX - mouthRect.width / 3, y: mouthRect.minY + smileOffset)
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
        
    }
    
    override func draw(_ rect: CGRect)
    {
        color.set()
        pathForCircleCenteredAtPoint(skullCenter, withRadius: skullRadius).stroke()
        pathForMouth().stroke()
        pathForBrow(.left).stroke()
        pathForBrow(.right).stroke()
        positionEye(leftEye, center: getEyeCenter(.left))
        positionEye(rightEye, center: getEyeCenter(.right))
    }


}
