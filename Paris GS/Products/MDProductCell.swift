//
//  MDProductCell.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 26-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDProductCell: UICollectionViewCell {

    @IBOutlet weak var imgTarjetaCencosud: UIImageView!
    @IBOutlet weak var btCompareHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btCompareBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbDiscount: UILabel!
    @IBOutlet weak var lbNormalPrice: UILabel!
   // @IBOutlet weak var ratingView: HCSStarRatingView!
    @IBOutlet weak var btCompare: UIImageView!
    @IBOutlet weak var imgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewDiscount: UIView!
   // @IBOutlet weak var ratingViewHeightConstraint: NSLayoutConstraint!
   // @IBOutlet weak var ratingViewWidthConstraint: NSLayoutConstraint!
   // @IBOutlet weak var ratingViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionRightConstraint: NSLayoutConstraint!
   // @IBOutlet weak var lbPriceTopContraint: NSLayoutConstraint!
    var compareSelected = false
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

       // ratingView.tintColor = COLOR_BLUE_LIGHT
       // ratingView.spacing = 5.0
       // ratingView.selected = false
       // ratingView.offStars = COLOR_GRAY_LIGHT
        
    }

}
