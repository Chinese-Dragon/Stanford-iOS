//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Mark on 7/2/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit
import Twitter
import CoreData

//Golbal Model to store the searching history
var RecentSearchHistory = [String]()

let HistorySize = 100


class TweetTableViewController: UITableViewController,UITextFieldDelegate {
    
    
    
    //Model -- array of array of tweets (outer part is section and inner part is row
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    var searchText: String? {
        didSet {
            tweets.removeAll()
            lastTwitterRequest = nil
            searchForTweets()
            title = searchText
        }
    }
    
    
    //Storyboard stuff
    private struct Storyboard {
        static let TweetCellIndentifier = "Tweet"
        static let SegueIndentifier = "show Tweet Info"
        static let SegueIndentifier2 = "TweetersMentioningSearchTerm"
    }
    
    
    //App life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        if NSUserDefaults.standardUserDefaults().objectForKey("myData") != nil {
            RecentSearchHistory = NSUserDefaults.standardUserDefaults().objectForKey("myData") as! [String]
        }
    }
    
    //Search tweets and stuff
    // getter ignored, if searchText is nil then the twitterRequest should be nil also
    private var twitterRequest: Twitter.Request? {
        if lastTwitterRequest == nil {
            if let query = searchText where !query.isEmpty {
                return Twitter.Request(search: query + " -filter:retweets", count: 5)
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
                    weakSelf?.refreshControl?.endRefreshing()
                    weakSelf?.updateDatabase(newTweets)
                    
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
        
    }
    
    private func storeForever(searchInfo: String) {
        if RecentSearchHistory.count == HistorySize{
            RecentSearchHistory.removeFirst()
            RecentSearchHistory.append(searchInfo)
        } else {
            RecentSearchHistory.append(searchInfo)
        }
        NSUserDefaults.standardUserDefaults().setObject(RecentSearchHistory, forKey: "myData")
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        searchForTweets()
    }
    
    private func updateDatabase(newTweets:[Twitter.Tweet]) {
        //closure here
        managedObjectContext?.performBlock{
            for twitterInfo in newTweets {
                _ = Tweet.tweetWithTwitterInfo(twitterInfo, inManagedObjectContext: self.managedObjectContext!)
            }
            do {
                try self.managedObjectContext!.save()
            } catch let error{
                print("Core data error \(error)")
            }
            
        }
        printDatabaseStatistics()
        print("Done printing db statistics")
    }
    
    private func printDatabaseStatistics() {
        managedObjectContext?.performBlock {
            if let results = try? self.managedObjectContext!.executeFetchRequest(NSFetchRequest(entityName: "TwitterUser")) {
                print("\(results.count) Twitter Users in my database")
            }
            
            //more efficient way to count objects in db
            let tweetCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "Tweet"), error: nil)
            print("\(tweetCount) tweets in my DB ")
            
            let mentionCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName:"Mention"), error: nil)
            print("\(mentionCount) mentions in my DB")
        }
        
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetCellIndentifier, forIndexPath: indexPath)
        
        let tweet = tweets[indexPath.section][indexPath.row]
        
        // Configure the custom cell...
        
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        return cell
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
       
            searchTextField.delegate = self
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        searchText = textField.text
        if let searchInfo = textField.text {
            storeForever(searchInfo)
        }
        searchTextField.text = ""
        return true
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Storyboard.SegueIndentifier {
            if let cell = sender as? TweetTableViewCell {
                let tweet = tweets[(self.tableView.indexPathForCell(cell)?.section)!][(self.tableView.indexPathForCell(cell)?.row)!]
                if let vc = segue.destinationViewController as? TweetMentionDetailTableViewController {
                    vc.tweet = tweet
                }
            }
        } else if segue.identifier == Storyboard.SegueIndentifier2 {
            if let tweetersTVC = segue.destinationViewController as? TweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.managedObjectContext = managedObjectContext
            }
        }
    }
    
    
}
