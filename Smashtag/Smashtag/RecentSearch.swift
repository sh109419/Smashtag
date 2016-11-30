//
//  RecentSearch.swift
//  Smashtag
//
//  Created by hyf on 16/10/31.
//  Copyright © 2016年 hyf. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct RecentSearch {
    
    private static let defaults = NSUserDefaults.standardUserDefaults()
    
    private struct Constants {
        static let numberOfSerchLimit = 100
        static let searchKey = "SearchHistory"
    }
    
    static var recentSearch: [String] {
        return defaults.objectForKey(Constants.searchKey) as? [String] ?? []
    }
    
    static func add(text: String) {
        var list = recentSearch.filter() {
            return $0.lowercaseString != text.lowercaseString
        }
        list.insert(text, atIndex: 0)
        while list.count > Constants.numberOfSerchLimit {
            deleteSearchTerm(list.last!)
            list.removeLast()
        }
        defaults.setObject(list, forKey: Constants.searchKey)
    }
    
    static func removeAtIndex(index: Int) {
        var list = recentSearch
        deleteSearchTerm(list[index])
        list.removeAtIndex(index)
        defaults.setObject(list, forKey: Constants.searchKey)
    }
    
    static func deleteSearchTerm(searchTerm: String) {
        let time = NSDate()
        let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.document.managedObjectContext
        // tweet
        let fetchRequest = NSFetchRequest(entityName: "Tweet")
        fetchRequest.predicate = NSPredicate(format: "searchTerm =[c] %@", searchTerm)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        // mention
        let mentionRequest = NSFetchRequest(entityName: "Mention")
        mentionRequest.predicate = NSPredicate(format: "searchTerm =[c] %@", searchTerm)
        let deleteMentionRequest = NSBatchDeleteRequest(fetchRequest: mentionRequest)
        
        // perform the batch delete
        do {
            try managedObjectContext?.executeRequest(deleteRequest)
            try managedObjectContext?.executeRequest(deleteMentionRequest)
            try managedObjectContext?.save()
        } catch let error {
            print("Core Data Error: \(error)")
        }
        print("Time to delete with batch request: \(NSDate().timeIntervalSinceDate(time))")
        //updateUI()
       
        // show searchterms in database
        let request = NSFetchRequest(entityName: "Tweet")
        request.resultType = .DictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = ["searchTerm"]
        if let results = try? managedObjectContext!.executeFetchRequest(request) {
            for obj in results {
                print((obj as! NSDictionary).allValues)
            }
        }
       
    }
    
}


