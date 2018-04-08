//
//  FollowupTableViewCell.swift
//  DTS-iOS
//
//  Created by Viktor on 13/06/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

class FollowupTableViewCell: UITableViewCell {

    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
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
