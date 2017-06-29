//
//  MDProductCellChildDataSource.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 02-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDProductCellChildDataSource: NSObject, UICollectionViewDataSource  {
    
    var data: Array<MDProduct>!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {()
        return data.count
    }
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath as IndexPath) as! MDProductCell
        cell.imgLeftConstraint.constant = 28
        cell.imgRightConstraint.constant = 28
        cell.layoutIfNeeded()
        cell.imgHeightConstraint.constant = cell.imgProduct.frame.size.width
        cell.descriptionLeftConstraint.constant = 5
        cell.descriptionRightConstraint.constant = 5
        cell.lbDescription.font = UIFont.init(name: "OpenSans", size: 10)
        cell.lbPrice.font = UIFont.init(name: "AzoSans-Bold", size: 23)
        cell.lbNormalPrice.font = UIFont.init(name: "OpenSans", size: 9)
        cell.lbDiscount.font = UIFont.init(name: "OpenSans", size: 9)
        cell.btCompare.isHidden = true
        
        if(data[indexPath.row].image != nil){
            let image = data[indexPath.row].image!
            cell.imgProduct.sd_setImage(with: URL.init(string: image), placeholderImage: UIImage.init(named: "cargando"))
        }
        else
        {
            cell.imgProduct.image = UIImage.init(named: "no_disponible")
        }
        cell.lbDescription.text = data[indexPath.row].shortDescription
        if(data[indexPath.row].discount != nil)
        {
            cell.lbDiscount.text = data[indexPath.row].discount
            cell.viewDiscount.isHidden = false
        }
        else
        {
            cell.viewDiscount.isHidden = true
        }
        
        let (bestPrice, normalPrice, _, isCencosud) = MDTools.price(prices: data[indexPath.row].prices)
        
        cell.lbPrice.text = bestPrice.value
        if(normalPrice != nil)
        {
            cell.lbNormalPrice.text = (normalPrice?.name)! + " " + (normalPrice?.value)!
        }
        else
        {
            cell.lbNormalPrice.text = ""
        }

        cell.imgTarjetaCencosud.isHidden = !isCencosud

        if(data[indexPath.row].discount != nil)
        {
            cell.viewDiscount.isHidden = false
            cell.lbDiscount.text = data[indexPath.row].discount
        }
        else
        {
            cell.viewDiscount.isHidden = true
        }
        
        MDTools.rounderBorderImage(imageView: cell.imgProduct)        
        cell.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        cell.layer.borderWidth = 1
        return cell
    }


}
