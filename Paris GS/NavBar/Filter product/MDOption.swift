//
//  MDOption.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 11-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDOption: NSObject {
    
    var optionID: NSNumber!
    var optionTitle: String!
    var name: String!
    var img: String?
    var type: String!

    var checked: Bool!
    
    init? (attributes: Dictionary<String, AnyObject>)
    {
        for (key, value) in attributes {
            if(key == "id")
            {
                if(value is NSNull){return nil}
                optionID = value as! NSNumber
            }
            if(key == "name")
            {
                if(value is NSNull){return nil}
                name = value as! String
            }
            if(key == "checked")
            {
                if(value is NSNull){return nil}
                checked = value as! Bool
            }
            if(key == "icon")
            {
                img = value as? String
            }
        }
    }

}
