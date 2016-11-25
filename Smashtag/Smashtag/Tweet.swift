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
    
    // the primary key is searchTerm + unique
    
    class func tweetWithTwitterInfo(searchTerm: String, twitterInfo: Twitter.Tweet, inManagedObjectContext context: NSManagedObjectContext) -> Tweet? {
        let request = NSFetchRequest(entityName: "Tweet")
        request.predicate = NSPredicate(format: "searchTerm =[c] %@ and unique = %@", searchTerm, twitterInfo.id)
        
        if let tweet = (try? context.executeFetchRequest(request))?.first as? Tweet {
            return tweet
        } else if let tweet = NSEntityDescription.insertNewObjectForEntityForName("Tweet", inManagedObjectContext: context) as? Tweet {
            tweet.searchTerm = searchTerm
            tweet.unique = twitterInfo.id
            tweet.text = twitterInfo.text
            // reset set of mentions
            let mentionsRelation = NSMutableSet()
            let mentions = twitterInfo.hashtags + twitterInfo.userMentions
            for mention in mentions {
                if let newMention = Mention.mentionWithTwitterInfo(searchTerm, twitterInfo: mention, inManagedObjectContext: context) {
                    mentionsRelation.addObject(newMention)
                }
            }
            tweet.mentions = mentionsRelation
            return tweet
        }
        
        return nil
    }

}
