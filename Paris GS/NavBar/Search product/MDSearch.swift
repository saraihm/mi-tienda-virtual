//
//  MDSearch.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 16-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDSearch: NSObject {
    
    var title: String!
    var subTitle: String!
    var resultsCount: Int!
    var productsId =  Array<Int>()
    
    
    init? (attributes: Dictionary<String, AnyObject>)
    {
        for (key, value) in attributes {
            if(key == "name")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                title = value as! String
            }
            if(key == "title")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                subTitle = value as! String
            }
            if(key == "count")
            {
                if(value is NSNull){return nil}
                resultsCount = value as! Int
            }
            if(key == "products")
            {
                if(value is NSNull){return nil}
                productsId = value as! Array<Int>
            }
        }
    }


}
