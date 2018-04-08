//
//  WalletTableViewCell.swift
//  DTS-iOS
//
//  Created by Viktor on 28/06/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit

class WalletTableViewCell: UITableViewCell {

    @IBOutlet weak var lblRedeemed: UILabel!
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var lblOfferTitle: UILabel!
    @IBOutlet weak var ivBarCode: UIImageView!
    @IBOutlet weak var lblURL: UILabel!
    @IBOutlet weak var lblRedemptionCode: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
