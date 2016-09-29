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
    
    fileprivate let emotionalFaces: Dictionary<String, FacialExpression> = [
        "angry": FacialExpression(eyes: .closed, eyeBrows: .furrowed, mouth: .frown),
        "happy": FacialExpression(eyes: .open, eyeBrows: .normal, mouth: .smile),
        "worried": FacialExpression(eyes: .open, eyeBrows: .relaxed, mouth: .smirk),
        "mischievious": FacialExpression(eyes: .open, eyeBrows: .furrowed, mouth: .grin)
    ]

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationvc = segue.destination as? UINavigationController {
            if let myfacevc = destinationvc.visibleViewController as? BlinkingFaceViewController, let identifier = segue.identifier, let expression = emotionalFaces[identifier]{
                myfacevc.expression = expression
                if let sendingButton = sender as? UIButton {
                    myfacevc.navigationItem.title = sendingButton.currentTitle
                }
            }
        }
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool
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
