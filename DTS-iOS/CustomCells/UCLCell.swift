//
//  UCLCell.swift
//  DTS-iOS
//
//  Created by Viktor on 28/07/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

class UCLCell: UITableViewCell {

    @IBOutlet weak var ivTitleBg: UIImageView!
    @IBOutlet weak var ivButtonBg: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
