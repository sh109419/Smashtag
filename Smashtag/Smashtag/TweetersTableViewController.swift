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
    var mention: String? { didSet { updateUI() } }
    var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() } }
    
    private func updateUI() {
        if let context = managedObjectContext where mention?.characters.count > 0 {
            let request = NSFetchRequest(entityName: "TwitterUser")
            request.predicate = NSPredicate(format: "any tweets.text contains[c] %@ and !screenName beginswith[c] %@", mention!, "darkside")
            let tweetCountSort = NSSortDescriptor(
                key: "tweetCount",
                ascending: false
            )
            let tweetUserSort = NSSortDescriptor(
                key: "screenName",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
            )
            request.sortDescriptors = [tweetCountSort, tweetUserSort]
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            //fetchResults.allObjects.sort({ $0.displayOrder.integerValue > $1.displayOrder.integerValue })
           // fetchedResultsController?.fetchedObjects!.sort({$0.tweet.count})
           // sortedArrayUsingDescriptor
            
        } else {
            fetchedResultsController = nil
        }
    }
    
    // this is the only UIableViewDataSource method we have to implement
    // if we use a CoreDataTAbleViewController
    // the most important call is fetchedResultsController?.objectAtIndexPath(indexPath)
    // (that's how we get the object that is in this row so we can load the cell up)
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TwitterUserCell", forIndexPath: indexPath)
        if let twitterUser = fetchedResultsController?.objectAtIndexPath(indexPath) as? TwitterUser {
            var screenName: String?
            twitterUser.managedObjectContext?.performBlockAndWait {
                // it's easy to forget to do this on the proper queue
                screenName = twitterUser.screenName
                // we're not assuming the context is a main queue context
                // so we'll grab the screenName and return to the main queue
                // to do the cell.textLabel?.text setting
            }
            cell.textLabel?.text = screenName
            if let count = tweetCountWithMentionByTwitterUser(twitterUser) {
                cell.detailTextLabel?.text = (count == 1) ? "1 tweet" : "\(count) tweets"
            } else {
                cell.detailTextLabel?.text = ""
            }
            cell.detailTextLabel?.text = (cell.detailTextLabel?.text)! + "\(twitterUser.tweetCount)"
        }
        return cell
    }
    
    // private func which figures out how many tweets
    // were tweeted by the given user that contain our mention
    private func tweetCountWithMentionByTwitterUser(user: TwitterUser) -> Int? {
        var count: Int?
        user.managedObjectContext?.performBlockAndWait {
            let request = NSFetchRequest(entityName: "Tweet")
            request.predicate = NSPredicate(format: "text contains[c] %@ and tweeter = %@", self.mention!, user)
            count = user.managedObjectContext?.countForFetchRequest(request, error: nil)
        }
        return count
    }
}