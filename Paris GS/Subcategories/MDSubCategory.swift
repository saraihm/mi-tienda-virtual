//
//  MDSubCategory.swift
//  Paris GS
//
//  Created by Motion Displays on 03-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDSubCategory: NSObject {
    
    var id: String!
    var name: String!
    var image: String!
    var classes =  Array<MDSubCategory>()
    
    
    init? (attributes: Dictionary<String, AnyObject>)
    {
        for (key, value) in attributes {
            if(key == "id")
            {
                if((value as! String).isEmpty){ return nil }
                id = value as! String
            }
            if(key == "name")
            {
                if((value as! String).isEmpty){ return nil }
                name = value as! String
            }
            if(key == "imageSidebar")
            {
                if((value as! String).isEmpty){ return nil }
                image = value as! String
            }
            if(key == "childs")
            {                
                let childs = value as! Array<AnyObject>
                if((childs).count != 0)
                {
                    for category: AnyObject in childs
                    {
                        let subcategory = MDSubCategory.init(attributes: category as! Dictionary<String, AnyObject>)
                        classes.append(subcategory!)
                        
                    }
                }
            }
        }
    }

}
