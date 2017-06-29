//
//  MDProduct.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 05-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDProduct: NSObject {

    var id: Int!
    var sku: String!
    var barcode: String?
    var name: String!
    var shortDescription: String!
    var image: String?
    var imageTv: String?
    var classId: String?
    var prices = Array<MDPrice>()
    var discount: String?
    var brand: String?
    var isUpdatedPrices = false
    
    //ShoppingCart
    var quantity: Int = 1
    
    init? (attributes: Dictionary<String, AnyObject>)
    {
        for (key, value) in attributes {
            if(key == "id")
            {
                if(value is NSNull){return nil}
                id = value as! Int
            }
            if(key == "sku")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                sku = value as! String
            }
            if(key == "barcode")
            {
                barcode = value as? String
            }
            if(key == "name")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                name = value as! String
            }
            if(key == "description")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                shortDescription = value as! String
            }
            if(key == "class")
            {
                print(value)
                classId = value as? String
            }
            if(key == "image")
            {
                image = value as? String
            }
            if(key == "extended")
            {
                imageTv = value as? String
            }
            if(key == "discount")
            {
                if(!(value is NSNull))
                {
                    discount = "-" + (value as! String)
                }
            }
            if(key == "brand")
            {
                brand = value as? String
            }

            if(key == "prices")
            {
                if(value is NSNull){return nil}
                let prices = value as! Array<AnyObject>
                if((prices).count != 0)
                {
                    for price: AnyObject in prices
                    {
                        let price = MDPrice.init(attributes:price as! Dictionary<String, AnyObject>)
                        if(price != nil)
                        {
                            self.prices.append(price!)
                        }
                    }
                    
                    if(self.prices.count == 0)
                    {
                        return nil
                    }
                }
                else
                {
                    return nil
                }
            }
        }
    }
    
    override init() {
    }
    
    init(productDescription: String?, productImage: String?, productClass: String?, productName: String?, productId: Int?, productPrices: Array<MDPrice>, productDiscount: String?, productBarcode: String?, sku: String?, quantity: Int) {
        self.shortDescription = productDescription
        self.image = productImage
        self.classId = productClass
        self.prices = productPrices
        self.discount = productDiscount
        self.sku = sku
        self.quantity = quantity
        self.id = productId
        self.name = productName
        self.barcode = productBarcode

    }
    

    required convenience init(coder decoder: NSCoder) {
        let productDescription = decoder.decodeObject(forKey: "productDescription") as! String?
        let productImage = decoder.decodeObject(forKey: "productImage") as! String?
        let productClass = decoder.decodeObject(forKey: "productClass") as! String?
        let productId = decoder.decodeObject(forKey: "productId") as! Int?
        let productName = decoder.decodeObject(forKey: "productName") as! String?
        let productBarcode = decoder.decodeObject(forKey: "productBarcode") as! String?
        let productPrices = (decoder.decodeObject(forKey: "productPrices") as!  Array<MDPrice>?)!
        let productDiscount = decoder.decodeObject(forKey: "productDiscount") as! String?
        let sku = decoder.decodeObject(forKey: "sku") as! String?
        let quantity = (decoder.decodeInteger(forKey: "quantity"))
        
        self.init(productDescription: productDescription!, productImage: productImage!, productClass: productClass, productName: productName, productId: productId, productPrices: productPrices,productDiscount: productDiscount, productBarcode: productBarcode, sku: sku, quantity: quantity)

    }
    
    func encodeWithCoder(_ coder: NSCoder) {
        coder.encode(self.shortDescription, forKey: "productDescription")
        coder.encode(self.image, forKey: "productImage")
        coder.encode(self.classId, forKey: "productClass")
        coder.encode(self.prices, forKey: "productPrices")
        coder.encode(self.discount, forKey: "productDiscount")
        coder.encode(self.sku, forKey: "sku")
        coder.encode(self.quantity, forKey: "quantity")
        coder.encode(self.id, forKey: "productId")
        coder.encode(self.name, forKey: "productName")
        coder.encode(self.barcode, forKey: "productBarcode")
    }
    
    func copyProduct() -> MDProduct {
        let copy = MDProduct(productDescription: self.shortDescription, productImage: self.image, productClass: self.classId, productName: self.name, productId: self.id, productPrices: self.prices, productDiscount: self.discount, productBarcode: self.barcode, sku:self.sku, quantity: self.quantity)
        
        return copy

    }


}
