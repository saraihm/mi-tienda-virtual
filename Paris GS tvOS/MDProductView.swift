//
//  MDProductView.swift
//  Paris GS
//
//  Created by Motion Displays on 20-10-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDProductView: UIView {

    @IBOutlet weak var imgCencosud: UIImageView!
    @IBOutlet weak var lbPriceBeforeDiscount: UILabel!
    @IBOutlet weak var lbPriceAfterDiscount: UILabel!
    @IBOutlet weak var lbDiscount: UILabel!
    @IBOutlet weak var lbNormalPrice: UILabel!
    @IBOutlet weak var lbBestPrice: UILabel!
    @IBOutlet weak var lbTitleNormalPrice: UILabel!
    @IBOutlet weak var lbTitleBestPrice: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var viewDescription: UIView!
    var contentView : UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        contentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        contentView!.frame = bounds
        
        // Make the view stretch with containing view
        contentView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView!)
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
}
