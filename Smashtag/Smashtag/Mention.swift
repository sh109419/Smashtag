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
    
    class func mentionWithTwitterInfo(_ searchTerm: String, twitterInfo: Twitter.Mention, inManagedObjectContext context: NSManagedObjectContext) -> Mention? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Mention")
        request.predicate = NSPredicate(format: "searchTerm =[c] %@ and keyWord = %@", searchTerm, twitterInfo.keyword)
        
        if let mention = (try? context.fetch(request))?.first as? Mention {
            mention.tweetCount = NSNumber(value: mention.tweetCount!.intValue + 1 as Int)
            return mention
        } else if let mention = NSEntityDescription.insertNewObject(forEntityName: "Mention", into: context) as? Mention {
            mention.searchTerm = searchTerm
            mention.keyWord = twitterInfo.keyword
            mention.keyWordWithoutPrefix = String(twitterInfo.keyword.characters.dropFirst())
            mention.prefix = twitterInfo.keyword.substring(to: twitterInfo.keyword.characters.index(after: twitterInfo.keyword.startIndex))
            mention.tweetCount = NSNumber(value: 1 as Int)
            return mention
        }
        
        return nil
    }


}
