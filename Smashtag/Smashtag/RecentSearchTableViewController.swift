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
        if UserDefaults.standard.object(forKey: "myData") != nil {
            
            //model
            RecentSearchHistory = UserDefaults.standard.object(forKey: "myData") as! [String]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    fileprivate struct Storyboard {
        static let segueIdentifier = "Show Tweets"
        static let segueIdentifier2 = "Show Detail"
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return RecentSearchHistory.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "history", for: indexPath)

        if !RecentSearchHistory.isEmpty{
            cell.textLabel?.text = RecentSearchHistory[RecentSearchHistory.count - (indexPath as NSIndexPath).row - 1]
            
        }
        // Configure the cell...

        return cell
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.segueIdentifier, let dvc = segue.destination as? TweetSegueViewController
        {
            dvc.searchText = RecentSearchHistory[RecentSearchHistory.count - ((self.tableView.indexPath(for: sender as! UITableViewCell) as NSIndexPath?)?.row)! - 1]
        } else if segue.identifier == Storyboard.segueIdentifier2, let dvc = segue.destination as? DetailDisclosureTableViewController
        {
            dvc.mentionToSearchInCoreData = RecentSearchHistory[RecentSearchHistory.count - ((self.tableView.indexPath(for: sender as! UITableViewCell) as NSIndexPath?)?.row)! - 1]
        }
    }
    

}
