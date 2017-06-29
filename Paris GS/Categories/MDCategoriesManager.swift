//
//  MDCategoriesManager.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 03-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDCategoriesManager: NSObject {

    static var categories = Array<MDCategory>()
    var subCategories = Array<MDCategory>()
    var appSubTitle = ""
    var tvTitle = ""
    var type = ""
    
    func getCategories( hasError: @escaping (Bool) -> ()){

            let path = kWSCategories
            print("path: ", path)
            
            if(MotionDisplaysApi.internetConnection())
            {
                MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: nil, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
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
                            MDCategoriesManager.categories.removeAll()
                            let roots = data?["roots"]?.arrayObject
                            for category: Any in roots!
                            {
                                let category = MDCategory.init(attributes: category as! Dictionary<String, AnyObject>)
                                if(category != nil)
                                {
                                    MDCategoriesManager.categories.append(category!)
                                }
                                
                            }
                            
                            if(!((data!["app_title"]!.object) is NSNull))
                            {
                                self.appSubTitle = data!["app_title"]!.stringValue
                            }
                            
                            if(!((data!["tv_title"]!.object) is NSNull))
                            {
                                self.tvTitle = data!["tv_title"]!.string!
                            }
                            if(!((data!["type"]!.object) is NSNull))
                            {
                                self.type = data!["type"]!.string!
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
    
    func getSubcategories(uniqueID: NSNumber, hasError: @escaping (Bool) -> ()){
        var parameters: Dictionary<String, AnyObject>
        if(uniqueID == 0)
        {
            parameters = [:]
            hasError(true)
        }
        else
        {
            let category = ["id": uniqueID]
            parameters = ["category": category as AnyObject]
        }
        
        print("parameters: ", parameters)
    
            let path = kWSSubCategories
            print("path: ", path)
            
            if(MotionDisplaysApi.internetConnection())
            {
                MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { (jsonResponse: Any?, hasResponseError: Bool) in

                
                    if(!hasResponseError && jsonResponse != nil)
                    {
                        let json = JSON(jsonResponse as AnyObject)
                        let data = json["data"].dictionary
                            print(json)
                        if(data == nil)
                        {
                            print("ERROR ON DATA")
                            hasError(true)
                        }
                        else
                        {
                            for subCategory: Any in (data!["children"]?.arrayObject)!
                            {
                                let subCategory = MDCategory.init(attributes: subCategory as! Dictionary<String, AnyObject>)
                                if(subCategory != nil)
                                {
                                    self.subCategories.append(subCategory!)
                                }
                                
                            }
                            
                            if(!((data!["app_title"]!.object) is NSNull))
                            {
                                self.appSubTitle = data!["app_title"]!.stringValue
                            }

                            if(!((data!["tv_title"]!.object) is NSNull))
                            {
                                self.tvTitle = data!["tv_title"]!.string!
                            }
                            if(!((data!["type"]!.object) is NSNull))
                            {
                                self.type = data!["type"]!.string!
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

}
