//
//  DetailDisclosureTableViewController.swift
//  Smashtag
//
//  Created by Mark on 7/11/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import UIKit
import CoreData

class DetailDisclosureTableViewController: CoreDataTableViewController {

    //Model
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    var mentionToSearchInCoreData: String? {
        didSet {
            title = mentionToSearchInCoreData
            updateUI()
        }
    }
    
    private func updateUI() {
        if let context = managedObjectContext where mentionToSearchInCoreData?.characters.count > 0 {
            let request = NSFetchRequest(entityName: "Mention")
            request.predicate = NSPredicate(format: "any tweets.text contains[c] %@ and mentionCount > 1",mentionToSearchInCoreData!)
            request.sortDescriptors = [NSSortDescriptor(
                key: "mentionCount",
                ascending: false,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil)
            
        } else {
            fetchedResultsController = nil
        }
    }
    
    // MARK: - Table view data source
  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MentionsOfSelectedRow", forIndexPath: indexPath)

        // Configure the cell...
        if let mention = fetchedResultsController?.objectAtIndexPath(indexPath) as? Mention {
            var mentionName: String?
            
            mention.managedObjectContext?.performBlockAndWait({ 
                mentionName = mention.keyword
            })
            cell.textLabel?.text = mentionName
            
            cell.detailTextLabel?.text = "\(mention.mentionCount) times mentioned "
        }
        return cell
    }

}
