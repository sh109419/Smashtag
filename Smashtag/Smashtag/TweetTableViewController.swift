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
    fileprivate var tweets = [Array<Twitter.Tweet>]() {// array of array of tweet // [tweet]
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            guard let text = searchText, !text.isEmpty else {
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
    fileprivate struct Constants {
        static let numberOfTweets = 100
    }
   
    // MARK: Fetching Tweets
    fileprivate var twitterRequest: Twitter.Request? {
        if lastTwitterRequest == nil {
            if let query = searchText, !query.isEmpty {
                //return Twitter.Request(search: query + " -filter:retweets", count: Constants.numberOfTweets)
                //When you click on a user in the Users section, search not only for Tweets that mention that user, but also for Tweets which were posted by that user.
                //https://twitter.com/search-home#
                var searchKeyword = query
                if query.hasPrefix("@") {
                    searchKeyword = query.trimmingCharacters(in: CharacterSet(charactersIn: "@"))
                    searchKeyword = "from:\(searchKeyword) OR \(query)"
                    //print(searchKeyword)
                }
                return Twitter.Request(search: searchKeyword + " -filter:retweets", count: Constants.numberOfTweets)
            }
        }
        return lastTwitterRequest?.newer
        
    }
    
    fileprivate var lastTwitterRequest: Twitter.Request?
    
    fileprivate func searchForTweets() {
        if let request = twitterRequest {
            refreshControl?.beginRefreshing()
            lastTwitterRequest = request
            request.fetchTweets { [weak weakSelf = self] newTweets in
                DispatchQueue.main.async {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, at: 0)
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
    fileprivate func updateDatabase(_ newTweets: [Twitter.Tweet]) {
        let managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.document.managedObjectContext
        managedObjectContext?.perform {
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

    fileprivate func printDatabaseStatistics() {
        let managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.document.managedObjectContext
        //managedObjectContext?.performBlock {
            if let results = try? managedObjectContext!.fetch(NSFetchRequest(entityName: "Mention")) {
                print("\(results.count) TwitterMentions")
            }
        do {
            if let tweetCount = try managedObjectContext!.count(for: NSFetchRequest(entityName: "Tweet")) as Int? {
               print("\(tweetCount) Tweets")
            }
        } catch let error as NSError {
                print(error)
            }
        
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
       // }
    }
    
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TweetCellIdentifier, for: indexPath)

        // Configure the cell...
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        return cell
    }
    
    // MARK: constants
    fileprivate struct Storyboard {
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
    }

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
               
        if segue.identifier == Storyboard.MentionsSegueIdentifier {
            if let destination = segue.destination as? MentionsTableViewController {
                if let cell = sender as? TweetTableViewCell {
                    destination.tweet = cell.tweet
                }
            }

        }
        if segue.identifier == Storyboard.ImagesSegueIdentifier {
            if let destination = segue.destination as? MediaCollectionViewController{
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
