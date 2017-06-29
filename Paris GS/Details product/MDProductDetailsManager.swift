//
//  MDProductDetailsManager.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 29-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDProductDetailsManager: NSObject {
    
    var SectionFichaProducto = -1
    var SectionDescription = -1
    var SectionProductosSimilares = -1
    var SectionProductosRelacionados = -1
    var SectionComentarios = -1
    var numberOfSections = 0
    var productPresentation: MDProductPresentation!
    var productTechnicalData = Array<MDProductTechnicalData>()
    var productsSimilarIds = Array<Int>()
    var productsRelativeIds = Array<Int>()
    var productsSimilar = Array<MDProduct>()
    var productsRelative = Array<MDProduct>()
    var productVariations = Array<MDVariant>()
  
    func getProductDetails(productId: Int, productClass: Int, hasError: @escaping (Bool) -> ()){

        let parameters: Dictionary<String,AnyObject>
        if(productClass != 0)
        {
            let product = ["id": productId, "class": productClass, "sub_filters":[ MDFilterMenuViewController.filters.answerIDs]] as [String : Any]
             parameters = ["product": product as AnyObject]
        }
        else
        {
            let product = ["id": productId, "sub_filters": [MDFilterMenuViewController.filters.answerIDs]] as [String : Any]

            parameters = ["product": product as AnyObject]
        }
       
        print("parameters: ", parameters)
        
            let path = kWSProductInformation
            print("path: ", path)
            
            if(MotionDisplaysApi.internetConnection())
            {
                MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                    
                    if(!hasResponseError && jsonResponse != nil)
                    {
                        let json = JSON(jsonResponse as AnyObject)
                        let data = json["data"].dictionary
                        
                        if(data == nil)
                        {
                            print("ERROR ON DATA")
                            hasError(true)
                        }
                        else
                        {
                            self.productPresentation = MDProductPresentation.init(attributes: (data!["product"]?.dictionaryObject)! as Dictionary<String, AnyObject>)
                            
                            for productTechnicalData: Any in (data!["product"]!["features"].arrayObject)!
                            {
                                let productTechnicalData = MDProductTechnicalData.init(attributes: productTechnicalData as! Dictionary<String, AnyObject>)
                                if(productTechnicalData != nil)
                                {
                                    self.productTechnicalData.append(productTechnicalData!)
                                }
                            }
                            
                            if(self.productTechnicalData.count == 0)
                            {
                                let tecnicalData = ["key": "Descripción" as AnyObject, "value": self.productPresentation.shortDescription as AnyObject]
                                let productTechnicalData = MDProductTechnicalData.init(attributes: tecnicalData as Dictionary<String, AnyObject>)
                                if(productTechnicalData != nil)
                                {
                                    self.productTechnicalData.append(productTechnicalData!)
                                }

                            }
                            
                            for variant: Any in (data!["product"]!["variants"].arrayObject)!
                            {
                                let variant = MDVariant.init(attributes: variant as! Dictionary<String, AnyObject>)
                                if(variant != nil)
                                {
                                    self.productVariations.append(variant!)
                                }
                            }
        
                            hasError(false)

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
    
    func getProductPrice(product: MDProduct, hasError: @escaping (Bool) -> ()){
        
        let parameters = ["product": ["id": product.id]]
        print("parameters: ", parameters)
        
        let path = kWSProductPrices
        print("path: ", path)
        
        if(MotionDisplaysApi.internetConnection())
        {
            MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                
                if(!hasResponseError && jsonResponse != nil)
                {
                    let json = JSON(jsonResponse as AnyObject)
                    let data = json["data"].dictionary
                    print(data)
                    
                    if(data == nil)
                    {
                        print("ERROR ON DATA")
                        hasError(true)
                    }
                    else
                    {
                        var prices = Array<MDPrice>()
                        let pricesArray = data?["prices"]?.arrayObject
                        if((pricesArray)?.count != 0)
                        {
                            for price: AnyObject in pricesArray as! Array<AnyObject>
                            {
                                let price = MDPrice.init(attributes:price as! Dictionary<String, AnyObject>)
                                if(price != nil)
                                {
                                    prices.append(price!)
                                }
                            }
                            
                        }
                        
                        product.prices = prices
                        hasError(false)
                        
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

    
    func getAllProductsSimilar(productId: Int, productClassId: Int?, hasError: @escaping (Bool) -> ()){

        let parameters: Dictionary<String,AnyObject>
        if(productClassId != nil)
        {
            let product = ["id": productId, "class": productClassId!, "sub_filters":[ MDFilterMenuViewController.filters.answerIDs]] as [String : Any]
            parameters = ["product": product as AnyObject]
        }
        else
        {
            let product = ["id": productId, "sub_filters": [MDFilterMenuViewController.filters.answerIDs]] as [String : Any]
            
            parameters = ["product": product as AnyObject]
        }

        print("parameters: ", parameters)
       
        let path = kWSProductInformationSimilar
            print("path: ", path)
            
            if(MotionDisplaysApi.internetConnection())
            {
                MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                    
                    if(!hasResponseError && jsonResponse != nil)
                    {
                        let json = JSON(jsonResponse as AnyObject)
                        let data = json["data"].dictionary
                        
                        if(data == nil)
                        {
                            print("ERROR ON DATA")
                            hasError(true)
                        }
                        else
                        {
                            self.productsSimilar.removeAll()
                            for product: Any in data!["products"]!.arrayObject!
                            {
                                let product = MDProduct.init(attributes: product as! Dictionary<String, AnyObject>)
                                if(product != nil)
                                {
                                    self.productsSimilar.append(product!)
                                }
                            }
                            
                            hasError(false)
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
    
    func getAllProductsRelative(productId: Int, productClassId: Int?, hasError: @escaping (Bool) -> ()){

        let parameters: Dictionary<String,AnyObject>
        if(productClassId != nil)
        {
            let product = ["id": productId, "class": productClassId!, "sub_filters":[ MDFilterMenuViewController.filters.answerIDs]] as [String : Any]
            parameters = ["product": product as AnyObject]
        }
        else
        {
            let product = ["id": productId, "sub_filters": [MDFilterMenuViewController.filters.answerIDs]] as [String : Any]
            
            parameters = ["product": product as AnyObject]
        }
        
        print("parameters: ", parameters)
    
        let path = kWSProductInformationRelated
            print("path: ", path)
            
            if(MotionDisplaysApi.internetConnection())
            {
                MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                    
                    if(!hasResponseError && jsonResponse != nil)
                    {
                        let json = JSON(jsonResponse as AnyObject)
                        let data = json["data"].dictionary
                        
                        if(data == nil)
                        {
                            print("ERROR ON DATA")
                            hasError(true)
                        }
                        else
                        {
                            self.productsRelative.removeAll()
                            for product: Any in data!["products"]!.arrayObject!
                            {
                                let product = MDProduct.init(attributes: product as! Dictionary<String, AnyObject>)
                                if(product != nil)
                                {
                                    self.productsRelative.append(product!)
                                }
                            }
                            
                            hasError(false)
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
    
    func separeteSkus(pruducts: Array<MDProduct>) -> String  {
        var skus = ""
        var arraySkus = Array<String>()
        for product in pruducts {
            arraySkus.append(product.sku)
        }
        skus = arraySkus.joined(separator: ";")
        
        return skus
    }


}
