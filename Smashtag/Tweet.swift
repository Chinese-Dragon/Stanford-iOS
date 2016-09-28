//
//  Tweet.swift
//  Smashtag
//
//  Created by Mark on 7/10/16.
//  Copyright © 2016 Mark. All rights reserved.
//

import Foundation
import CoreData
import Twitter

@objc(Tweet)
class Tweet: NSManagedObject {
    
    //load up twitter's tweets into coredata database
    class func tweetWithTwitterInfo(twitterInfo: Twitter.Tweet, inManagedObjectContext context: NSManagedObjectContext) -> Tweet?
    {
        let request = NSFetchRequest(entityName: "Tweet")
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.id)
        
        if let tweet = (try? context.executeFetchRequest(request))?.first as? Tweet
        {
            return tweet
            
        } else if let tweet = NSEntityDescription.insertNewObjectForEntityForName("Tweet", inManagedObjectContext: context) as? Tweet
        {
            tweet.unique = twitterInfo.id
            tweet.posted = twitterInfo.created
            tweet.text = twitterInfo.text
            tweet.tweeter = TwitterUser.TwitterUserWithTwitterInfo(twitterInfo.user, inManagedObjectContext: context)
            
            let allMentionsWithTwitterInfo = twitterInfo.hashtags + twitterInfo.userMentions
            let mentionsNSSet = tweet.mutableSetValueForKey("mentions")
            
            print("\(allMentionsWithTwitterInfo.count) allMentions")
            for currentMention in allMentionsWithTwitterInfo
            {
                if let mentionWithInfo = Mention.mentionWithTwitterInfo(currentMention, currentCoreDataTweet: tweet, inManagedObjectContext: context) {
                    print(mentionWithInfo.keyword)
                    mentionsNSSet.addObject(mentionWithInfo)
                }
            }
            print("\(mentionsNSSet.count) mentions associated with each tweet")
    
            return tweet
        }
        //in case for some reason we cannot convert one
        return nil
    }
    
}
