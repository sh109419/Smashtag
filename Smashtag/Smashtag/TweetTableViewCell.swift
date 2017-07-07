//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by hyf on 16/10/20.
//  Copyright © 2016年 hyf. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    fileprivate func updateUI()
    {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet
        {
            tweetTextLabel?.text = tweet.text
            if tweetTextLabel?.text != nil  {
                for _ in tweet.media {
                    tweetTextLabel.text! += " 📷"
                }
                //Enhance Smashtag from lecture to highlight (in a different color for each) hashtags, 
                //urls and user screen names mentioned in the text of each Tweet
                //tweetTextLabel.attributedText = attributedString(tweet, string: tweetTextLabel.text!)
                tweetTextLabel?.attributedText  = getColorfulAttributedText(tweet, plainText: tweetTextLabel.text!)
            }
            
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
            
            if let profileImageURL = tweet.user.profileImageURL {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                    let imageData = try? Data(contentsOf: profileImageURL)
                    DispatchQueue.main.async {
                        if profileImageURL == self.tweet?.user.profileImageURL {
                            if imageData != nil {
                                self.tweetProfileImageView?.image = UIImage(data: imageData!)
                            }
                        }
                    }
                    
                }
            }
            
                
            let formatter = DateFormatter()
            if Date().timeIntervalSince(tweet.created) > 24*60*60 {
                formatter.dateStyle = DateFormatter.Style.short
            } else {
                formatter.timeStyle = DateFormatter.Style.short
            }
            tweetCreatedLabel?.text = formatter.string(from: tweet.created)
        }
        
    }
    
    fileprivate struct MentionColor {
        static let user = UIColor.purple
        static let hashtag = UIColor.brown
        static let url = UIColor.blue
    }

    /*
     
    tweetTextLabel.attributedText = attributedString(tweet, string: tweetTextLabel.text!)
     
    private struct AttributedItem {
        var range: NSRange
        var color: UIColor
    }
    
    private func attributedString(tweet: Twitter.Tweet, string: String) -> NSAttributedString {
        var attributedList = [AttributedItem]()
        var attributedItems = [AttributedItem]()
        // user mention
        attributedItems = tweet.userMentions.map { (mention: Mention) -> AttributedItem in
            return AttributedItem(range: mention.nsrange,color: UIColor.purpleColor())
        }
        attributedList += attributedItems
        // urls
        attributedItems = tweet.urls.map { (mention: Mention) -> AttributedItem in
            return AttributedItem(range: mention.nsrange,color: UIColor.blueColor())
        }
        attributedList += attributedItems
        // hashtags
        attributedItems = tweet.hashtags.map { (mention: Mention) -> AttributedItem in
            return AttributedItem(range: mention.nsrange,color: UIColor.brownColor())
        }
        attributedList += attributedItems
        
        let attributedString = NSMutableAttributedString(string: string)
        for item in attributedList {
            attributedString.addAttribute(NSForegroundColorAttributeName, value: item.color, range: item.range)
        }
        return attributedString
    }
*/
    
    fileprivate func getColorfulAttributedText(_ tweet: Twitter.Tweet, plainText: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: plainText)
        attributedString.setMentionsColor(tweet.userMentions, color: MentionColor.user)
        attributedString.setMentionsColor(tweet.hashtags, color: MentionColor.hashtag)
        attributedString.setMentionsColor(tweet.urls, color: MentionColor.url)
        return attributedString
    }
}

private extension NSMutableAttributedString {
    func setMentionsColor(_ mentions: [Twitter.Mention], color: UIColor) {
        for mention in mentions {
            addAttribute(NSForegroundColorAttributeName, value: color, range: mention.nsrange)
        }
    }
}
