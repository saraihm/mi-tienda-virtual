//
//  MDOption.swift
//  Paris GS
//
//  Created by Motion Displays on 12-12-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDOptionSurvey: NSObject {
    
    var id: Int!
    var name: String!
    var reasons = Array<MDReason>()
    var type: String!
    var descriptionOption: String!
    
    init? (attributes: Dictionary<String, AnyObject>)
    {
        for (key, value) in attributes {
            if(key == "id")
            {
                if(value is NSNull){return nil}
                id = value as! Int
            }
            if(key == "title")
            {
                if(!(value is NSNull))
                {
                    name = value as! String
                }
            }
            if(key == "type")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                type = value as! String
            }

            if(key == "description")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                descriptionOption = value as! String
            }
            if(key == "reasons")
            {
                if(value is NSNull){return nil}
                let reasons = value as! Array<AnyObject>
                if((reasons).count != 0)
                {
                    for reason: AnyObject in reasons
                    {
                        let reason = MDReason.init(attributes:reason as! Dictionary<String, AnyObject>)
                        if(reason != nil)
                        {
                            self.reasons.append(reason!)
                        }
                    }
                }
            }
        }
    }

}
