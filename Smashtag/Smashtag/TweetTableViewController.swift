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
        (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    
    var searchText: String? {
        didSet {
            tweets.removeAll()
            lastTwitterRequest = nil
            searchForTweets()
            title = searchText
        }
    }
    
    
    //Storyboard stuff
    fileprivate struct Storyboard {
        static let TweetCellIndentifier = "Tweet"
        static let SegueIndentifier = "show Tweet Info"
        static let SegueIndentifier2 = "TweetersMentioningSearchTerm"
    }
    
    
    //App life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        if UserDefaults.standard.object(forKey: "myData") != nil {
            RecentSearchHistory = UserDefaults.standard.object(forKey: "myData") as! [String]
        }
    }
    
    //Search tweets and stuff
    // getter ignored, if searchText is nil then the twitterRequest should be nil also
    fileprivate var twitterRequest: Twitter.Request? {
        if lastTwitterRequest == nil {
            if let query = searchText , !query.isEmpty {
                return Twitter.Request(search: query + " -filter:retweets", count: 5)
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
                            weakSelf?.tweets.insert(newTweets, at: 0)
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
    
    fileprivate func storeForever(_ searchInfo: String) {
        if RecentSearchHistory.count == HistorySize{
            RecentSearchHistory.removeFirst()
            RecentSearchHistory.append(searchInfo)
        } else {
            RecentSearchHistory.append(searchInfo)
        }
        UserDefaults.standard.set(RecentSearchHistory, forKey: "myData")
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        searchForTweets()
    }
    
    fileprivate func updateDatabase(_ newTweets:[Twitter.Tweet]) {
        //closure here
        managedObjectContext?.perform{
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
    
    fileprivate func printDatabaseStatistics() throws {
        managedObjectContext?.perform {
            if let results = try? self.managedObjectContext!.fetch(NSFetchRequest(entityName: "TwitterUser")) {
                print("\(results.count) Twitter Users in my database")
            }
            
            //more efficient way to count objects in db
            guard let tweetCount = self.managedObjectContext!.count(for: NSFetchRequest(entityName: "Tweet")) else  {
                
            }
            print("\(tweetCount) tweets in my DB ")
            
            guard let mentionCount = self.managedObjectContext!.count(for: NSFetchRequest(entityName:"Mention"))
            print("\(mentionCount) mentions in my DB")
        }
        
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TweetCellIndentifier, for: indexPath)
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        searchText = textField.text
        if let searchInfo = textField.text {
            storeForever(searchInfo)
        }
        searchTextField.text = ""
        return true
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Storyboard.SegueIndentifier {
            if let cell = sender as? TweetTableViewCell {
                let tweet = tweets[(self.tableView.indexPath(for: cell)?.section)!][(self.tableView.indexPathForCell(cell)?.row)!]
                if let vc = segue.destination as? TweetMentionDetailTableViewController {
                    vc.tweet = tweet
                }
            }
        } else if segue.identifier == Storyboard.SegueIndentifier2 {
            if let tweetersTVC = segue.destination as? TweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.managedObjectContext = managedObjectContext
            }
        }
    }
    
    
}
