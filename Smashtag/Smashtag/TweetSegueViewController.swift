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
    fileprivate var twitterRequest: Twitter.Request? {
        if lastTwitterRequest == nil {
            if let query = searchText , !query.isEmpty {
                return Twitter.Request(search: query + " -filter:retweets", count: 30)
            }
        }
        return lastTwitterRequest?.requestForNewer
    }
    
    fileprivate var lastTwitterRequest: Twitter.Request?
    
    fileprivate func searchForTweets() {
        //make sure it is not nil
        if let request = twitterRequest {
            lastTwitterRequest = request
            request.fetchTweets { [weak weakSelf = self] newTweets in
                DispatchQueue.main.async {
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets[section].count
    }
    
    fileprivate struct Storyboard {
        static let TweetCellIndentifier = "tweet2"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TweetCellIndentifier, for: indexPath)
        
        let tweet = tweets[indexPath.section][indexPath.row]
        
        // Configure the custom cell...
        
        if let tweetCell = cell as? TweetSegueTableViewCell {
            tweetCell.tweet = tweet
        }
        return cell
    }

}
