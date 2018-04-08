//
//  AccountTableViewCell.swift
//  DTS-iOS
//
//  Created by Viktor on 22/02/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {

    @IBOutlet weak var lblAccountName: UILabel!
    @IBOutlet weak var lblBankAccount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
