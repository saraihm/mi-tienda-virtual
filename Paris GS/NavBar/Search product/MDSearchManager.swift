//
//  MDSearchManager.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 16-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDSearchManager: NSObject {
    
    var resultSkus = Array<MDSearch>()
    
    func searchProduct(key: String, hasError: @escaping (Bool) -> ()){
  
        let parameters = ["product":[ "keyword":key]]
        print("parameters: ", parameters)
        
            let path = kWSProductSearch
            print("path: ", path)
            
            if(MotionDisplaysApi.internetConnection())
            {
                MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                    
                    if(!hasResponseError && jsonResponse != nil)
                    {
                        let json = JSON(jsonResponse as AnyObject)
                        let data = json["data"].arrayObject
                        if(data == nil)
                        {
                            print("ERROR ON DATA")
                            hasError(true)
                        }
                        else
                        {
                            for search: Any in data!
                            {
                                let searchResult = MDSearch.init(attributes: search as! Dictionary<String, AnyObject>)
                                if(searchResult != nil)
                                {
                                    self.resultSkus.append(searchResult!)
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

}
