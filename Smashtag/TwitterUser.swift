//
//  TwitterUser.swift
//  Smashtag
//
//  Created by Mark on 7/10/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import Foundation
import CoreData
import Twitter

@objc(TwitterUser)
class TwitterUser: NSManagedObject {
    
    class func TwitterUserWithTwitterInfo(_ twitterInfo: Twitter.User, inManagedObjectContext context: NSManagedObjectContext) -> TwitterUser? {
  
        let request = NSFetchRequest(entityName: "TwitterUser")
        request.predicate = NSPredicate(format: "screenName = %@", twitterInfo.screenName)
        
        if let twitterUser = (try? context.fetch(request))?.first as? TwitterUser {
            return twitterUser
        } else if let twitterUser = NSEntityDescription.insertNewObject(forEntityName: "TwitterUser", into: context) as? TwitterUser {
            twitterUser.screenName = twitterInfo.screenName
            twitterUser.name = twitterInfo.name
            return twitterUser
        }
        return nil
    }
    
}
