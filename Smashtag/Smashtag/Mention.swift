//
//  Mention.swift
//  Smashtag
//
//  Created by hyf on 16/11/24.
//  Copyright © 2016年 hyf. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class Mention: NSManagedObject {


    // the primary key is searchTerm + mention
    
    class func mentionWithTwitterInfo(searchTerm: String, twitterInfo: Twitter.Mention, inManagedObjectContext context: NSManagedObjectContext) -> Mention? {
        let request = NSFetchRequest(entityName: "Mention")
        request.predicate = NSPredicate(format: "searchTerm =[c] %@ and keyWord = %@", searchTerm, twitterInfo.keyword)
        
        if let mention = (try? context.executeFetchRequest(request))?.first as? Mention {
            mention.tweetCount = NSNumber(integer: mention.tweetCount!.integerValue + 1)
            return mention
        } else if let mention = NSEntityDescription.insertNewObjectForEntityForName("Mention", inManagedObjectContext: context) as? Mention {
            mention.searchTerm = searchTerm
            mention.keyWord = twitterInfo.keyword
            mention.keyWordWithoutPrefix = String(twitterInfo.keyword.characters.dropFirst())
            mention.prefix = String(twitterInfo.keyword.characters.first)
            mention.tweetCount = NSNumber(integer: 1)
            return mention
        }
        
        return nil
    }


}
