//
//  MDAtribute.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 25-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDAtribute: NSObject {

    var atributesName: String!
    var tagValues = Array<String>()
    
    init? (attributes: Dictionary<String, AnyObject>)
    {
        for (key, value) in attributes {
            if(key == "name")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                atributesName = value as! String
            }
            if(key == "values")
            {
                if(value is NSNull){return nil}
                tagValues = value as! Array<String>
            }
        }
    }

}
