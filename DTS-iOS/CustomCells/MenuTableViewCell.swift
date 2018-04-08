//
//  MenuTableViewCell.swift
//  101Compaign-iOS
//
//  Created by Viktor on 04/05/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var viewSeprator: UIView!
    @IBOutlet weak var ivMenu: UIImageView!
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
