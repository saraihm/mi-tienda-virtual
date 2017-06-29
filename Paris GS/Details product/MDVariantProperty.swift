//
//  MDVariantProperty.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 30-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDVariantProperty: NSObject {

    var key: String!
    var value: String!
    var name: String?
    
    init(key: String, value: String, name: String?) {
        self.key = key
        self.value = value
        self.name = name
    }
}
