//
//  ImageCache.swift
//  Smashtag
//
//  Created by hyf on 16/11/10.
//  Copyright © 2016年 hyf. All rights reserved.
//

import UIKit

class ImageCache: NSCache<AnyObject, AnyObject> {
    
    
    
    func getImageByURL(_ url: URL, completion: @escaping (_ image: UIImage?) -> ()) {
        // get from cache
        if let imageData = self.object(forKey: url as AnyObject) as? Data {
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                completion(image)
            }

            return
        }
        // get from network
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            let data = try? Data(contentsOf: url)
            if let imageData = data {
                self.setObject(imageData as AnyObject, forKey: url as AnyObject, cost: imageData.count) // cost is bytes
                //print("\(url.absoluteString) \(imageData.length)")
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    completion(image)
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
