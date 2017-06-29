//
//  MDShoppingCart.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 22-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDShoppingCart: NSObject, NSCoding {
    
    var products = Array<MDProduct>()
    var total: Float = 0
    var totalCencosud: Float = 0
    
    override init() {
        
    }
    init(products: Array<MDProduct>, total: Float, totalCencosud: Float ) {
        self.products = products
        self.total = total
        self.totalCencosud = totalCencosud
    }
    
    func saveShoppingCart()
    {
        let userDefault = UserDefaults.standard
        if((userDefault.object(forKey: "shoppingCart")) != nil)
        {
            userDefault.removeObject(forKey: "shoppingCart")
        }
        
        let shoppingCart = NSKeyedArchiver.archivedData(withRootObject: MDShoppingCartViewController.shoppingCart)
        userDefault.set(shoppingCart, forKey: "shoppingCart")
        userDefault.synchronize()
    }
    
    
    func setShoppingCart(shoppingCart: NSData) {
        MDShoppingCartViewController.shoppingCart = NSKeyedUnarchiver.unarchiveObject(with: shoppingCart as Data) as! MDShoppingCart
    }
    
    func addProduct(product: MDProduct) {

        var equal = false
        if(products.count > 0)
        {
            for productElement: MDProduct in products {
                if(productElement.sku == product.sku)
                {
                     productElement.quantity = productElement.quantity+1
                     equal = true
                }
            }
            
            if(!equal)
            {
                products.append(product)
            }
        }
        else
        {
            products.append(product)
        }
        
         calculateSubtotal()
    }
    
    func deleteProduct(index: Int) {
        let product = products[index]
        for productElement: MDProduct in products {
            if(productElement.sku == product.sku)
            {
                products.remove(at: products.index(of: product)!)
                calculateSubtotal()
            }
        }
        saveShoppingCart()
    }
    
    func deleteAllProduct() {
        products.removeAll()
        total = 0
        totalCencosud = 0
        saveShoppingCart()
        
    }
  
    
    func moreProduct(index: Int) {
        let product = products[index]
        for productElement: MDProduct in products {
            if(productElement.sku == product.sku)
            {
                productElement.quantity = productElement.quantity+1
                calculateSubtotal()
            }
        }
        saveShoppingCart()
    }
    
    func lessProduct(index: Int) {
        let product = products[index]
        for productElement: MDProduct in products {
            if(productElement.sku == product.sku)
            {
                productElement.quantity = productElement.quantity-1
                calculateSubtotal()
            }
        }
        saveShoppingCart()
    }
    
    func calculateSubtotal() {
        totalCencosud = Float(0)
        total = Float(0)
        var valueCencosud = Float(0)
        var valueInternet = Float(0)
        var valueNormal = Float(0)
        
        for product in products {
            for price: MDPrice in product.prices {
                
                if(price.name == kPriceCencosud)
                {
                    var value = price.value.replacingOccurrences(of:"$", with: "")
                    value = value.replacingOccurrences(of:".", with: "")
                    valueCencosud =  Float(value)!*Float(product.quantity)
                }
                else if(price.name == kPriceInternet)
                {
                    var value = price.value.replacingOccurrences(of:"$", with: "")
                    value = value.replacingOccurrences(of:".", with: "")
                    valueInternet = (Float(value)!*Float(product.quantity))
                }
                else
                {
                    var value = price.value.replacingOccurrences(of:"$", with: "")
                    value = value.replacingOccurrences(of:".", with: "")
                    valueNormal = (Float(value)!*Float(product.quantity))
                }
            }
            
            if(valueCencosud != 0)
            {
                totalCencosud += valueCencosud
            }
            if(valueInternet != 0)
            {
                total += valueInternet
                if(valueCencosud == 0)
                {
                    totalCencosud += valueInternet
                }
            }
            else if (valueNormal != 0)
            {
                total += valueNormal
            }
            
            valueCencosud = 0
            valueNormal = 0
            valueInternet = 0
        }
        
        if(total == totalCencosud)
        {
            totalCencosud = 0
        }
    }
    
    
     public convenience required init?(coder aDecoder: NSCoder) {
        let total = (aDecoder.decodeFloat(forKey: "total"))
        let totalCencosud = (aDecoder.decodeFloat(forKey: "totalCencosud"))
        let products = aDecoder.decodeObject(forKey: "products") as! Array<MDProduct>
        self.init(products: products, total: total, totalCencosud: totalCencosud)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.total, forKey: "total")
        aCoder.encode(self.totalCencosud, forKey: "totalCencosud")
        aCoder.encode(self.products, forKey: "products")
        
    }
    
}
