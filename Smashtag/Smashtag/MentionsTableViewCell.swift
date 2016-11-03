//
//  MentionTableViewCell.swift
//  Smashtag
//
//  Created by hyf on 16/10/21.
//  Copyright © 2016年 hyf. All rights reserved.
//

import UIKit
import Twitter

class MentionsTableViewCell: UITableViewCell {

    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageURL: NSURL? {
        didSet {
            updateUI()
        }
    }
    
    
    private func updateUI()
    {
        // reset any existing tweet information
        mediaImageView?.image = nil
        if let url = imageURL {
            spinner?.startAnimating()
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                let imageData = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) {
                    if url == self.imageURL {
                        if imageData != nil {
                            self.mediaImageView?.image = UIImage(data: imageData!)
                        }
                    }
                    self.spinner?.stopAnimating()
                }
            }
        }
    }
    
    
    
}
