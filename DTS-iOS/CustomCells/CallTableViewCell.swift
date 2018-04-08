//
//  CallTableViewCell.swift
//  DTS-iOS
//
//  Created by Viktor on 31/10/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

class CallTableViewCell: UITableViewCell {

    @IBOutlet weak var btnRequestInfo: UIButton!
    @IBOutlet weak var btnHideListing: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
