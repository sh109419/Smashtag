//
//  MediaItemsCollectionViewController.swift
//  Smashtag
//
//  Created by hyf on 16/11/4.
//  Copyright © 2016年 hyf. All rights reserved.
//

import UIKit
import Twitter

private let reuseIdentifier = "media cell"

class MediaCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    // MARK: model
    var tweetList = [Tweet]() {
        didSet {
            var index = 0
            for tweet in tweetList {
                for image in tweet.media {
                    imageList.append(TweetMedia(media: image, tweetIndex: index))
                    index += 1
                }
            }
        }
    }
    
    private struct TweetMedia {
        let media: MediaItem
        let tweetIndex: Int
    }
    
    private var imageList = [TweetMedia]()
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        collectionView?.indexPathsForSelectedItems()?.first?.item
        
        if let destination = segue.destinationViewController as? MentionsTableViewController {
            if let selectedIndex = collectionView?.indexPathsForSelectedItems()?.first?.item {
                destination.tweet = tweetList[selectedIndex]
            }
        }
    }
    
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageList.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MediaCollectionViewCell
    
        cell.mediaItem = imageList[indexPath.item].media
    
        return cell
    }
    

    // MARK: UICollectionViewDelegateFlowLayout
    private struct Constants {
        //static let imageMaxLength = 180.0
        static let bigImageCountPerPortraitRow = 2
        static let bigImageCountPerLandScapeRow = 3
        //static let smallImageCountPerPortraitRow = 3
        //static let smallImageCountPerLandScapeRow = 4
    }
    
    private var currentOrient: UIInterfaceOrientation {
        return UIApplication.sharedApplication().statusBarOrientation
    }

    private var imageWidth: CGFloat {
        var count = currentOrient.isLandscape ? Constants.bigImageCountPerLandScapeRow : Constants.bigImageCountPerPortraitRow
        count += isSmallImages ? 1 : 0
        let spacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing
        let offset: CGFloat = 0.1 // without offset, sometimes can not show 3 images in a row, maybe is the problem of 'float calculate'
        
        //print("is landscape \(currentOrient.isLandscape) bounds.size = \(view.bounds.size) count=\(count)")
        /* if orientation changed while showing other form, collectionView() will run
         1. open MediacollectionView at tab "search"
            collectionView() run, status: --is landscape false bounds.size = (414.0, 736.0) count=2
         2. at tab "recents" change orientation
            collectionView() run, status: --is landscape true  bounds.size = (414.0, 736.0) count=3
         
        Note: orientation is from "portrait" to "lnadscape", however bounds.size have not changed
         so, width should be min(width,height) in portrait while be max(width,height) in landscape
        */
        let bounds = collectionView!.bounds
        let calculatedWidth = currentOrient.isLandscape ? max(bounds.width, bounds.height) : min(bounds.width, bounds.height)

        return (calculatedWidth - spacing! * CGFloat(count - 1) - offset) / CGFloat(count)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let ratio = imageList[indexPath.item].media.aspectRatio
        let width = imageWidth
               let height = width / CGFloat(ratio)
        return CGSizeMake(width, height)
    }
    
    // MARK: resize layout
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        //Change UICollectionViewCell size on different device orientations
        coordinator.animateAlongsideTransition(
            { _ in self.collectionView?.performBatchUpdates(nil, completion: nil) },
            completion: nil
        )
    }
    
    // MARK: Scroll view
    // zoom in show less pictures (landscape: 3 Portrait: 2), but the size of each image becomes bigger
    // zoom out show more pictures (landscape: 4 portrait: 3), but the size of each image becomes smaller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(self.changeScale(_:))))
    }
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Ended:
            //updateImagesPerRow(recognizer.scale < 1)
            let showMoreImages = recognizer.scale < 1
            if ((showMoreImages == true) && (isSmallImages == false)) || ((showMoreImages == false) && (isSmallImages == true)) {
                isSmallImages = !isSmallImages
                collectionView?.performBatchUpdates(nil, completion: nil)
            }
            recognizer.scale = 1.0
        default: break
        }
    }
    
    private var isSmallImages = false // show more image means zoom out the image
    
}
