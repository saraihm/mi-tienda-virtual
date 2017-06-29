//
//  MDDevice.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 26-09-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDDevice: NSObject {

    var id: Int!
    var uuid: String!
    var name: String!
    var device_type: String!
    var environment: String!
    var created_at: String!
    var updated_at: String!
    
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
            if(key == "uuid")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                uuid = value as! String
            }
        }
    }

}
