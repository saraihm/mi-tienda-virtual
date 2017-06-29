//
//  MDShoppingCarManager.swift
//  Paris GS
//
//  Created by Motion Displays on 18-10-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDShoppingCarManager: NSObject {
    
    let userDefault = UserDefaults.standard
    var cartID: Int!
    static var cookies = ""
    
//    func newShoppingCart(hasError: @escaping (Bool) -> ())
//    {
//        let parameters = ["cart":["user": ["id":userDefault.value(forKey: "id")!, "store":userDefault.value(forKey: "store")!, "user_name":userDefault.value(forKey: "user_name")!]]]
//        
//        print("parameters: ", parameters)
//        
//        let path = kWSNewCart
//        
//        if(MotionDisplaysApi.internetConnection())
//        {
//            MotionDisplaysApi.jsonRequestOperationGET(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
//                
//                if(!hasResponseError && jsonResponse != nil)
//                {
//                    let json = JSON(jsonResponse as AnyObject)
//                    let data = json["data"].dictionaryObject
//                    
//                    if(data == nil)
//                    {
//                        print("ERROR ON DATA")
//                        hasError(true)
//                    }
//                    else
//                    {
//                        self.cartID = data?["id"] as! Int
//                        hasError(false)
//                    }
//                }
//                else
//                {
//                    hasError(true)
//                }
//                },failure: { (error: Error) in
//                    hasError(true)
//            })
//        }
//        else
//        {
//            hasError(true)
//        }
//        
//        
//    }
    
    func addProductShoopingCart(product: MDProduct, hasError: @escaping (Bool) -> ())
    {
        let parameters = ["cart":["id":self.cartID!, "product":product.id!, "quantity":String(product.quantity)]]
        
        print("parameters: ", parameters)
        
        let path = kWSAddItemCart
        
        if(MotionDisplaysApi.internetConnection())
        {
            MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                
                if(!hasResponseError && jsonResponse != nil)
                {
                    let json = JSON(jsonResponse as AnyObject)
                    let data = json["data"].bool
                    
                    if(data == nil)
                    {
                        print("ERROR ON DATA")
                        hasError(true)
                    }
                    else
                    {
                        if(data!)
                        {
                            hasError(false)
                        }
                        else
                        {
                            hasError(true)
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
    
    func publishShoopingCart( hasError: @escaping (Bool) -> ())
    {
        
        let path = kWSPublishCart
        
        if(MotionDisplaysApi.internetConnection())
        {
            MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: nil, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                
                if(!hasResponseError && jsonResponse != nil)
                {
                    let json = JSON(jsonResponse as AnyObject)
                    let data = json["data"].dictionaryObject
                    
                    if(data == nil)
                    {
                        print("ERROR ON DATA")
                        hasError(true)
                    }
                    else
                    {
                        var result = ""
                        for cookie in data?["cookies"] as! Array<String>
                        {/*
                            print(cookie)
                            let cookieValues = cookie.components(separatedBy:";")
                            let name = cookieValues[0]
                            let path = cookieValues[1].lowercased()
                            let domain = cookieValues[2].lowercased()
                            result += "document.cookie='\(name); \(domain); \(path); "
                            if(cookieValues.count > 3)
                            {
                                let date = cookieValues[3].components(separatedBy:"=")[1]
                                result += "expires=\(date); "
                            }
                            result += "'; "*/
                            result += cookie.components(separatedBy:";")[0] + "; "
                        }
                       // result += "document.cookie='JSESSIONID=00002FzpxbbTqkh2KszFsIxXEqc; domain=/;  path=/; '; "
                        MDShoppingCarManager.cookies = result
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
    




}
