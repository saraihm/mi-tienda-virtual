//
//  MDCollectionViewCellFicha.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 17-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDCollectionViewCellFicha: UICollectionViewCell {
    
    var collectionViewDataSource : UICollectionViewDataSource!
    var collectionViewDelegate : UICollectionViewDelegate!
    var firstTimeFicha = true
    var firstTimeProduct = true
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        
    }
    
    func setCollectionViewDataSourceDelegat(dataSource: UICollectionViewDataSource, delegate :UICollectionViewDelegate, forRow row: Int){
        
        if(self.collectionViewDataSource == nil)
        {
            self.collectionViewDataSource = dataSource
            
            self.collectionViewDelegate = delegate
            collectionView.register(UINib(nibName: "TitleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:  "TitleCellIdentifier")
            collectionView.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ContentCellIdentifier")
            
            collectionView.scrollRectToVisible(CGRect(x:0,y:0,width:1, height:1), animated: true)
            collectionView.scrollsToTop = true
            collectionView.backgroundColor = UIColor.white
            collectionView.dataSource = self.collectionViewDataSource
            collectionView.delegate = self.collectionViewDelegate
            collectionView.tag = row

        }
        
    }
    

    var collectionViewOffset: CGFloat {
        set {
            collectionView.contentOffset.x = newValue
        }
        
        get {
            return collectionView.contentOffset.x
        }
    }
}
