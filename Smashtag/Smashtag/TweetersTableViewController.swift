//
//  TweetersTableViewController.swift
//  Smashtag
//
//  Created by Mark on 7/10/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class TweetersTableViewController: CoreDataTableViewController {
    
    //Model
    //It is the mention (# or @) to search in the local db
    var mention: String? {
        didSet { updateUI() }
    }
    //it is the context of our coredata db
    var managedObjectContext: NSManagedObjectContext? {
        didSet { updateUI() }
    }
    
    fileprivate func updateUI() {
        if let context = managedObjectContext , mention?.characters.count > 0 {
            let request = NSFetchRequest(entityName: "TwitterUser")
            request.predicate = NSPredicate(format: "any tweets.text contains[c] %@", mention!)
            request.sortDescriptors = [NSSortDescriptor(
                key: "screenName",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
            )]
            
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil)
            
        } else {
            fetchedResultsController = nil
        }
    }
    
    fileprivate func tweetCountWithMentionByTwitterUser(_ user: TwitterUser) -> Int?{
        var count: Int?
        user.managedObjectContext?.performAndWait({ 
            let request = NSFetchRequest(entityName: "Tweet")
            request.predicate = NSPredicate(format: "text contains[c] %@ and tweeter = %@", self.mention!, user)
            count = user.managedObjectContext?.count(for: request, error: nil)
        })
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TwitterUserCell", for: indexPath)

        // Configure the cell...
        if let twitterUser = fetchedResultsController?.object(at: indexPath) as? TwitterUser {
            var screenName: String?
            
            //wait until the block is excuted before we configure the cell
            twitterUser.managedObjectContext?.performAndWait({
                //cannot update UI in another thread even though in this situation the block is always in the main thread
                screenName = twitterUser.screenName
            })
            cell.textLabel?.text = screenName
            
            if let count = tweetCountWithMentionByTwitterUser(twitterUser) {
                cell.detailTextLabel?.text = (count == 1) ? "1 tweet" : "\(count) tweets"
            } else {
                cell.detailTextLabel?.text = ""
            }
            
        }
        return cell
    }
    
    


}
