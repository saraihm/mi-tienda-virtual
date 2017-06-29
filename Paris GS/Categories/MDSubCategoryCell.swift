//
//  MDCategoriesCell.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 25-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDSubCategoryCell: UICollectionViewCell {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var imgHeight: NSLayoutConstraint!
    @IBOutlet weak var imgRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgLeftConstraint: NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }

}
