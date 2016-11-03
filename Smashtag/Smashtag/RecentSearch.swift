//
//  RecentSearch.swift
//  Smashtag
//
//  Created by hyf on 16/10/31.
//  Copyright © 2016年 hyf. All rights reserved.
//

import Foundation

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
            list.removeLast()
        }
        defaults.setObject(list, forKey: Constants.searchKey)
    }
    
    static func removeAtIndex(index: Int) {
        var list = recentSearch
        list.removeAtIndex(index)
        defaults.setObject(list, forKey: Constants.searchKey)
    }
}


