//
//  GraphViewController.swift
//  Calculator
//
//  Created by Mark on 6/12/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    //model
    var graphProramData = [AnyObject]() {
        didSet {
            print("model set")
            updateGraph()
        }
    }
    
    //view
    @IBOutlet weak var graph: graphView! {
        didSet{
            
            graph.addGestureRecognizer(UIPinchGestureRecognizer(target: graph, action: #selector(graph.changeScale)))
            updateGraph()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    fileprivate func checkFunctionType(_ data: [AnyObject]) -> String {
        var type = "Linear"
        for item in data {
            if let strItem = item as? String{
                if strItem == "cos" || strItem == "sin" {
                    type = "Sinusoidal"
                }
            }
        }
        return type
    }

    fileprivate func updateGraph() {
        if graph != nil && !graphProramData.isEmpty {
            graph.graphType = checkFunctionType(graphProramData)
            graph.programInfo = graphProramData
            print(checkFunctionType(graphProramData))
        } else {
            print("graph is nil")
        }
    }
}
