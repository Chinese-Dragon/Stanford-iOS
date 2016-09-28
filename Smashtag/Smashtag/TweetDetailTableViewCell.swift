//
//  TweetDetailTableViewCell.swift
//  Smashtag
//
//  Created by Mark on 7/7/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

class TweetDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetImage: UIImageView!
    
    //Model
    var imageURL: NSURL? {
        didSet{
            fetchImage()
        }
    }
    
    private func fetchImage() {
        if let url = imageURL {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                let contentOfURL = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) {
                    if url == self.imageURL {
                        if let imageData = contentOfURL {
                            self.tweetImage.image = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
    

    
}
