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

class MediaCollectionViewController: UICollectionViewController{
    
    
    // MARK: model
    var tweetList: [Twitter.Tweet] = [] {
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
    
    fileprivate struct TweetMedia {
        let media: MediaItem
        let tweetIndex: Int
    }
    
    fileprivate var imageList = [TweetMedia]()
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        //collectionView?.indexPathsForSelectedItems?.first?.item
        
        if let destination = segue.destination as? MentionsTableViewController {
            if let selectedIndex = collectionView?.indexPathsForSelectedItems?.first?.item {
                destination.tweet = tweetList[selectedIndex]
            }
        }
    }
    
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MediaCollectionViewCell
        cell.mediaItem = imageList[indexPath.item].media
        return cell
    }
    
    // MARK: resize layout
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //Change UICollectionViewCell size on different device orientations
        coordinator.animate(
            alongsideTransition: { _ in self.refreshLayout(); print("change size") },
            completion: nil
        )
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: Scroll view
        collectionView!.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(self.changeScale(_:))))
        // MARK: photo flow
        if let layout = collectionView?.collectionViewLayout as? ImageFlowViewLayout {
            layout.delegate = self
            layout.numberOfColumns = numberOfColumns
        }
    }
    
    
    // MARK: Scroll view
    // zoom in show less pictures (landscape: 3 Portrait: 2), but the size of each image becomes bigger
    // zoom out show more pictures (landscape: 4 portrait: 3), but the size of each image becomes smaller
    
    func changeScale(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            //updateImagesPerRow(recognizer.scale < 1)
            let showMoreImages = recognizer.scale < 1
            if ((showMoreImages == true) && (isSmallImages == false)) || ((showMoreImages == false) && (isSmallImages == true)) {
                isSmallImages = !isSmallImages
                //collectionView?.performBatchUpdates(nil, completion: nil)
                //collectionView?.reloadData()
                refreshLayout()
            }
            recognizer.scale = 1.0
        default: break
        }
    }
    
    fileprivate var isSmallImages = false // show more image means zoom out the image
    
    fileprivate func refreshLayout() {
        (collectionViewLayout as? ImageFlowViewLayout)?.numberOfColumns = numberOfColumns
        collectionView?.reloadData()
    }
    
    fileprivate struct Constants {
        //static let imageMaxLength = 180.0
        static let bigImageCountPerPortraitRow = 2
        static let bigImageCountPerLandScapeRow = 3
        //static let smallImageCountPerPortraitRow = 3
        //static let smallImageCountPerLandScapeRow = 4
    }
    
    // how many images per row
    fileprivate var numberOfColumns: Int {
        let currentOrient = UIApplication.shared.statusBarOrientation
        var count = currentOrient.isLandscape ? Constants.bigImageCountPerLandScapeRow : Constants.bigImageCountPerPortraitRow
        count += isSmallImages ? 1 : 0
        return count
    }

}

// MARK: image flow
extension MediaCollectionViewController: ImageFlowViewLayoutDelegate {
    
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath,
                        withWidth width: CGFloat) -> CGFloat {
        let ratio = imageList[indexPath.item].media.aspectRatio
        let height = width / CGFloat(ratio)
        return height
    }
    
}
