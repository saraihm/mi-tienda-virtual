//
//  MDColorCell.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 29-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

protocol CollectionViewSelectedProtocol: class {
    
    func collectionViewSelected(collectionView: Int, item: Int)
    func collectionViewShowAllProducts(collectionViewItem : Int, moreItems: Bool)
    
}

class MDCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var collectionViewDataSource : UICollectionViewDataSource!
    weak var collectionViewDelegate : UICollectionViewDelegate!
    weak var delegate : CollectionViewSelectedProtocol!
    
    @IBOutlet weak var btShowAll: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        
    }
    
    func setCollectionViewDataSourceDelegate(dataSource: UICollectionViewDataSource, forRow row: Int) {
        
        self.collectionViewDataSource = dataSource
        
        self.collectionViewDelegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(UINib(nibName: "MDProductCell", bundle: nil), forCellWithReuseIdentifier: "productCell")
        
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self.collectionViewDataSource
        collectionView.delegate = self.collectionViewDelegate
        collectionView.tag = row
        collectionView.reloadData()
        
        self.btShowAll.layer.cornerRadius = kCornerRadiusButton
        self.btShowAll.layer.borderColor = COLOR_GRAY_DARK.cgColor
        self.btShowAll.layer.borderWidth = 1
        
        //  self.btShowAll.setTitle("Ver menos", forState: .Selected)
        //  self.btShowAll.setTitleColor(COLOR_GRAY_DARK, forState: .Selected)
        self.btShowAll.setTitle("Ver todos", for: .normal)
    }


    @IBAction func btShowAllAction(_ sender: AnyObject) {
        self.delegate.collectionViewShowAllProducts(collectionViewItem: collectionView.tag, moreItems: true)

      /*  if(self.btShowAll.selected == true)
        {
            self.delegate.collectionViewShowAllProducts(collectionView.tag, moreItems: false)
        }
        else
        {
            self.delegate.collectionViewShowAllProducts(collectionView.tag, moreItems: true)
        }
         */
    }
    var collectionViewOffset: CGFloat {
        set {
            collectionView.contentOffset.x = newValue
        }
        
        get {
            return collectionView.contentOffset.x
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell no: \(indexPath.row) of collection view: \(collectionView.tag)")
        self.delegate.collectionViewSelected(collectionView: collectionView.tag, item: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 205)
    }



}
