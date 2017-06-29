//
//  MDFilterHeaderCell.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 28-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDFilterHeaderCell: UICollectionReusableView {
    
    @IBOutlet weak var imgRow: UIImageView!
    @IBOutlet weak var lbTitleFilter: UILabel!
    var open = false
    var checked = false
    
    override func awakeFromNib() {
        self.open = false
        self.imgRow.isHighlighted = false
    }
    
    
    func toggleOpenWithUserAction(userAction: Bool, willOpen: (Bool) -> ()){
        print("toggleOpenWithUserAction ini")
        if (userAction) {
            open = !open
            if(open)
            {
                self.imgRow.image = UIImage.init(named: "bt_comprimir")
            }
            else
            {
                 self.imgRow.image = UIImage.init(named: "bt_comparador_abajo")
            }

            return willOpen(open)
            
        }
        else
        {
            if(self.open)
            {
                print("without userAction - restore open status")
                self.imgRow.isHighlighted = true
            }
            else
            {
                print("without userAction - restore close status")
                self.imgRow.isHighlighted = false
            }
        }
        
        print("toggleOpenWithUserAction end")

    }
    
    func toggleOpenWithUserActionDetailProduct(userAction: Bool, willOpen: (Bool) -> ()){
        print("toggleOpenWithUserAction ini")
        if (userAction) {
            open = !open
            if(open)
            {
                self.imgRow.image = UIImage.init(named: "bt_ficha_comprimir")
            }
            else
            {
                self.imgRow.image = UIImage.init(named: "bt_ficha_expandir")
            }
            
            return willOpen(open)
            
        }
        else
        {
            if(self.open)
            {
                print("without userAction - restore open status")
                self.imgRow.isHighlighted = true
            }
            else
            {
                print("without userAction - restore close status")
                self.imgRow.isHighlighted = false
            }
        }
        
        print("toggleOpenWithUserAction end")
        
    }

    
    func runSpinAnimationOnView(view:UIView, duration:Double, rotations: Float, repea: Float, floatAngle:Float) {
        let rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber.init(value: floatAngle * rotations)
        rotationAnimation.duration = duration
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = repea
        
        view.layer .add(rotationAnimation, forKey: "rotationAnimation")
    }
    
}
