//
//  SelectAccountTableViewCell.swift
//  DTS-iOS
//
//  Created by Viktor on 15/03/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import DLRadioButton

class SelectAccountTableViewCell: UITableViewCell {

    @IBOutlet weak var btnRadio: DLRadioButton!
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
