//
//  SelectBillTableViewCell.swift
//  DTS-iOS
//
//  Created by Viktor on 15/03/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import DLRadioButton

class SelectBillTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDueDate: UILabel!
    @IBOutlet weak var btnRadio: DLRadioButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
