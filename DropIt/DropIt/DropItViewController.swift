//
//  DropItViewController.swift
//  DropIt
//
//  Created by Mark on 7/15/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

class DropItViewController: UIViewController {

    //Game view to dispaly all subviews (game components)
    @IBOutlet weak var gameView: DropItView! {
        didSet {
            gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addDrop(_:))))
            gameView.addGestureRecognizer(UIPanGestureRecognizer(target: gameView, action: #selector(DropItView.grabDrop(_:))))
            gameView.realGravity = true
        }
    }
   
    func addDrop(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            gameView.addDrop()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gameView.animating = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameView.animating = false
    }
}
