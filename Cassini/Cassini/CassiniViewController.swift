//
//  CassiniViewController.swift
//  Cassini
//
//  Created by Mark on 6/30/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

class CassiniViewController: UIViewController{
    
    //Something we need from Storyboard
    private struct Storyboard {
        static let ShowImageSegue = "Show Image"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.ShowImageSegue{
            if let ivc = segue.destinationViewController.contentViewController as? ImageViewController {
                let imageName = (sender as? UIButton)?.currentTitle
                ivc.imageURL = DemoURL.NASAImageNamed(imageName)
                ivc.title = imageName
            }
        }
    }
    
    //check if it is in splitViewController (iPad), if true then we just replace content of detail view, if false it means we are in navigationController (iPhone), then we need use segue
    @IBAction func showImage(sender: UIButton) {
        if let ivc = splitViewController?.viewControllers.last?.contentViewController as? ImageViewController {
            let imageName = sender.currentTitle
            ivc.imageURL = DemoURL.NASAImageNamed(imageName)
            ivc.title = imageName
        } else {
            performSegueWithIdentifier(Storyboard.ShowImageSegue, sender: sender)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

