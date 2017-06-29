//
//  MDPrice.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 05-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDPrice: NSObject {
    
    var bold: Bool?
    var name: String!
    var value: String!
    
    init? (attributes: Dictionary<String, AnyObject>)
    {
        for (key, value) in attributes {
            if(key == "bold")
            {
                bold = value as? Bool
            }
            if(key == "type")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                name = value as! String
            }
            if(key == "value")
            {
                if(value is NSNull){return nil}
                if((value as! String).isEmpty){ return nil }
                self.value = value as! String
            }
        }
    }
    
    init(bold: Bool?, name: String, value: String) {
        self.bold = bold
        self.name = name
        self.value = value
    }
    
    required convenience init(coder decoder: NSCoder) {
        let value = decoder.decodeObject(forKey: "value") as! String?
        let bold = decoder.decodeObject(forKey: "bold") as? Bool?
        let name = decoder.decodeObject(forKey: "name") as! String?
        self.init(bold:bold!, name: name!, value: value!)
        
    }
    
    func encodeWithCoder(_ coder: NSCoder) {
        coder.encode(self.value, forKey: "value")
        coder.encode(self.bold, forKey: "bold")
        coder.encode(self.name, forKey: "name")
        
    }
    
    override init() {
        
    }



}
