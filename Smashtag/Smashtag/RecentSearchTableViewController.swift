//
//  RecentSearchTableViewController.swift
//  
//
//  Created by hyf on 16/10/31.
//
//

import UIKit
import CoreData

class RecentSearchTableViewController: UITableViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return RecentSearch.recentSearch.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = RecentSearch.recentSearch[indexPath.row]
        
        return cell
    }
 
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            RecentSearch.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    private struct Storyboard {
        static let ShowMentionDetailSegueIdentifier = "show mention detail"
        static let SearchMentionAgainSegueIdentifier = "search mention again"
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Storyboard.SearchMentionAgainSegueIdentifier {
            if let destination = segue.destinationViewController as? TweetTableViewController {
                if let cell = sender as? UITableViewCell {
                    destination.searchText = cell.textLabel?.text
                }
            }
        }
        if segue.identifier == Storyboard.ShowMentionDetailSegueIdentifier {
            if let tweetersTVC = segue.destinationViewController as? TweetersTableViewController {
                if let cell = sender as? UITableViewCell {
                    tweetersTVC.searchTerm = cell.textLabel?.text
                }
                 let managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
                tweetersTVC.managedObjectContext = managedObjectContext
            }
            
        }

    }

    
    

}
