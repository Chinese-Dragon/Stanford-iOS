//
//  DetailDisclosureTableViewController.swift
//  Smashtag
//
//  Created by Mark on 7/11/16.
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


class DetailDisclosureTableViewController: CoreDataTableViewController {

    //Model
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    
    var mentionToSearchInCoreData: String? {
        didSet {
            title = mentionToSearchInCoreData
            updateUI()
        }
    }
    
    fileprivate func updateUI() {
        if let context = managedObjectContext , mentionToSearchInCoreData?.characters.count > 0 {
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
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MentionsOfSelectedRow", for: indexPath)

        // Configure the cell...
        if let mention = fetchedResultsController?.object(at: indexPath) as? Mention {
            var mentionName: String?
            
            mention.managedObjectContext?.performAndWait({ 
                mentionName = mention.keyword
            })
            cell.textLabel?.text = mentionName
            
            cell.detailTextLabel?.text = "\(mention.mentionCount) times mentioned "
        }
        return cell
    }

}
