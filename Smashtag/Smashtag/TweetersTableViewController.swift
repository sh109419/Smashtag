//
//  TweetersTableViewController.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class TweetersTableViewController: CoreDataTableViewController {
    var searchTerm: String? { didSet { title = searchTerm } }
    var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() } }
    
    private func updateUI() {
        if let context = managedObjectContext where searchTerm?.characters.count > 0 {
            let request = NSFetchRequest(entityName: "Mention")
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
            request.sortDescriptors = [tweetCountSort, tweetMentionSort]
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MentionCell", forIndexPath: indexPath)
        if let tweetMention = fetchedResultsController?.objectAtIndexPath(indexPath) as? Mention {
            var mention: String?
            var count: Int?
            tweetMention.managedObjectContext?.performBlockAndWait {
                mention = tweetMention.keyWord
                count = tweetMention.tweetCount?.integerValue
            }
            cell.textLabel?.text = mention
            if let count = count {
                cell.detailTextLabel?.text = "\(count) tweets"
            }
        }
        
        return cell
    }
    
}