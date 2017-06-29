//
//  MDLoadingView.swift
//  Paris GS
//
//  Created by Motion Displays on 27-10-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDLoadingView: UIView {

    var loading: DotsLoader!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor.clear
        loading = DotsLoader.init(frame: CGRect.init(x: self.center.x-57, y: self.center.y-40, width: 114, height: 80))
        self.addSubview(loading)
    }
    
    func starLoding(inView: UIView)  {
      
        loading.startAnimating()
        inView.addSubview(self)
    }
    
    func stopLoding()  {
        
        self.removeFromSuperview()

    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
