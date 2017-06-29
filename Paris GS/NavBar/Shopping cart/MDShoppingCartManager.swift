//
//  MDShoppingCartManager.swift
//  Paris GS
//
//  Created by Motion Displays on 22-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDShoppingCartManager: NSObject {

    var shoppingCart =  MDShoppingCart()
    
    func addProductToCart(product: MDProduct) {
        
       shoppingCart.addProduct(product)
    }
    

}
