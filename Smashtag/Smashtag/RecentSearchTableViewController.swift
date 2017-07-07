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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return RecentSearch.recentSearch.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = RecentSearch.recentSearch[indexPath.row]
        
        return cell
    }
 
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            RecentSearch.removeAtIndex(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    fileprivate struct Storyboard {
        static let ShowMentionDetailSegueIdentifier = "show mention detail"
        static let SearchMentionAgainSegueIdentifier = "search mention again"
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Storyboard.SearchMentionAgainSegueIdentifier {
            if let destination = segue.destination as? TweetTableViewController {
                if let cell = sender as? UITableViewCell {
                    destination.searchText = cell.textLabel?.text
                }
            }
        }
        if segue.identifier == Storyboard.ShowMentionDetailSegueIdentifier {
            if let tweetersTVC = segue.destination as? TweetersTableViewController {
                if let cell = sender as? UITableViewCell {
                    tweetersTVC.searchTerm = cell.textLabel?.text
                }
                 let managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.document.managedObjectContext
                tweetersTVC.managedObjectContext = managedObjectContext
            }
            
        }

    }

    
    

}
