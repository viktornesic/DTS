//
//  detailActionsTableViewCell.swift
//  DTS-iOS
//
//  Created by Viktor on 31/10/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

class detailActionsTableViewCell: UITableViewCell {

    @IBOutlet weak var btnDriveTo: UIButton!
    @IBOutlet weak var btnStreetView: UIButton!
    @IBOutlet weak var btnGetInfo: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnApply: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        formateButton(btnApply)
        formateButton(btnShare)
        formateButton(btnDriveTo)
        formateButton(btnGetInfo)
        formateButton(btnStreetView)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension detailActionsTableViewCell {
    func formateButton(_ btn: UIButton) -> Void {
        btn.layer.cornerRadius = btn.frame.size.width / 2
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 1.0
        btn.clipsToBounds = true
    }
}
