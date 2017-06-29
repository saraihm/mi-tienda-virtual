//
//  MDCompareProducts.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 25-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDCompareProducts: NSObject {

    var atributes = Array<MDAtribute>()
    var products = Array<MDProduct>()
    var data: AnyObject!

    
    func compareProducts(firstProduct: Int, secondProduct: Int, hasError: @escaping (Bool) -> ()){
  
        let parameters = ["product": ["id": [firstProduct, secondProduct]]] as [String : Any]
        print("parameters: ", parameters)

            let path = kWSCompareProducts
            print("path: ", path)
            
            if(MotionDisplaysApi.internetConnection())
            {
                MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                    
                    if(!hasResponseError && jsonResponse != nil)
                    {
                        let json = JSON(jsonResponse as AnyObject)
                        let data = json["data"].dictionary
                        self.data = jsonResponse as AnyObject!

                        if(data == nil)
                        {
                            print("ERROR ON DATA")
                            hasError(true)
                        }
                        else
                        {
                            let productShortDescription = data!["products"]?.arrayObject
                            
                            for productNew: Any in productShortDescription!
                            {
                                let product = MDProduct.init(attributes: productNew as! Dictionary<String, AnyObject>)
                                if(product != nil)
                                {
                                    self.products.append(product!)
                                }

                            }
                            
                            if(self.products.count == 0)
                            {
                                hasError(true)
                            }
                            else
                            {
                                let atributes = data!["features"]?.arrayObject
                                for atribute: Any in atributes!
                                {
                                    let atribute = MDAtribute.init(attributes: atribute as! Dictionary<String, AnyObject>)
                                    if(atribute != nil)
                                    {
                                        self.atributes.append(atribute!)
                                    }
                                }
                                
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
