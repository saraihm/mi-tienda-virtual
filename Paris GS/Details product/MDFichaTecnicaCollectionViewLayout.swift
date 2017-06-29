//
//  MDFichaTecnicaCollectionViewLayout.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 16-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDFichaTecnicaCollectionViewLayout: UICollectionViewLayout {
    let numberOfColumns = 2
    var itemAttributes : NSMutableArray!
    var itemsSize : NSMutableArray!
    var contentSize = CGSize()
    
    override func prepare() {
        if(self.itemAttributes != nil){
           self.itemAttributes.removeAllObjects()
            itemsSize.removeAllObjects()
            contentSize = CGSize()
        }
        
        if self.collectionView?.numberOfSections == 0 {
            return
        }
        
        if (self.itemAttributes != nil && self.itemAttributes.count > 0) {
            for section in 0..<self.collectionView!.numberOfSections {
                let numberOfItems : Int = self.collectionView!.numberOfItems(inSection: section)
                for index in 0..<numberOfItems {
                    if section != 0 && index != 0 {
                        continue
                    }
                    
                    let attributes : UICollectionViewLayoutAttributes = self.layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath(item: index, section: section))!
                    if section == 0 {
                        var frame = attributes.frame
                        frame.origin.y = self.collectionView!.contentOffset.y
                        attributes.frame = frame
                    }
                    
                    if index == 0 {
                        var frame = attributes.frame
                        frame.origin.x = self.collectionView!.contentOffset.x
                        attributes.frame = frame
                    }
                }
            }
            return
        }
        
        if (self.itemsSize == nil || self.itemsSize.count != numberOfColumns) {
            self.calculateItemsSize()
        }
        
        var column = 0
        var xOffset : CGFloat = 0
        var yOffset : CGFloat = 0
        var contentWidth : CGFloat = 0
        var contentHeight : CGFloat = 0
        
        for section in 0..<self.collectionView!.numberOfSections {
            let sectionAttributes = NSMutableArray()
            
            for index in 0..<numberOfColumns {
                let itemSize = (self.itemsSize[index] as AnyObject).cgSizeValue
                let indexPath = NSIndexPath(item: index, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath as IndexPath)
                attributes.frame = CGRect(x:xOffset, y:yOffset, width:(itemSize?.width)!, height:(itemSize?.height)!).integral
                
                if section == 0 && index == 0 {
                    attributes.zIndex = 1024;
                } else  if section == 0 || index == 0 {
                    attributes.zIndex = 1023
                }
                
                if section == 0 {
                    var frame = attributes.frame
                    frame.origin.y = self.collectionView!.contentOffset.y
                    attributes.frame = frame
                }
                if index == 0 {
                    var frame = attributes.frame
                    frame.origin.x = self.collectionView!.contentOffset.x
                    attributes.frame = frame
                }
                
                sectionAttributes.add(attributes)
                
                xOffset += (itemSize?.width)!
                column += 1
                
                if column == numberOfColumns {
                    if xOffset > contentWidth {
                        contentWidth = xOffset
                    }
                    
                    column = 0
                    xOffset = 0
                    yOffset += (itemSize?.height)!
                }
            }
            if (self.itemAttributes == nil) {
                self.itemAttributes = NSMutableArray(capacity: self.collectionView!.numberOfSections)
            }
            self.itemAttributes .add(sectionAttributes)
        }
        
        let attributes : UICollectionViewLayoutAttributes = (self.itemAttributes.lastObject as! NSMutableArray).lastObject as! UICollectionViewLayoutAttributes
        contentHeight = attributes.frame.origin.y + attributes.frame.size.height
        self.contentSize = CGSize(width:contentWidth, height:contentHeight)
    }
    
    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }

    
    func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let array = self.itemAttributes.object(at: indexPath.section) as! NSArray
        return array.object(at: indexPath.row) as? UICollectionViewLayoutAttributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        if self.itemAttributes != nil {
            for section in self.itemAttributes {
                
                let filteredArray  =  (section as! NSMutableArray).filtered(
                    
                    using: NSPredicate(block: { (evaluatedObject, bindings) -> Bool in
                        return rect.intersects((evaluatedObject! as! UICollectionViewLayoutAttributes).frame)
                    })
                    ) as! [UICollectionViewLayoutAttributes]
                
                
                attributes.append(contentsOf: filteredArray)
            }
        }
        
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
    
    func sizeForItemWithColumnIndex(columnIndex: Int) -> CGSize {
        if(columnIndex == 0)
        {
            return CGSize(width:UIScreen.main.bounds.width/4-30, height:50)
        }
        
        return CGSize(width:UIScreen.main.bounds.width/4, height:50)
    }
    
    func calculateItemsSize() {
        self.itemsSize = NSMutableArray(capacity: numberOfColumns)
        for index in 0..<numberOfColumns {
            self.itemsSize.add(NSValue(cgSize: self.sizeForItemWithColumnIndex(columnIndex: index)))
        }
    }

}
