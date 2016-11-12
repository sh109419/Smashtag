//
//  MediaCollectionViewCell.swift
//  Smashtag
//
//  Created by hyf on 16/11/4.
//  Copyright © 2016年 hyf. All rights reserved.
//

import UIKit
import Twitter

class MediaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var mediaItem: Twitter.MediaItem? {
        didSet {
            //updateUI()
            imageView?.image = nil
            ImageCache.sharedInstance.getImageByURL(mediaItem!.url) {
                (image: UIImage?) in self.imageView.image = image
            }
        }
    }
    
}
