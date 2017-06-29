//
//  MDSimulateOptions.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 07-09-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDSimulateOption: NSObject {
    
    var optionImage: String!
    var optionPreview: String!
    
    init? (attributes: Dictionary<String, AnyObject>)
    {
        for (key, value) in attributes {
            if(key == "image")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                optionImage = value as! String
            }
            if(key == "preview")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                optionPreview = value as! String
            }
        }
    }
}
