//
//  MDFichaTecnicaCellChildDataSource.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 16-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDFichaTecnicaCellChildDataSource: NSObject , UICollectionViewDataSource  {
    
    var data : Array<MDProductTechnicalData>!
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let titleCell : TitleCollectionViewCell = collectionView .dequeueReusableCell( withReuseIdentifier: "TitleCellIdentifier", for: indexPath as IndexPath) as! TitleCollectionViewCell
            titleCell.dateLabel.textColor = COLOR_BLUE_DARK
            let border = CALayer()
            let with = CGFloat(1.0)
            border.borderColor = UIColor.groupTableViewBackground.cgColor
            border.frame = CGRect(x:0, y: titleCell.frame.size.height - with, width: titleCell.frame.size.width, height: titleCell.frame.size.height)
            border.borderWidth = with
            titleCell.layer.addSublayer(border)
            titleCell.layer.masksToBounds = true
            titleCell.dateLabel.text = data[indexPath.section].featureKey
            return titleCell
        } else {
            let contentCell : ContentCollectionViewCell = collectionView .dequeueReusableCell(withReuseIdentifier: "ContentCellIdentifier", for: indexPath as IndexPath) as! ContentCollectionViewCell
            
            let border = CALayer()
            let with = CGFloat(1.0)
            border.borderColor = UIColor.groupTableViewBackground.cgColor
            border.frame = CGRect(x:0, y: contentCell.frame.size.height - with, width: contentCell.frame.size.width-50, height: contentCell.frame.size.height)
            border.borderWidth = with
            contentCell.layer.addSublayer(border)
            contentCell.layer.masksToBounds = true
            contentCell.contentLabel.text = data[indexPath.section].featureValue
            return contentCell
        }
        
    }
}
