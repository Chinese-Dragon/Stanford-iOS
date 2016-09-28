//
//  Mention.swift
//  Smashtag
//
//  Created by Mark on 7/11/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import Foundation
import CoreData
import Twitter

class Mention: NSManagedObject {
    
    // Insert code here to add functionality to your managed object subclass
    
    class func mentionWithTwitterInfo(twitterInfo:Twitter.Mention, currentCoreDataTweet: Tweet, inManagedObjectContext context: NSManagedObjectContext) -> Mention? {
        
        let request = NSFetchRequest(entityName: "Mention")
        request.predicate = NSPredicate(format: "keyword matches[c] %@ and any tweets.unique = %@", twitterInfo.keyword, currentCoreDataTweet.unique!)
        
        let request2 = NSFetchRequest(entityName: "Mention")
        request2.predicate = NSPredicate(format: "keyword matches[c] %@", twitterInfo.keyword)
    
        
        if let _ = (try? context.executeFetchRequest(request))?.first as? Mention {
            return nil
        } else if let mention = (try? context.executeFetchRequest(request2))?.first as? Mention{
            mention.mutableSetValueForKey("tweets").addObject(currentCoreDataTweet)
            mention.mentionCount += 1
            return mention
        } else if let mention = NSEntityDescription.insertNewObjectForEntityForName("Mention", inManagedObjectContext: context) as? Mention {
            mention.keyword = twitterInfo.keyword
            mention.mutableSetValueForKey("tweets").addObject(currentCoreDataTweet)
            mention.mentionCount += 1
            return mention
        }
        
        return nil
    }
}
