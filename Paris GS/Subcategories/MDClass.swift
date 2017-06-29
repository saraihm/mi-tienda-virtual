//
//  MDClass.swift
//  Paris GS
//
//  Created by Motion Displays on 04-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDClass: NSObject {

    var id: String!
    var name: String!
    var image: String!
    var classes =  Array<AnyObject>()
    
    
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
                if((value as! Array<AnyObject>).count != 0)
                {
                    classes =  value as! Array<AnyObject>
                }
                
            }
        }
    }

}
