//
//  MDShoppingCartCell.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 03-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

protocol TableViewCellSelectedDelegate: class  {
    
    func tableViewCellSelected(index : Int)
    func tableViewCellMoreProduct(index : Int)
    func tableViewCellLessProduct(index : Int)
    
}

class MDShoppingCartCell: UITableViewCell {

    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var lbSku: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbNormalPrice: UILabel!
    @IBOutlet weak var lbQuantity: UILabel!
    @IBOutlet weak var btMore: UIButton!
    @IBOutlet weak var btLess: UIButton!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var btRemoveProduct: UIButton!
    @IBOutlet weak var imgTarjetaCencosud: UIImageView!
    weak var delegate : TableViewCellSelectedDelegate!
    
    var quantityProduct = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        MDTools.rounderBorderImage(imageView: imgProduct)
        imgProduct.layer.borderWidth = 1
        imgProduct.layer.borderColor = COLOR_BLUE_LIGHT.cgColor
        
        viewContent.layer.borderWidth = 2
        viewContent.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        viewContent.layer.cornerRadius = kCornerRadiusButton
    }
    
    @IBAction func removeProduct(_ sender: AnyObject) {
        delegate!.tableViewCellSelected(index: sender.tag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(isSelected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func lessAction(_ sender: AnyObject) {
        if(quantityProduct != 1)
        {
            quantityProduct = quantityProduct-1
            delegate!.tableViewCellLessProduct(index: sender.tag)
        }
        
        if(quantityProduct < 10)
        {
            lbQuantity.text = "0"+String(quantityProduct)
        }
        else
        {
            lbQuantity.text = String(quantityProduct)
        }        
    }
    
    @IBAction func moreAction(_ sender: AnyObject) {
        quantityProduct = quantityProduct+1
        if(quantityProduct < 10)
        {
            lbQuantity.text = "0"+String(quantityProduct)
        }
        else
        {
            lbQuantity.text = String(quantityProduct)
        }
       
        delegate!.tableViewCellMoreProduct(index: sender.tag)
    }
}
