//
//  TweetSegueViewController.swift
//  Smashtag
//
//  Created by Mark on 7/8/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit
import Twitter

class TweetSegueViewController: UITableViewController {

    //Model array of array of tweets (outer part is section and inner part is row)
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    

    var searchText: String? {
        didSet {
            tweets.removeAll()
            lastTwitterRequest = nil
            searchForTweets()
            title = searchText
        }
    }
    
    // getter ignored, if searchText is nil then the twitterRequest should be nil also
    private var twitterRequest: Twitter.Request? {
        if lastTwitterRequest == nil {
            if let query = searchText where !query.isEmpty {
                return Twitter.Request(search: query + " -filter:retweets", count: 30)
            }
        }
        return lastTwitterRequest?.requestForNewer
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        //make sure it is not nil
        if let request = twitterRequest {
            lastTwitterRequest = request
            request.fetchTweets { [weak weakSelf = self] newTweets in
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, atIndex: 0)
                        }
                    }
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tweets.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets[section].count
    }
    
    private struct Storyboard {
        static let TweetCellIndentifier = "tweet2"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetCellIndentifier, forIndexPath: indexPath)
        
        let tweet = tweets[indexPath.section][indexPath.row]
        
        // Configure the custom cell...
        
        if let tweetCell = cell as? TweetSegueTableViewCell {
            tweetCell.tweet = tweet
        }
        return cell
    }

}
