//
//  UCLTypeViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 14/07/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

class UCLTypeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func btnApt_Tapped(_ sender: AnyObject) {
        AppDelegate.returnAppDelegate().userProperty.setObject("APT", forKey: "uclType" as NSCopying)
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ucllocationVC") as! UCLLocationViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func btnHouse_Tapped(_ sender: AnyObject) {
        AppDelegate.returnAppDelegate().userProperty.setObject("APT", forKey: "uclType" as NSCopying)
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ucllocationVC") as! UCLLocationViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnBB_Tapped(_ sender: AnyObject) {
        AppDelegate.returnAppDelegate().userProperty.setObject("APT", forKey: "uclType" as NSCopying)
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ucllocationVC") as! UCLLocationViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBack_Tapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}
