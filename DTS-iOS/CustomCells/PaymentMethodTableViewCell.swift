//
//  PaymentMethodTableViewCell.swift
//  DTS-iOS
//
//  Created by Viktor on 16/01/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit

class PaymentMethodTableViewCell: UITableViewCell {

    @IBOutlet weak var btnConfirmVerifyDeposit: UIButton!
    @IBOutlet weak var txtAmount2: UITextField!
    @IBOutlet weak var txtAmount1: UITextField!
    @IBOutlet weak var btnVerifyDeposits: UIButton!
    @IBOutlet weak var lblBankAccount: UILabel!
    @IBOutlet weak var lblRoute: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnRequestInfo: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
