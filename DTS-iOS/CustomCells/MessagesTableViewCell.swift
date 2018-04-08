//
//  MessagesTableViewCell.swift
//  DTS-iOS
//
//  Created by Viktor on 20/05/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {

    @IBOutlet weak var constraintAddress2: NSLayoutConstraint!
    @IBOutlet weak var constraintAddress1: NSLayoutConstraint!
    @IBOutlet weak var constraintActionTrailing: NSLayoutConstraint!
    @IBOutlet weak var constraintActionWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintActionHeight: NSLayoutConstraint!
    @IBOutlet weak var viewVerticalLine: UIView!
    @IBOutlet weak var lblRoundedStatus: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var btnProperty: UIButton!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var ivProperty: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
