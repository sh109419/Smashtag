//
//  ImageCache.swift
//  Smashtag
//
//  Created by hyf on 16/11/10.
//  Copyright © 2016年 hyf. All rights reserved.
//

import UIKit

class ImageCache: NSCache {
    
    
    
    func getImageByURL(url: NSURL, completion: (image: UIImage?) -> ()) {
        // get from cache
        if let imageData = self.objectForKey(url) as? NSData {
            let image = UIImage(data: imageData)
            dispatch_async(dispatch_get_main_queue()) {
                completion(image: image)
            }

            return
        }
        // get from network
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            let data = NSData(contentsOfURL: url)
            if let imageData = data {
                self.setObject(imageData, forKey: url, cost: imageData.length) // cost is bytes
                //print("\(url.absoluteString) \(imageData.length)")
                let image = UIImage(data: imageData)
                dispatch_async(dispatch_get_main_queue()) {
                    completion(image: image)
                }
            }
        }
        
    }
    
}

//Singleton
extension ImageCache {
    class var sharedInstance : ImageCache {
        struct Static {
            static let instance : ImageCache = ImageCache()
        }
        //Static.instance.countLimit = 100
        Static.instance.totalCostLimit = 100 * 1024 * 1024 * 3 // cache 100 images which each size is 3MB
        return Static.instance
    }
}