//
//  Tweet.swift
//  Smashtag
//
//  Created by hyf on 16/11/17.
//  Copyright © 2016年 hyf. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class Tweet: NSManagedObject {

    // a class method which
    // returns a Tweet from the database if Twitter.Tweet has already been put in
    // or returns a newly-added-to-the-database Tweet if not
    
    class func tweetWithTwitterInfo(twitterInfo: Twitter.Tweet, inManagedObjectContext context: NSManagedObjectContext) -> Tweet? {
        let request = NSFetchRequest(entityName: "Tweet")
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.id)
        
        if let tweet = (try? context.executeFetchRequest(request))?.first as? Tweet {
            return tweet
        } else if let tweet = NSEntityDescription.insertNewObjectForEntityForName("Tweet", inManagedObjectContext: context) as? Tweet {
            tweet.unique = twitterInfo.id
            tweet.text = twitterInfo.text
            tweet.posted = twitterInfo.created
            tweet.tweeter = TwitterUser.twitterUserWithTwitterInfo(twitterInfo.user, inManagedObjectContext: context)
            return tweet
        }
        
        return nil
    }

}
