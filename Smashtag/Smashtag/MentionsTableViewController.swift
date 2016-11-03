//
//  MentionTableViewController.swift
//  Smashtag
//
//  Created by hyf on 16/10/21.
//  Copyright © 2016年 hyf. All rights reserved.
//

import UIKit
import Twitter

class MentionsTableViewController: UITableViewController {
    
    // MARK: model
    var tweet: Twitter.Tweet? {
        didSet {
            title = tweet?.user.screenName
            prepareSectionDataset()
            tableView.reloadData()
        }
    }
    
    private var sections = [Section]()// medias & mentions
    
    private struct Section {
        var title: String
        var items: [Item]
    }
    
    private enum Item {
        case media(MediaItem)//(NSURL, Double)
        case mention(String)//(String)
        var data: AnyObject {
            switch self {
            case .media(let media):
                return media
            case .mention(let mention):
                return mention
            }
        }
    }
    
    private struct SectionTitle {
        static let image = "Images"
        static let hashtag = " Hashtags"
        static let user = "Users"
        static let url = "Urls"
    }
    
    private func prepareSectionDataset() {
        if let tweet = self.tweet {
            if tweet.media.count > 0 {
                sections.append(Section(title: SectionTitle.image, items: tweet.media.map {Item.media($0)} ))
            }
            if tweet.hashtags.count > 0 {
                sections.append(Section(title: SectionTitle.hashtag ,items: tweet.hashtags.map {Item.mention($0.keyword)} ))
            }
            // users include user & usermentions
            var userItems: [Item] = [Item.mention("@" + tweet.user.screenName)]
            if tweet.userMentions.count > 0 {
                userItems += tweet.userMentions.map { Item.mention($0.keyword) }
            }
            sections.append(Section(title: SectionTitle.user, items: userItems ))
            
            if tweet.urls.count > 0 {
                sections.append(Section(title: SectionTitle.url, items: tweet.urls.map {Item.mention($0.keyword)} ))
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sections[section].items.count
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    private struct Storyboard {
        static let MentionCellIdentifier = "Mention"
        static let MediaCellIdentifier = "Media"
        // segue
        static let MentionSegueIdentifier = "show search"
        static let MediaSegueIdentifier = "show image"
        static let URLSegueIdentifier = "show url"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let itemData = sections[indexPath.section].items[indexPath.row].data
        if itemData is Twitter.MediaItem {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MediaCellIdentifier, forIndexPath: indexPath)
            if let mediaCell = cell as? MentionsTableViewCell {
                mediaCell.imageURL = (itemData as? Twitter.MediaItem)?.url
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MentionCellIdentifier, forIndexPath: indexPath)
            cell.textLabel?.text = itemData as? String
            return cell
        }
        
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item = sections[indexPath.section].items[indexPath.row]
        switch item {
        case .media(let media):
            let currentOrient = UIApplication.sharedApplication().statusBarOrientation
            if currentOrient.isLandscape == true {
                //Get frame height without navigation bar height and tab bar height 
                let tabBarHeight = self.tabBarController?.tabBar.frame.size.height ?? 0.0
                return tableView.bounds.maxY - tableView.sectionHeaderHeight - tabBarHeight //UIApplication.sharedApplication().statusBarFrame.height
            } else {
                return tableView.bounds.width / CGFloat(media.aspectRatio)
            }
        case .mention(_):
            return UITableViewAutomaticDimension
        }
    }
    
    // navigation from table
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        switch item {
        case .media(_):
            if cell is MentionsTableViewCell {
                if (cell as! MentionsTableViewCell).mediaImageView.image != nil {
                    performSegueWithIdentifier(Storyboard.MediaSegueIdentifier, sender: cell)
                }
            }
        case .mention(let mention):
            if mention.hasPrefix("http") == true {
                performSegueWithIdentifier(Storyboard.URLSegueIdentifier, sender: cell)
            } else {
                performSegueWithIdentifier(Storyboard.MentionSegueIdentifier, sender: cell)
            }
        }
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Storyboard.MentionSegueIdentifier {
            if let destination = segue.destinationViewController as? TweetTableViewController {
                if let cell = sender as? UITableViewCell {
                    destination.searchText = cell.textLabel?.text
                }
            }
        }
        if segue.identifier == Storyboard.MediaSegueIdentifier {
            if let destination = segue.destinationViewController as? ImageViewController {
                if let cell = sender as? MentionsTableViewCell {
                    destination.image = cell.mediaImageView.image
                    destination.title = cell.imageURL?.absoluteString
                }
            }
        }
        if segue.identifier == Storyboard.URLSegueIdentifier {
            if let destination = segue.destinationViewController as? WebViewController {
                if let cell = sender as? UITableViewCell {
                    destination.urlString = cell.textLabel?.text
                }
            }
        }

    }
    

}
