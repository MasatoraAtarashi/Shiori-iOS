//
//  FeedTableViewCell.swift
//  Shiori
//
//  Created by あたらしまさとら on 2019/09/16.
//  Copyright © 2019 Masatora Atarashi. All rights reserved.
//

import SwipeCellKit
import UIKit

class FeedTableViewCell: SwipeTableViewCell {

    // MARK: Type Aliases
    // MARK: Classes
    // MARK: Structs
    // MARK: Enums
    // MARK: Properties
    // MARK: IBOutlets
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subContent: UILabel!
    @IBOutlet weak var date: UILabel!

    // MARK: Initializers
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.thumbnail.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    // MARK: Type Methods
    // MARK: View Life-Cycle Methods
    // MARK: IBActions
    // MARK: Other Methods
    func changeTextColor(color: UIColor) {
        self.title.textColor = color
        self.subContent.textColor = color
        self.date.textColor = color
    }

    // MARK: Subscripts
}
