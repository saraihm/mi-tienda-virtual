//
//  MDColorCellChildViewDelegate.swift
//  Paris GS
//
//  Created by Motion Displays on 01-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDColorCellChildViewDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("select cell no: \(indexPath.row) of collection view: \(collectionView.tag)")
        let currentCell = collectionView.cellForItemAtIndexPath(indexPath)
        currentCell?.layer.borderColor = COLOR_BLUE_LIGHT.CGColor
        currentCell?.layer.borderWidth = 1
        currentCell?.addExternalBorder(6, borderColor: COLOR_BLUE_LIGHT, externalBoderRadius: 18.2)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        print("deselect cell no: \(indexPath.row) of collection view: \(collectionView.tag)")
        let currentCell = collectionView.cellForItemAtIndexPath(indexPath)
        currentCell?.layer.borderColor = UIColor.blackColor().CGColor
        currentCell?.layer.borderWidth = 1
        currentCell?.removeExternalBorders()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(25, 25)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 40
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 18.2, 0, 40);
    }
    


}


