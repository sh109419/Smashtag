//
//  Mention+CoreDataProperties.swift
//  Smashtag
//
//  Created by hyf on 16/11/24.
//  Copyright © 2016年 hyf. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Mention {

    @NSManaged var keyWord: String?
    @NSManaged var keyWordWithoutPrefix: String?
    @NSManaged var tweetCount: NSNumber?
    @NSManaged var searchTerm: String?
    @NSManaged var prefix: String?
    @NSManaged var tweets: NSSet?

}
