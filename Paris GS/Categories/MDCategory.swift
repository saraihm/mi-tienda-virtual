//
//  MDCategory.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 03-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDCategory: NSObject {
   
     var uniqueID: NSNumber!
     var itemName: String!
     var itemSubTitle = ""
     var imageThumb: String!
     var hasNext = false
     var imageBodyPortrait: String!
     var imageBodyLandscape: String!
     var imageHome: String!
     var imageHomePortrait: String!
   
    init? (attributes: Dictionary<String, AnyObject>)
    {
        for (key, value) in attributes {
            if(key == "id")
            {
                if(value is NSNull){return nil}
                uniqueID = value as! NSNumber
            }
            if(key == "name")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                itemName = value as! String
            }
            if(key == "name")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                itemName = value as! String
            }
            if(key == "is_leaf")
            {
                if(value is NSNull){return nil}
                hasNext = value as! Bool
                hasNext = !hasNext
            }
            if(key == "images")
            {
                if(value is NSNull){return nil}
                let images = value as! Dictionary<String,AnyObject>
                for (key, value) in images
                {
                    if(key == "body_portrait")
                    {
                        imageBodyPortrait = value as? String
                        if(imageBodyPortrait == nil)
                        {
                            imageBodyPortrait = ""
                        }
                    }
                    if(key == "body_landscape")
                    {
                        imageBodyLandscape = value as? String
                    }
                    if(key == "home_landscape")
                    {
                        imageHome = value as? String
                    }
                    if(key == "home_portrait_2x")
                    {
                        imageHomePortrait = value as? String
                    }
                    if(key == "thumb")
                    {
                        imageThumb = value as? String
                    }
                }                
            }
            
        }
    }

    
    
}
