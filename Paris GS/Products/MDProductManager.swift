//
//  MDProducts.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 05-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDProductManager: NSObject {
    
    var products = Array<MDProduct>()
    var data: AnyObject!

    func getProductsFromIDs(productIds: Array<Int>, hasError: @escaping (Bool) -> ()){

        let parameters = ["product": ["id":productIds]] as [String : Any]
        print("parameters: ", parameters)
        
            let path = kWSProductResult
            print("path: ", path)
            
            if(MotionDisplaysApi.internetConnection())
            {
                MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                    if(!hasResponseError && jsonResponse != nil)
                    {
                        let json = JSON(jsonResponse as AnyObject)
                        let data = json["data"].dictionary
                        self.data = jsonResponse as AnyObject!
                        print(self.data)
                        if(data == nil)
                        {
                            print("ERROR ON DATA")
                            hasError(true)
                        }
                        else
                        {
                            for product: Any in data!["products"]!.arrayObject!
                            {
                                let product = MDProduct.init(attributes: product as! Dictionary<String, AnyObject>)
                                if(product != nil)
                                {
                                    var added = false
                                    for product1 in self.products
                                    {
                                        if(product1.id == product?.id)
                                        {
                                            self.products[self.products.index(of: product1)!] = product!
                                            added = true
                                        }
                                    }
                                    if(!added){
                                        self.products.append(product!)
                                    }
                                    
                                }
                            }
                            
                            if(self.products.count == 0)
                            {
                                hasError(true)
                            }
                            else
                            {
                                hasError(false)
                            }
                        }
                    }
                    else
                    {
                        hasError(true)
                    }
                    
                    },failure: { (error: Error) in
                        hasError(true)
                })
            }
            else
            {
                hasError(true)
            }
    }
}
