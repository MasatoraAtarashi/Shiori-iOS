//
//  FeedTableViewCell.swift
//  Shiori
//
//  Created by あたらしまさとら on 2019/09/16.
//  Copyright © 2019 Masatora Atarashi. All rights reserved.
//

import UIKit
import SwipeCellKit


class FeedTableViewCell: SwipeTableViewCell {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subContent: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
