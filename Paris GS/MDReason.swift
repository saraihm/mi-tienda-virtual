//
//  MDReason.swift
//  Paris GS
//
//  Created by Motion Displays on 12-12-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDReason: NSObject {
    
    var id: Int!
    var descriptionReason: String!
    
    init? (attributes: Dictionary<String, AnyObject>)
    {
        for (key, value) in attributes {
            if(key == "id")
            {
                if(value is NSNull){return nil}
                id = value as! Int
            }
            if(key == "description")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                descriptionReason = value as! String
            }
        }
    }

}
