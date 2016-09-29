//
//  ViewController.swift
//  FaceIt
//
//  Created by Mark on 6/10/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController
{
    
    //Model
    var expression = FacialExpression(eyes: .open, eyeBrows: .furrowed, mouth: .smile) {
        didSet {updateUI()}
    }
    
    //outlet of the view 
    @IBOutlet weak var faceView: FaceView! {
        didSet {
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: #selector(FaceView.changeScale(_:))))
            
            //since change mouth we need change model, which means that we can only do that in controller because view and model are seperated
            let happierSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(FaceViewController.increaseHappiness))
            happierSwipeGestureRecognizer.direction = .down
            faceView.addGestureRecognizer(happierSwipeGestureRecognizer)
            
            let sadderSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(FaceViewController.decreaseHappiness))
            sadderSwipeGestureRecognizer.direction = .up
            faceView.addGestureRecognizer(sadderSwipeGestureRecognizer)
            
            updateUI()
        }
    }
    
    fileprivate struct Animation {
        static let ShakeAngle = CGFloat(M_PI/6)
        static let ShakeDuration = 0.5
    }
    
    @IBAction func headShake(_ sender: UITapGestureRecognizer)
    {
        UIView.animate(
            withDuration: Animation.ShakeDuration,
            animations: {
                self.faceView.transform = self.faceView.transform.rotated(by: Animation.ShakeAngle)
            },
            completion: { finished in
                if finished {
                    UIView.animate(
                        withDuration: Animation.ShakeDuration,
                        animations: {
                            self.faceView.transform = self.faceView.transform.rotated(by: -Animation.ShakeAngle * 2)
                        },
                        completion: { finished in
                            if finished {
                                UIView.animate(
                                    withDuration: Animation.ShakeDuration,
                                    animations: {
                                        self.faceView.transform = self.faceView.transform.rotated(by: Animation.ShakeAngle)
                                    },
                                    completion: { finished in
                                        if finished {
                                            
                                        }
                                    }
                                )
                            }
                        }
                    )
                }
            }
        )
    }
//    @IBAction func toggleEyes(recognizer: UITapGestureRecognizer) {
//        if recognizer.state == .Ended {
//            switch expression.eyes {
//            case .Open: expression.eyes = .Closed
//            case .Closed: expression.eyes = .Open
//            case .Squinting: break
//            }
//        }
//        
//    }
    
    
    //interpret model info to reflect changes in views, a maping
    fileprivate var mouthCurvatures = [FacialExpression.Mouth.frown: -1.0,
                                   .grin: 0.5,
                                   .smile: 1.0,
                                   .smirk: -0.5,
                                   .neutral: 0.0]
    fileprivate var eyeBrowTilts = [FacialExpression.EyeBrows.relaxed: 0.5,
                                .furrowed: -0.5,
                                .normal: 0.0]
    fileprivate var eyes = [FacialExpression.Eyes.open: true,
                        .closed: false,
                        .squinting: false]
    
    fileprivate func updateUI()
    {
        if faceView != nil{
            faceView.eyesOpen = eyes[expression.eyes] ?? true
            faceView.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0 //we can alo use switch
            faceView.eyeBrowTilt = eyeBrowTilts[expression.eyeBrows] ?? 0.0
        }
    }
    
    func increaseHappiness() {
        expression.mouth = expression.mouth.happierMouth()
    }
    
    func decreaseHappiness() {
        expression.mouth = expression.mouth.sadderMouth()
    }
    
    
    
    

}

