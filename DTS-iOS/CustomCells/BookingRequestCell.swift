//
//  BookingRequestCell.swift
//  DTS-iOS
//
//  Created by Viktor on 27/12/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit

class BookingRequestCell: UITableViewCell {

    @IBOutlet weak var lblLeasor: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var lblContactNumber: UILabel!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var lblReject: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
