//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Mark on 7/6/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetScreenNameLabel: UILabel!

    @IBOutlet weak var tweetTextLabel: UILabel!

    @IBOutlet weak var tweetProfileImageView: UIImageView!
    
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    fileprivate var allMentions = [Array<Twitter.Mention>]()
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    fileprivate var mentionColor : Dictionary<String,UIColor> = [
        "hashtag": UIColor.brown,
        "url": UIColor.blue,
        "userMention": UIColor.cyan
    ]

    fileprivate func assignMentionsColor(_ type: String, mentions: [Twitter.Mention], mutableString: NSMutableAttributedString) {
        for mention in mentions {
            if let color = mentionColor[type]{
                mutableString.addAttribute(NSForegroundColorAttributeName, value: color, range: mention.nsrange)
            }
        }
    }
    
    fileprivate func updateUI()
    {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet
        {
            tweetTextLabel?.text = tweet.text
            if tweetTextLabel?.text != nil
            {
                let myMutableString  = NSMutableAttributedString(string: tweet.text)
                assignMentionsColor("hashtag", mentions: tweet.hashtags, mutableString: myMutableString)
                assignMentionsColor("url", mentions: tweet.urls, mutableString: myMutableString)
                assignMentionsColor("userMention", mentions: tweet.userMentions, mutableString: myMutableString)
                tweetTextLabel.attributedText = myMutableString
                
                for _ in tweet.media {
                    tweetTextLabel.text! += " 📷"
                }
            }
            
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
            
            if let profileImageURL = tweet.user.profileImageURL {
                if let imageData = Data(contentsOfURL: profileImageURL) { // blocks main thread!
                    DispatchQueue.main.async {
                        self.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                    
                }
            }
            
            let formatter = DateFormatter()
            if Date().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = DateFormatter.Style.short
            } else {
                formatter.timeStyle = DateFormatter.Style.short
            }
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
        }
        
    }
}
