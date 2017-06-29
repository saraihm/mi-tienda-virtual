//
//  MDStore.swift
//  Paris GS
//
//  Created by Motion Displays on 13-10-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDStore: NSObject {

    var id: Int!
    var salesCode: String!
    var name: String!

    
    init? (attributes: Dictionary<String, AnyObject>)
    {
        for (key, value) in attributes {
            if(key == "id")
            {
                if(value is NSNull){return nil}
                id = value as! Int
            }
            if(key == "name")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                name = value as! String
            }
            if(key == "sales_code")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                salesCode = value as! String
            }
        }
    }
}
