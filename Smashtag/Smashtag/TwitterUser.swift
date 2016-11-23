//
//  TwitterUser.swift
//  Smashtag
//
//  Created by hyf on 16/11/17.
//  Copyright © 2016年 hyf. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class TwitterUser: NSManagedObject {

    // a class method which
    // returns a TwitterUser from the database if Twitter.user has already been put in
    // or returns a newly-added-to-the-database TwitterUser if not
    
    class func twitterUserWithTwitterInfo(twitterInfo: Twitter.User, inManagedObjectContext context: NSManagedObjectContext) -> TwitterUser? {
        let request = NSFetchRequest(entityName: "TwitterUser")
        request.predicate = NSPredicate(format: "screenName = %@", twitterInfo.screenName)
        if let twitterUser = (try? context.executeFetchRequest(request))?.first as? TwitterUser {
            let count = twitterUser.tweetCount?.integerValue ?? 0
            twitterUser.tweetCount = NSNumber(integer: count + 1)
            return twitterUser
        } else if let twitterUser = NSEntityDescription.insertNewObjectForEntityForName("TwitterUser", inManagedObjectContext: context) as? TwitterUser {
            twitterUser.screenName = twitterInfo.screenName
            twitterUser.name = twitterInfo.name
            let count = twitterUser.tweetCount?.integerValue ?? 0
            twitterUser.tweetCount = NSNumber(integer: count + 1)
            return twitterUser
        }
        
        return nil
    }
}
