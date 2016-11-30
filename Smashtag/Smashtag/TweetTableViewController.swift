//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by hyf on 16/10/20.
//  Copyright © 2016年 hyf. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class TweetTableViewController: UITableViewController, UITextFieldDelegate {

    // MARK: model
    private var tweets = [Array<Twitter.Tweet>]() {// array of array of tweet // [tweet]
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            guard let text = searchText where !text.isEmpty else {
                return
            }
            tweets.removeAll()
            lastTwitterRequest = nil
            searchForTweets()
            title = searchText
            RecentSearch.add(text)
        }
    }
    
   
    // MARK: Constants
    private struct Constants {
        static let numberOfTweets = 100
    }
   
    // MARK: Fetching Tweets
    private var twitterRequest: Twitter.Request? {
        if lastTwitterRequest == nil {
            if let query = searchText where !query.isEmpty {
                //return Twitter.Request(search: query + " -filter:retweets", count: Constants.numberOfTweets)
                //When you click on a user in the Users section, search not only for Tweets that mention that user, but also for Tweets which were posted by that user.
                //https://twitter.com/search-home#
                var searchKeyword = query
                if query.hasPrefix("@") {
                    searchKeyword = query.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "@"))
                    searchKeyword = "from:\(searchKeyword) OR \(query)"
                    //print(searchKeyword)
                }
                return Twitter.Request(search: searchKeyword + " -filter:retweets", count: Constants.numberOfTweets)
            }
        }
        return lastTwitterRequest?.requestForNewer
        
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        if let request = twitterRequest {
            refreshControl?.beginRefreshing()
            lastTwitterRequest = request
            request.fetchTweets { [weak weakSelf = self] newTweets in
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, atIndex: 0)
                            weakSelf?.updateDatabase(newTweets)
                        }
                    }
                    self.refreshControl?.endRefreshing()
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    // add the Twitter.Tweets to our database
    private func updateDatabase(newTweets: [Twitter.Tweet]) {
        let managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.document.managedObjectContext
        managedObjectContext?.performBlock {
            for twitterInfo in newTweets {
                _ = Tweet.tweetWithTwitterInfo(self.searchText!, twitterInfo: twitterInfo, inManagedObjectContext: managedObjectContext!)
            }
            do {
                try managedObjectContext?.save()
            } catch let error {
                print("Core Data Error: \(error)")
            }
            self.printDatabaseStatistics()
        }
        //printDatabaseStatistics()
        print("done printing database statistics")
    }

    private func printDatabaseStatistics() {
        let managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.document.managedObjectContext
        //managedObjectContext?.performBlock {
            if let results = try? managedObjectContext!.executeFetchRequest(NSFetchRequest(entityName: "Mention")) {
                print("\(results.count) TwitterMentions")
            }
            let tweetCount = managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "Tweet"), error: nil)
            print("\(tweetCount) Tweets")
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
       // }
    }
    
    
    @IBAction func refresh(sender: UIRefreshControl) {
        searchForTweets()
    }
    
    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        title = "Twitter Search"
        //first run
        if searchTextField.text?.isEmpty == true {
            searchText = RecentSearch.recentSearch.first ?? ""
            searchTextField.text = searchText
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets[section].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetCellIdentifier, forIndexPath: indexPath)

        // Configure the cell...
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        return cell
    }
    
    // MARK: constants
    private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
        static let MentionsSegueIdentifier = "show mentions"
        static let ImagesSegueIdentifier = "show images"
    }

    // MARK: outlets
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    // MARK: UITextFieldDelegte
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
    }

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
               
        if segue.identifier == Storyboard.MentionsSegueIdentifier {
            if let destination = segue.destinationViewController as? MentionsTableViewController {
                if let cell = sender as? TweetTableViewCell {
                    destination.tweet = cell.tweet
                }
            }

        }
        if segue.identifier == Storyboard.ImagesSegueIdentifier {
            if let destination = segue.destinationViewController as? MediaCollectionViewController{
                var tweetList: [Twitter.Tweet] = []
                for tweetByOneUser in tweets {
                    for tweet in tweetByOneUser {
                        if tweet.media.count > 0 {
                            tweetList.append(tweet)
                        }
                    }
                }
                destination.tweetList = tweetList
            }
        }
    }
    

}
