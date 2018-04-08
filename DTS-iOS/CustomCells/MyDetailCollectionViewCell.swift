//
//  MyDetailCollectionViewCell.swift
//  DTS-iOS
//
//  Created by Viktor on 15/02/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit

class MyDetailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var txtField: UITextField!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var txtSSN: AKMaskField!
    @IBOutlet weak var txtAddress: AutoCompleteTextField!
    @IBOutlet weak var btnNext: UIButton!
}
