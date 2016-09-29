//
//  TweetMentionDetailTableViewController.swift
//  Smashtag
//
//  Created by Mark on 7/7/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit
import Twitter

class TweetMentionDetailTableViewController: UITableViewController {
    
    
    //Model - data from previous MVC
    var tweet:Twitter.Tweet? {
        didSet {
            title = tweet?.user.name
        }
    }
    
    fileprivate let numberOfSection = 4
    
    fileprivate struct Storyboard {
        static let TweetImageCellIdentifier = "images"
        static let TweetMentionCellIdentifier = "mentions"
        static let SegueIdentifier = "Show Tweets"
    }
    
    fileprivate var sectionIdentifiers: Dictionary<Int,String> = [
        0: "images",
        1: "mentions",
        2: "mentions",
        3: "mentions"
    ]
    
    fileprivate var sectionNames : Dictionary<Int,String> = [
        0 : "Images",
        1 : "Hashtags",
        2 : "Users",
        3 : "urls"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSection
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentTweet = tweet{
            return getTweetInfo(section, tweet: currentTweet)
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: sectionIdentifiers[(indexPath as NSIndexPath).section]!, for: indexPath)
        if let currentTweet = tweet {
            if let imageCell = cell as? TweetDetailTableViewCell {
                imageCell.imageURL = currentTweet.media[indexPath.row].url
            } else {
                switch (indexPath as NSIndexPath).section {
                case 1:
                    cell.textLabel?.text = currentTweet.hashtags[indexPath.row].keyword
                case 2:
                    cell.textLabel?.text = currentTweet.userMentions[indexPath.row].keyword
                case 3:
                    cell.textLabel?.text = currentTweet.urls[indexPath.row].keyword
                default:
                    break
                }
            }
        }
        return cell
    }
    
    fileprivate func getTweetInfo(_ section: Int,tweet: Twitter.Tweet) -> Int{
        switch section {
        case 0: return tweet.media.count
        case 1: return tweet.hashtags.count
        case 2: return tweet.userMentions.count
        case 3: return tweet.urls.count
        default:return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let currentTweet = tweet{
            if getTweetInfo(section, tweet: currentTweet) != 0 {
                return sectionNames[section]
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let currentTweet = tweet {
            if (indexPath as NSIndexPath).section == 0 {
                return tableView.frame.width / CGFloat(currentTweet.media[indexPath.row].aspectRatio)
            }
        }
        return UITableViewAutomaticDimension
    }
       
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell,let currentTweet = tweet{
            let sec = (self.tableView.indexPath(for: cell)! as NSIndexPath).section
            let row = (self.tableView.indexPath(for: cell)! as NSIndexPath).row
            print("Section \(sec) Row \(row)")
            if segue.identifier == Storyboard.SegueIdentifier,let vc = segue.destination as? TweetSegueViewController {
                switch sec {
                case 1:
                    let searchHashTag = currentTweet.hashtags[row].keyword
                    vc.searchText = searchHashTag
                    storeForever(searchHashTag)
                case 2:
                    let searchUser = currentTweet.userMentions[row].keyword
                    vc.searchText = searchUser
                    storeForever(searchUser)
                default:
                    break
                }
            }
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let cell = sender as? UITableViewCell{
            let sec = (self.tableView.indexPath(for: cell)! as NSIndexPath).section
            if identifier == Storyboard.SegueIdentifier && sec != 3 {
                return true
            }
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (indexPath as NSIndexPath).section == 3, let currentTweet = tweet {
            if let url = URL(string: currentTweet.urls[indexPath.row].keyword) {
                UIApplication.sharedApplication.openURL(url)
            }
        }
        return indexPath
    }
    
    
}
