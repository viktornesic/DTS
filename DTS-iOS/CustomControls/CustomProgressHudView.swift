//
//  CustomProgressHudView.swift
//  DTS-iOS
//
//  Created by Viktor on 16/03/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit

class CustomProgressHudView: UIView {

    class func createCustomHudView() -> CustomProgressHudView {
        let customHudView = Bundle.main.loadNibNamed("CustomProgressHudView", owner: self, options: nil)![0] as! CustomProgressHudView
        return customHudView
    }
    
}
