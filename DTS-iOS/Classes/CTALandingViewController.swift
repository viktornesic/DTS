//
//  CTALandingViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 19/09/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit

class CTALandingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ditchButtonTapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ctaVC") as! CTAViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        if UserDefaults.standard.object(forKey: "token") != nil {
            let tabbarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabbarVC") as! UITabBarController
            AppDelegate.returnAppDelegate().window?.rootViewController = tabbarVC
        }
        else {
            let revealVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "revealVC") as! SWRevealViewController
            AppDelegate.returnAppDelegate().window?.rootViewController = revealVC
        }
        
    }
}


