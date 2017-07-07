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
    
    fileprivate static let defaults = UserDefaults.standard
    
    fileprivate struct Constants {
        static let numberOfSerchLimit = 100
        static let searchKey = "SearchHistory"
    }
    
    static var recentSearch: [String] {
        return defaults.object(forKey: Constants.searchKey) as? [String] ?? []
    }
    
    static func add(_ text: String) {
        var list = recentSearch.filter() {
            return $0.lowercased() != text.lowercased()
        }
        list.insert(text, at: 0)
        while list.count > Constants.numberOfSerchLimit {
            deleteSearchTerm(list.last!)
            list.removeLast()
        }
        defaults.set(list, forKey: Constants.searchKey)
    }
    
    static func removeAtIndex(_ index: Int) {
        var list = recentSearch
        deleteSearchTerm(list[index])
        list.remove(at: index)
        defaults.set(list, forKey: Constants.searchKey)
    }
    
    static func deleteSearchTerm(_ searchTerm: String) {
        let time = Date()
        let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.document.managedObjectContext
        // tweet
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tweet")
        fetchRequest.predicate = NSPredicate(format: "searchTerm =[c] %@", searchTerm)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        // mention
        let mentionRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Mention")
        mentionRequest.predicate = NSPredicate(format: "searchTerm =[c] %@", searchTerm)
        let deleteMentionRequest = NSBatchDeleteRequest(fetchRequest: mentionRequest)
        
        // perform the batch delete
        do {
            try managedObjectContext?.execute(deleteRequest)
            try managedObjectContext?.execute(deleteMentionRequest)
            try managedObjectContext?.save()
        } catch let error {
            print("Core Data Error: \(error)")
        }
        print("Time to delete with batch request: \(Date().timeIntervalSince(time))")
        //updateUI()
       
        // show searchterms in database
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tweet")
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = ["searchTerm"]
        if let results = try? managedObjectContext!.fetch(request) {
            for obj in results {
                print((obj as! NSDictionary).allValues)
            }
        }
       
    }
    
}


