//
//  DescriptionTableViewCell.swift
//  DTS-iOS
//
//  Created by Viktor on 29/10/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var btnContact: UIButton!
    @IBOutlet weak var btnLHLink: UIButton!
    @IBOutlet weak var lblLink: UILabel!
    @IBOutlet weak var lblContact: UILabel!
    @IBOutlet weak var lblBrokageOffice: UILabel!
    @IBOutlet weak var agentName: UILabel!
    @IBOutlet weak var lblPropertyHighlights: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
