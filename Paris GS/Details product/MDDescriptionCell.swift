//
//  MDDescriptionCell.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 29-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import WebKit

class MDDescriptionCell: UICollectionViewCell {
    
    var webView: WKWebView?
    var myActivityIndicator: UIActivityIndicatorView!
    var pagesLoaded = 0

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.webView = WKWebView()
        self.contentView.addSubview(self.webView!)
        myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = self.center
        myActivityIndicator.startAnimating()
        self.webView?.addSubview(myActivityIndicator)
    }
    
}
