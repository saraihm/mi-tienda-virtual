//
//  MDTableViewCollectionCellCollectionViewCell.swift
//  Paris GS
//
//  Created by Motion Displays on 16-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDTableViewCollectionCellCollectionViewCell: UICollectionViewCell {
    
    var collectionViewDataSource : UICollectionViewDataSource!
    var collectionViewDelegate : UICollectionViewDelegate!
    var delegate : CollectionViewSelectedProtocol!

    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
