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
    var imageURL: URL? {
        didSet{
            fetchImage()
        }
    }
    
    fileprivate func fetchImage() {
        if let url = imageURL {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                let contentOfURL = try? Data(contentsOf: url)
                DispatchQueue.main.async {
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
