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
    
    fileprivate var sections = [Section]()// medias & mentions
    
    fileprivate struct Section {
        var title: String
        var items: [Item]
    }
    
    fileprivate enum Item {
        case media(MediaItem)//(NSURL, Double)
        case mention(String)//(String)
        var data: AnyObject {
            switch self {
            case .media(let media):
                return media as AnyObject
            case .mention(let mention):
                return mention as AnyObject
            }
        }
    }
    
    fileprivate struct SectionTitle {
        static let image = "Images"
        static let hashtag = " Hashtags"
        static let user = "Users"
        static let url = "Urls"
    }
    
    fileprivate func prepareSectionDataset() {
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    fileprivate struct Storyboard {
        static let MentionCellIdentifier = "Mention"
        static let MediaCellIdentifier = "Media"
        // segue
        static let MentionSegueIdentifier = "show search"
        static let MediaSegueIdentifier = "show image"
        static let URLSegueIdentifier = "show url"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemData = sections[indexPath.section].items[indexPath.row].data
        if itemData is Twitter.MediaItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.MediaCellIdentifier, for: indexPath)
            if let mediaCell = cell as? MentionsTableViewCell {
                mediaCell.imageURL = (itemData as? Twitter.MediaItem)?.url
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.MentionCellIdentifier, for: indexPath)
            cell.textLabel?.text = itemData as? String
            return cell
        }
        
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = sections[indexPath.section].items[indexPath.row]
        switch item {
        case .media(let media):
            let currentOrient = UIApplication.shared.statusBarOrientation
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        switch item {
        case .media(_):
            if cell is MentionsTableViewCell {
                if (cell as! MentionsTableViewCell).mediaImageView.image != nil {
                    performSegue(withIdentifier: Storyboard.MediaSegueIdentifier, sender: cell)
                }
            }
        case .mention(let mention):
            if mention.hasPrefix("http") == true {
                performSegue(withIdentifier: Storyboard.URLSegueIdentifier, sender: cell)
            } else {
                performSegue(withIdentifier: Storyboard.MentionSegueIdentifier, sender: cell)
            }
        }
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Storyboard.MentionSegueIdentifier {
            if let destination = segue.destination as? TweetTableViewController {
                if let cell = sender as? UITableViewCell {
                    destination.searchText = cell.textLabel?.text
                }
            }
        }
        if segue.identifier == Storyboard.MediaSegueIdentifier {
            if let destination = segue.destination as? ImageViewController {
                if let cell = sender as? MentionsTableViewCell {
                    destination.image = cell.mediaImageView.image
                    destination.title = cell.imageURL?.absoluteString
                }
            }
        }
        if segue.identifier == Storyboard.URLSegueIdentifier {
            if let destination = segue.destination as? WebViewController {
                if let cell = sender as? UITableViewCell {
                    destination.urlString = cell.textLabel?.text
                }
            }
        }

    }
    

}
