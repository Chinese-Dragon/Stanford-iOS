//
//  TweetersTableViewController.swift
//  Smashtag
//
//  Created by Mark on 7/10/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit
import CoreData

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
    
    private func updateUI() {
        if let context = managedObjectContext where mention?.characters.count > 0 {
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
    
    private func tweetCountWithMentionByTwitterUser(user: TwitterUser) -> Int?{
        var count: Int?
        user.managedObjectContext?.performBlockAndWait({ 
            let request = NSFetchRequest(entityName: "Tweet")
            request.predicate = NSPredicate(format: "text contains[c] %@ and tweeter = %@", self.mention!, user)
            count = user.managedObjectContext?.countForFetchRequest(request, error: nil)
        })
        return count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TwitterUserCell", forIndexPath: indexPath)

        // Configure the cell...
        if let twitterUser = fetchedResultsController?.objectAtIndexPath(indexPath) as? TwitterUser {
            var screenName: String?
            
            //wait until the block is excuted before we configure the cell
            twitterUser.managedObjectContext?.performBlockAndWait({
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
