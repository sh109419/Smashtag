//
//  TweetersTableViewController.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class TweetersTableViewController: CoreDataTableViewController {
    var searchTerm: String? { didSet { title = searchTerm } }
    var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() } }
    
    fileprivate func updateUI() {
        if let context = managedObjectContext, searchTerm?.characters.count > 0 {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Mention")
            request.predicate = NSPredicate(format: "searchTerm =[c] %@ and tweetCount > 1", searchTerm!)
            let tweetCountSort = NSSortDescriptor(
                key: "tweetCount",
                ascending: false
            )
            let tweetMentionSort = NSSortDescriptor(
                key: "keyWordWithoutPrefix",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
            )
            // for section
            let tweetPrefixSort = NSSortDescriptor(
                key: "prefix",
                ascending: false
            )

            request.sortDescriptors = [tweetPrefixSort, tweetCountSort, tweetMentionSort]
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: "prefix",
                cacheName: nil
            )
        } else {
            fetchedResultsController = nil
        }
    }
    
    // this is the only UIableViewDataSource method we have to implement
    // if we use a CoreDataTAbleViewController
    // the most important call is fetchedResultsController?.objectAtIndexPath(indexPath)
    // (that's how we get the object that is in this row so we can load the cell up)
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MentionCell", for: indexPath)
        if let tweetMention = fetchedResultsController?.object(at: indexPath) as? Mention {
            var mention: String?
            var count: Int?
            tweetMention.managedObjectContext?.performAndWait {
                mention = tweetMention.keyWord! + tweetMention.prefix!
                count = tweetMention.tweetCount?.intValue
            }
            cell.textLabel?.text = mention
            if let count = count {
                cell.detailTextLabel?.text = "\(count) tweets"
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            if sections[section].name == "#" {
                return "Hashtags"
            }
            return "Users"
        } else {
            return nil
        }
    }

  
}
