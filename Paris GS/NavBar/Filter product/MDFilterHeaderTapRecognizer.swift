//
//  MDFilterHeaderTapRecognizer.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 28-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDFilterHeaderTapRecognizer: UITapGestureRecognizer {
    
    var recognizerType: NSInteger!
    var indexPath: NSIndexPath!
    var section: Int?
    
    enum MDFilterHeaderTapRecognizerType: Int {
       case MDFilterHeaderRecognizerLineFirstLevel
       case MDFilterHeaderRecognizerLineSecondLevel
       case MDFilterHeaderRecognizerLineChild
       case MDFilterHeaderRecognizerFilter
    }

}
