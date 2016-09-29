//
//  NamedBezierPathsView.swift
//  DropIt
//
//  Created by Mark on 7/16/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

class NamedBezierPathsView: UIView
{
    var bezierPaths = [String: UIBezierPath]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        for (_,path) in bezierPaths {
            path.stroke()
        }
    }
}
