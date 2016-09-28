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
    var expression = FacialExpression(eyes: .Open, eyeBrows: .Furrowed, mouth: .Smile) {
        didSet {updateUI()}
    }
    
    //outlet of the view 
    @IBOutlet weak var faceView: FaceView! {
        didSet {
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: #selector(FaceView.changeScale(_:))))
            
            //since change mouth we need change model, which means that we can only do that in controller because view and model are seperated
            let happierSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(FaceViewController.increaseHappiness))
            happierSwipeGestureRecognizer.direction = .Down
            faceView.addGestureRecognizer(happierSwipeGestureRecognizer)
            
            let sadderSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(FaceViewController.decreaseHappiness))
            sadderSwipeGestureRecognizer.direction = .Up
            faceView.addGestureRecognizer(sadderSwipeGestureRecognizer)
            
            updateUI()
        }
    }
    
    private struct Animation {
        static let ShakeAngle = CGFloat(M_PI/6)
        static let ShakeDuration = 0.5
    }
    
    @IBAction func headShake(sender: UITapGestureRecognizer)
    {
        UIView.animateWithDuration(
            Animation.ShakeDuration,
            animations: {
                self.faceView.transform = CGAffineTransformRotate(self.faceView.transform, Animation.ShakeAngle)
            },
            completion: { finished in
                if finished {
                    UIView.animateWithDuration(
                        Animation.ShakeDuration,
                        animations: {
                            self.faceView.transform = CGAffineTransformRotate(self.faceView.transform, -Animation.ShakeAngle * 2)
                        },
                        completion: { finished in
                            if finished {
                                UIView.animateWithDuration(
                                    Animation.ShakeDuration,
                                    animations: {
                                        self.faceView.transform = CGAffineTransformRotate(self.faceView.transform, Animation.ShakeAngle)
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
    private var mouthCurvatures = [FacialExpression.Mouth.Frown: -1.0,
                                   .Grin: 0.5,
                                   .Smile: 1.0,
                                   .Smirk: -0.5,
                                   .Neutral: 0.0]
    private var eyeBrowTilts = [FacialExpression.EyeBrows.Relaxed: 0.5,
                                .Furrowed: -0.5,
                                .Normal: 0.0]
    private var eyes = [FacialExpression.Eyes.Open: true,
                        .Closed: false,
                        .Squinting: false]
    
    private func updateUI()
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

