//
//  MDProductPresentation.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 29-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDProductPresentation: MDProduct {
    
    var longDescription: String?
    var line: String?
    var subline: String?
    var basicImages = Array<String>()
    var simulationImages = Array<String>()
    var basicImagesTv = Array<String>()
    var simulationImagesTv = Array<String>()
    var has_colors = false
    var preview = false
    var productClassId: Int?
    
    override init? (attributes: Dictionary<String, AnyObject>)
    {
        super.init(attributes: attributes)
        for (key, value) in attributes {
            
            if(key == "descriptions")
            {
                if(value is NSNull){return nil}
                let descriptions = value as! Dictionary<String, String>
                longDescription = descriptions["long"]
                shortDescription = descriptions["short"]
            }
            if(key == "is_simulable")
            {
                preview = value as! Bool
            }
            if(key == "has_colors")
            {
                has_colors = value as! Bool
            }
            if(key == "images")
            {
                let images = value["basic_images"] as! Array<Dictionary<String,String>>
                for image in images {
                    basicImages.append(image["image"]!)
                    basicImagesTv.append(image["extended"]!)
                }
                
                let imagesSimulation = value["environment_simulation"] as! Array<Dictionary<String,String>>
                for image in imagesSimulation {
                    simulationImages.append(image["image"]!)
                    simulationImagesTv.append(image["extended"]!)
                }
                
            }
            if(key == "path")
            {
                let classes = value as! Array<AnyObject>
                if((classes).count != 0)
                {
                    let classId = classes.last
                    print(classId!)
                    productClassId = classId?["id"] as? Int
                }
            }
        }
    }
    

    required convenience init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
       super.init()
    }

}
