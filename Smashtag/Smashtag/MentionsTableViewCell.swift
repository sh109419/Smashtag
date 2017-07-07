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
    
    var imageURL: URL? {
        didSet {
            //updateUI()
            mediaImageView?.image = nil
            spinner?.startAnimating()
            ImageCache.sharedInstance.getImageByURL(imageURL!) {
                (image: UIImage?) in self.mediaImageView.image = image
                self.spinner?.stopAnimating()
            }

        }
    }
    
}
