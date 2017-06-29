//
//  MDVariant.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 29-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDVariant: MDProductPresentation {
    
    var variantAvailable: Int!
    var properties = Array<MDVariantProperty>()
    
    override init? (attributes: Dictionary<String, AnyObject>)
    {
        super.init(attributes: attributes)
        
        for (key, value) in attributes {
            if(key == "variantAvailable")
            {
                variantAvailable = value as! Int
            }
            if(key == "color")
            {
                let colorProperties = value as! Dictionary<String, AnyObject>
                if(colorProperties["hex"] is NSNull)
                {
                    properties.append(MDVariantProperty.init(key: "Color", value: "", name:colorProperties["name"] as? String ))
                }
                else
                {
                    properties.append(MDVariantProperty.init(key: "Color", value: colorProperties["hex"]! as! String, name:colorProperties["name"] as? String ))
                }
                
            }
        }
    }
    
    required convenience init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
