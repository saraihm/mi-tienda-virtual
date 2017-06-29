//
//  MDColorCellChildDataSource.swift
//  Paris GS
//
//  Created by Motion Displays on 01-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

extension UIView {
    
    struct Constants {
        static let ExternalBorderName = "externalBorder"
    }
    
    func addExternalBorder(borderWidth: CGFloat = 2.0, borderColor: UIColor = UIColor.whiteColor(), externalBoderRadius: CGFloat) -> CALayer {
        let externalBorder = CALayer()
        
        externalBorder.frame = CGRectMake(-borderWidth, -borderWidth, frame.size.width + 2 * borderWidth, frame.size.height + 2 * borderWidth)
        externalBorder.cornerRadius = externalBoderRadius;
        externalBorder.borderColor = borderColor.CGColor
        externalBorder.borderWidth = borderWidth
        externalBorder.name = Constants.ExternalBorderName
        
        layer.insertSublayer(externalBorder, atIndex: 0)
        layer.masksToBounds = false
        
        return externalBorder
    }
    
    func removeExternalBorders() {
        layer.sublayers?.filter() { $0.name == Constants.ExternalBorderName }.forEach() {
            $0.removeFromSuperlayer()
        }
    }
    
    func removeExternalBorder(externalBorder: CALayer) {
        guard externalBorder == Constants.ExternalBorderName else { return }
        externalBorder.removeFromSuperlayer()
    }
    
}

class MDColorCellChildDataSource: NSObject, UICollectionViewDataSource  {
  
    var data : NSArray!
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        cell.layer.cornerRadius = 12.5;
       
        cell.removeExternalBorders()
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.borderWidth = 1

        cell.backgroundColor = UIColor.greenColor()
        
        return cell
    }


}

