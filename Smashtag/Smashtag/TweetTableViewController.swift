//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by hyf on 16/10/20.
//  Copyright © 2016年 hyf. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: model
    var tweets = [Array<Twitter.Tweet>]() {// array of array of tweet
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
            searchForTweets()
            title = searchText
            RecentSearch.add(text)
        }
    }
    
    private struct Constants {
        static let numberOfTweets = 100
    }

    private var twitterRequest: Twitter.Request? {
        if let query = searchText where !query.isEmpty {
            //When you click on a user in the Users section, search not only for Tweets that mention that user, but also for Tweets which were posted by that user.
            //https://twitter.com/search-home#
            var searchKeyword = query
            if query.hasPrefix("@") {
                searchKeyword = query.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "@"))
                searchKeyword = "from:\(searchKeyword)  \(query)" // it seems no work, is twitter.app's problem?
            }
            return Twitter.Request(search: searchKeyword + " -filter:retweets", count: Constants.numberOfTweets)
        }
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        if let request = twitterRequest {
            spinner?.startAnimating()
            lastTwitterRequest = request
            request.fetchTweets { [weak weakSelf = self] newTweets in
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, atIndex: 0)
                        }
                    }
                    self.spinner?.stopAnimating()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        view.addSubview(spinner)
        title = "Twitter Search"
        //first run
        if searchTextField.text?.isEmpty == true {
            searchText = RecentSearch.recentSearch.first ?? ""
            searchTextField.text = searchText
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //bounds (max - min) / 2 = mid = center - min
        spinner.center = CGPointMake(view.bounds.midX, view.bounds.midY)
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

    private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
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
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
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
        if let destination = segue.destinationViewController as? MentionsTableViewController {
            if let cell = sender as? TweetTableViewCell {
                destination.tweet = cell.tweet
            }
        }
    }
    

}
