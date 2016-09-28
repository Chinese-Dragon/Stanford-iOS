//
//  RecentSearchTableViewController.swift
//  Smashtag
//
//  Created by Mark on 7/9/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit

class RecentSearchTableViewController: UITableViewController {
    
    //Model -- RecentSearchHistory: the global data
    override func viewDidLoad() {
        title = "History"
        if NSUserDefaults.standardUserDefaults().objectForKey("myData") != nil {
            
            //model
            RecentSearchHistory = NSUserDefaults.standardUserDefaults().objectForKey("myData") as! [String]
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    private struct Storyboard {
        static let segueIdentifier = "Show Tweets"
        static let segueIdentifier2 = "Show Detail"
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return RecentSearchHistory.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("history", forIndexPath: indexPath)

        if !RecentSearchHistory.isEmpty{
            cell.textLabel?.text = RecentSearchHistory[RecentSearchHistory.count - indexPath.row - 1]
            
        }
        // Configure the cell...

        return cell
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.segueIdentifier, let dvc = segue.destinationViewController as? TweetSegueViewController
        {
            dvc.searchText = RecentSearchHistory[RecentSearchHistory.count - (self.tableView.indexPathForCell(sender as! UITableViewCell)?.row)! - 1]
        } else if segue.identifier == Storyboard.segueIdentifier2, let dvc = segue.destinationViewController as? DetailDisclosureTableViewController
        {
            dvc.mentionToSearchInCoreData = RecentSearchHistory[RecentSearchHistory.count - (self.tableView.indexPathForCell(sender as! UITableViewCell)?.row)! - 1]
        }
    }
    

}
