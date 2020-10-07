//
//  CollectionViewFlowLayout.swift
//  iOSBrowser
//
//  Created by NINAYA-BLRM20 on 09/09/20.
//  Copyright © 2020 NINAYA-BLRM20. All rights reserved.
//

import UIKit

let RotateDegree = -60.0

class CollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var contentSize: CGSize?
    var itemGap: CGFloat?
    var attributes: [UICollectionViewLayoutAttributes] = []
    var pannedIndexpath: IndexPath?
    var pannedStartPoint: CGPoint?
    var pannedUpdatePoint: CGPoint?
    
    override var collectionViewContentSize: CGSize {
        return self.contentSize ?? CGSize(width: 0, height: 0)
    }
    
    override func prepare() {
        super.prepare()
        
        self.itemGap = CGFloat(round(self.collectionView!.frame.size.height * 0.2))
        var top = CGFloat(0.0)
        let left = CGFloat(6.0)
        let width = CGFloat(round(self.collectionView!.frame.size.width - 2*left))
        let height = CGFloat(round((self.collectionView!.frame.size.height/self.collectionView!.frame.size.width) * width))
        
        let itemsCount = self.collectionView?.numberOfItems(inSection: 0)
        self.attributes = []
        for item in 0 ..< itemsCount!{
            let indexpath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexpath)
            
            if let cell = self.collectionView?.cellForItem(at: IndexPath(row: item, section: 0)) as? BrowserCollectionViewCell {
                cell.navBarHeightConstraint.constant = 0
                cell.topViewHeightConstraint.constant = 20.0
                cell.searchBar.isUserInteractionEnabled = false
                cell.webView.isUserInteractionEnabled = false
                cell.layer.cornerRadius = 15.0
                cell.layer.borderWidth = 1.0
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.cellDeleteButton.isHidden = false
            }
            
            var frame = CGRect(x: left, y: top, width: width, height: height)
            attributes.frame = frame
            attributes.zIndex = item
            
            var angleOfRotation = CGFloat(-61.0)
            var frameOffset = self.collectionView!.contentOffset.y - frame.origin.y - floor(self.collectionView!.frame.size.height/10.0)
            if (frameOffset > 0) {
                // make the cell at the top fall away
                frameOffset = frameOffset/5.0;
                frameOffset = min(frameOffset, 30.0);
                angleOfRotation += frameOffset;
            }
            let rotation = CATransform3DMakeRotation(CGFloat((Double.pi * Double(angleOfRotation)/180.0)), 1.0, 0.0, 0.0)

            // perspective
            let depth = 400.0
            let translateDown = CATransform3DMakeTranslation(0.0, -150.0, CGFloat(-depth))
            let translateUp = CATransform3DMakeTranslation(0.0, 0.0, CGFloat(depth))
            var scale = CATransform3DIdentity
            scale.m34 = -1.0/1500.0;
            let perspective =  CATransform3DConcat(CATransform3DConcat(translateDown, scale), translateUp)

            // final transform
            let transform = CATransform3DConcat(rotation, perspective)
            
            var gap = self.itemGap
            
            if let indexpath = self.pannedIndexpath, item == indexpath.item {
                let dx = max((self.pannedStartPoint?.x ?? 0) - (self.pannedUpdatePoint?.x ?? 0), 0.0)
                frame.origin.x -= dx
                attributes.frame = frame
                attributes.alpha = max(1.0 - dx/width, 0)
                
                gap = attributes.alpha * (self.itemGap ?? 0)
            }
            
            attributes.transform3D = transform
            
            self.attributes.append(attributes)
            
            top += gap!
        }
        if (self.attributes.count > 0) {
            let lastItemAttributes = self.attributes.last
            self.contentSize = CGSize(width: self.collectionView!.frame.size.width, height: (lastItemAttributes?.frame.origin.y)! + (lastItemAttributes?.frame.size.height)!)
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let cell = self.collectionView?.cellForItem(at: indexPath) as? BrowserCollectionViewCell {
            cell.navBarHeightConstraint.constant = 0
            cell.topViewHeightConstraint.constant = 20.0
            cell.searchBar.isUserInteractionEnabled = false
            cell.webView.isUserInteractionEnabled = false
            cell.layer.cornerRadius = 15.0
            cell.layer.borderWidth = 1.0
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.cellDeleteButton.isHidden = false
        }
        return self.attributes[indexPath.row]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var array = [UICollectionViewLayoutAttributes]()
        for attribute in self.attributes {
            if (attribute.frame.intersects(rect)) {
                array.append(attribute)
            }
        }
        return array
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.attributes[itemIndexPath.item]
    }
}
