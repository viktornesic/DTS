//
//  SuccessViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 26/12/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController {
    @IBOutlet weak var lblSuccessMessage: UILabel!
    @IBOutlet weak var btnSideMenu: UIButton!
    var successMessage: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if successMessage != nil {
            self.lblSuccessMessage.text = successMessage
        }
        
        self.perform(#selector(SuccessViewController.loadRootViewController), with: nil, afterDelay: 5)

    }
    
    func loadRootViewController() -> Void {
        AppDelegate.returnAppDelegate().UpdateRootVC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
