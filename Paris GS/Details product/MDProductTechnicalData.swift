//
//  MDProductTechnicalData.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 29-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDProductTechnicalData: NSObject {
    
    var featureKey: String!
    var featureValue: String!
    
    init? (attributes: Dictionary<String, AnyObject>)
    {
        for (key, value) in attributes {
            if(key == "key")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                featureKey = value as! String
            }
            if(key == "value")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                featureValue = value as! String
            }
        }
    }

}
