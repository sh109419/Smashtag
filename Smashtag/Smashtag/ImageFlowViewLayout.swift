//
//  WaterfallCollectionViewLayout.swift
//  Smashtag
//
//  Created by hyf on 16/11/13.
//  Copyright © 2016年 hyf. All rights reserved.
//

// Variable Height of a UICollectionViewCell Depending on Data

import UIKit

protocol ImageFlowViewLayoutDelegate {
    // all images with same width
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth: CGFloat) -> CGFloat
}

class ImageFlowViewLayout: UICollectionViewLayout {
 
    // MARK: properties
    var delegate: ImageFlowViewLayoutDelegate!
    var numberOfColumns = 2 {
        didSet {
            collectionViewlayoutAttributes.removeAll()
            contentHeight = 0.0
        }
    }
    var cellPadding: CGFloat = 6.0
    
    private var collectionViewlayoutAttributes = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat  = 0.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
    }
    
    // MARK: methods
    
    override func prepareLayout() {
        // do it when attributes is empty
        if collectionViewlayoutAttributes.isEmpty {
            // get column width, all images with the same width
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth )
            }
            
            // set yOffset to zero for the 1st row
            var yOffset = [CGFloat](count: numberOfColumns, repeatedValue: 0)
            
            // only one section
            var column = 0
            for item in 0 ..< collectionView!.numberOfItemsInSection(0) {
                
                let indexPath = NSIndexPath(forItem: item, inSection: 0)
                
                let photoWidth = columnWidth - cellPadding * 2
                let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath,
                                                          withWidth: photoWidth)
                let height = photoHeight + cellPadding * 2  // cell (columnWidth, height)
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.frame = insetFrame
                collectionViewlayoutAttributes.append(attributes)
                
                contentHeight = max(contentHeight, CGRectGetMaxY(frame))
                yOffset[column] = yOffset[column] + height
                
                // select the 1st columm whose yOffset is min
                var minY = yOffset[column]
                for col in 0..<numberOfColumns {
                    if yOffset[col] < minY {
                        minY = yOffset[col]
                        column = col
                    }
                }
            }
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in collectionViewlayoutAttributes {
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
}