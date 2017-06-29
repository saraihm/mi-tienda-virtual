//
//  MDFilter.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 11-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDFilter: NSObject {
    
    var filterID: NSNumber!
    var filterTitle: String!
    var checkCounter: NSNumber!
    var options = Array<MDOption>()
    var name: String!
    var type: String!
    var tips: Bool!
    
    init? (attributes: Dictionary<String, AnyObject>)
    {
        for (key, value) in attributes {
            if(key == "id")
            {
                if(value is NSNull){return nil}
                filterID = value as! NSNumber
            }
            if(key == "name")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                name = value as! String
            }
            if(key == "sub_filters")
            {
                if(value is NSNull){return nil}
                let optionArray = value as! Array<AnyObject>
                if((optionArray).count != 0)
                {
                    for optionValue: AnyObject in optionArray
                    {
                        let option = MDOption.init(attributes: optionValue as! Dictionary<String, AnyObject>)
                        if(option != nil)
                        {
                            options.append(option!)
                        }
                    }
                    
                    var counter = 0
                    
                    for option: MDOption in options {
                        if(option.checked == true)
                        {
                            counter = counter + 1
                        }
                    }
                    
                    checkCounter = NSNumber(value: counter)
                }
                else
                {
                    return nil
                }
               
            }
            
        }
    }

}
