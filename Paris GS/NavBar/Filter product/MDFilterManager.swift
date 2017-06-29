 //
//  MDFilterManager.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 11-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDFilterManager: NSObject {
    
    var filterIdOpen: NSNumber?
    var lastFilterErased: NSNumber?
    var filters = Array<MDFilter>()
    var answerIDs = Array<NSNumber>()
    var productIds = Array<Int>()
    var firstTimeOpen = true
    var hasSort = false
    var indexPathOpen: NSIndexPath?
    var filterWithProductsId = false
    var isSortAsc = true
    var isSortDesc = false
    var isSortAZ = false
    var isSortZA = false
    
    func getFiltersWith(categoryId: NSNumber, hasError: @escaping (Bool) -> ()){

        var direction = "asc"
        var sort = ["by":"price", "direction":direction]
        if(isSortDesc)
        {
            direction = "desc"
            sort = ["by":"price", "direction":direction]
        }
        else if(isSortAZ)
        {
            direction = "asc"
            sort = ["by":"description", "direction":direction]
        }
        else if(isSortZA)
        {
            direction = "desc"
            sort = ["by":"description", "direction":direction]
        }
        
        let parameters = ["category": ["id": categoryId, "sub_filters": answerIDs, "sort": sort]]
        
        print("parameters: ", parameters)
       
        let path = kWSFilter
            print("path: ", path)
            
            if(MotionDisplaysApi.internetConnection())
            {
                MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                    
                    if(!hasResponseError && jsonResponse != nil)
                    {
                        let json = JSON(jsonResponse as AnyObject)
                        let data = json["data"].dictionaryObject
                        print(json)
                        if(data == nil)
                        {
                            print("ERROR ON DATA")
                            hasError(true)
                        }
                        else
                        {
                            let filters = data!["filters"]
                            self.filters.removeAll()
                            for filter: AnyObject in filters! as! Array<AnyObject>
                            {
                                let filter = MDFilter.init(attributes: filter as! Dictionary<String, AnyObject>)
                                if(filter != nil)
                                {
                                    if(filter?.name != "Precio")
                                    {
                                        filter?.options = (filter?.options.sorted{ $0.name < $1.name })!
                                    }
                                    self.filters.append(filter!)
                                }
                            }
                            
                            for filter: MDFilter in self.filters
                            {
                                if(self.filterIdOpen == filter.filterID)
                                {
                                    self.setIndexPathOpenFilter(indexPathOpen: NSIndexPath.init(item: 0, section: self.filters.index(of: filter)!))
                                    break
                                }
                            }
                            
                            self.productIds = data!["products"] as! Array<Int>
                                
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
    
    func getFiltersWith(productsID: Array<Int>, hasError: @escaping (Bool) -> ()){
        var direction = "asc"
        var sort = ["by":"price", "direction":direction]
        if(isSortDesc)
        {
            direction = "desc"
            sort = ["by":"price", "direction":direction]
        }
        else if(isSortAZ)
        {
            direction = "asc"
            sort = ["by":"description", "direction":direction]
        }
        else if(isSortZA)
        {
            direction = "desc"
            sort = ["by":"description", "direction":direction]
        }
        
        let parameters = ["product": ["id": productsID, "sub_filters": answerIDs, "sort": sort]]
        
        print("parameters: ", parameters)
        
    
            let path = kWSFilterSkus
            print("path: ", path)
            
            if(MotionDisplaysApi.internetConnection())
            {
                MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                    
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
                            let filters = data!["filters"]
                            self.filters.removeAll()
                            for filter: AnyObject in filters! as! Array<AnyObject>
                            {
                                let filter = MDFilter.init(attributes: filter as! Dictionary<String, AnyObject>)
                                if(filter != nil)
                                {
                                    if(filter?.name != "Precio")
                                    {
                                        filter?.options = (filter?.options.sorted{ $0.name < $1.name })!
                                    }

                                    self.filters.append(filter!)                                    
                                }
                            }
                            
                            for filter: MDFilter in self.filters
                            {
                                if(self.filterIdOpen == filter.filterID)
                                {
                                    self.setIndexPathOpenFilter(indexPathOpen: NSIndexPath.init(item: 0, section: self.filters.index(of: filter)!))
                                    break
                                }
                            }
                            
                            self.productIds = data!["products"] as! Array<Int>
                                

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

    
    
    // MARK - AnswerIDs functions
    
    func addAnswerID(optionID: NSNumber) {
        if(optionID != 0)
        {
           answerIDs.append(optionID)
        }
        
        print("ANSWERS AFTER INSERT: ", answerIDs)
    }
    
    func removeAnswerID(optionID: NSNumber)
    {
        if(optionID != 0)
        {
            let index = answerIDs.index(of: optionID)
            answerIDs.remove(at: index!)
        }
    }
    
    func setIndexPathOpenFilter(indexPathOpen: NSIndexPath?) {
        self.indexPathOpen = indexPathOpen
        if(self.indexPathOpen != nil)
        {
            self.filterIdOpen = filters[indexPathOpen!.section].filterID
        }
        else
        {
            self.filterIdOpen = nil
        }
    }
    
    func setIndexPathOpenDetailsProduct(indexPathOpen: NSIndexPath?, linesTotal: Int) {
        self.indexPathOpen = indexPathOpen
    }
}
