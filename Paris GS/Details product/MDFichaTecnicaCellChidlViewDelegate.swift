//
//  MDFichaTecnicaCellChidlViewDelegate.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 16-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDFichaTecnicaCellChidlViewDelegate: NSObject, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        if(indexPath.row != 0)
        {
            let index = IndexPath.init(row: indexPath.row-1, section: indexPath.section)
            let currentCell = collectionView.cellForItem(at: indexPath as IndexPath)  as! ContentCollectionViewCell
            let currentCellTitle = collectionView.cellForItem(at: index)  as! TitleCollectionViewCell
            
            let descriptionLongPopUp = MDPopUpDescriptionViewController()
            descriptionLongPopUp.modalPresentationStyle = .overCurrentContext
            descriptionLongPopUp.modalTransitionStyle = .crossDissolve
            descriptionLongPopUp.descriptionLong = currentCell.contentLabel.text
            descriptionLongPopUp.titleDescription = currentCellTitle.dateLabel.text
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.navigationController.present(descriptionLongPopUp, animated: true, completion: nil)

        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return true
    }
}
