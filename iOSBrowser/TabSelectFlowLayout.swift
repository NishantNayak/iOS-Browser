//
//  TabSelectFlowLayout.swift
//  iOSBrowser
//
//  Created by NINAYA-BLRM20 on 10/09/20.
//  Copyright © 2020 NINAYA-BLRM20. All rights reserved.
//

import UIKit

class TabSelectFlowLayout: UICollectionViewFlowLayout {

    var contentSize: CGSize?
    var attributes: [UICollectionViewLayoutAttributes] = []
    
    override var collectionViewContentSize: CGSize {
        return self.contentSize ?? CGSize(width: 0, height: 0)
    }
    
    override func prepare() {
        super.prepare()
        
        var top = CGFloat(0.0)
        let left = CGFloat(0.0)
        let width = self.collectionView?.frame.size.width ?? 0
        let height = self.collectionView?.frame.size.height ?? 0
        
        let itemsCount = self.collectionView?.numberOfItems(inSection: 0)
        attributes = []
        for item in 0 ..< itemsCount!{
            let indexpath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexpath)
            
            if let cell = self.collectionView?.cellForItem(at: indexpath) as? BrowserCollectionViewCell {
                cell.searchBar.isUserInteractionEnabled = true
                cell.webView.isUserInteractionEnabled = true
                cell.layer.cornerRadius = 0.0
                cell.topViewHeightConstraint.constant = 0.0
                cell.navBarHeightConstraint.constant = 100
                cell.cellDeleteButton.isHidden = true
            }
            
            let frame = CGRect(x: left, y: top, width: width, height: height)
            attributes.frame = frame
            attributes.zIndex = item
            
            self.attributes.append(attributes)
            
            top += height
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
            cell.searchBar.isUserInteractionEnabled = true
            cell.webView.isUserInteractionEnabled = true
            cell.layer.cornerRadius = 0.0
            cell.topViewHeightConstraint.constant = 0.0
            cell.navBarHeightConstraint.constant = 100
            cell.cellDeleteButton.isHidden = true
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
        return array;
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.attributes[itemIndexPath.row]
    }
        
}
