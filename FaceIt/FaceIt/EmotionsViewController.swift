//
//  EmotionsViewController.swift
//  FaceIt
//
//  Created by Mark on 6/12/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

class EmotionsViewController: UIViewController, UISplitViewControllerDelegate
{
    override func viewDidLoad() {
        super.viewDidLoad()
        splitViewController?.delegate = self
    }
    
    private let emotionalFaces: Dictionary<String, FacialExpression> = [
        "angry": FacialExpression(eyes: .Closed, eyeBrows: .Furrowed, mouth: .Frown),
        "happy": FacialExpression(eyes: .Open, eyeBrows: .Normal, mouth: .Smile),
        "worried": FacialExpression(eyes: .Open, eyeBrows: .Relaxed, mouth: .Smirk),
        "mischievious": FacialExpression(eyes: .Open, eyeBrows: .Furrowed, mouth: .Grin)
    ]

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationvc = segue.destinationViewController as? UINavigationController {
            if let myfacevc = destinationvc.visibleViewController as? BlinkingFaceViewController, let identifier = segue.identifier, let expression = emotionalFaces[identifier]{
                myfacevc.expression = expression
                if let sendingButton = sender as? UIButton {
                    myfacevc.navigationItem.title = sendingButton.currentTitle
                }
            }
        }
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool
    {
//        if primaryViewController.contentViewController == self {
//            if let _ = secondaryViewController.contentViewController as? FaceViewController {
//                return true
//            }
//        }
        return true
    }

}

extension UIViewController {
    var contentViewController: UIViewController {
        get {
            if let navcon = self as? UINavigationController{
                return navcon.visibleViewController ?? self
            } else {
                return self
            }
        }
    }
}
