//
//  TwitterUser+CoreDataProperties.swift
//  Smashtag
//
//  Created by hyf on 16/11/21.
//  Copyright © 2016年 hyf. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TwitterUser {

    @NSManaged var name: String?
    @NSManaged var screenName: String?
    @NSManaged var tweetCount: NSNumber?
    @NSManaged var tweets: NSSet?

}
