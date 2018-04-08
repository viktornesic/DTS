//
//  LNViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 10/02/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit

class LNViewController: UIViewController {

    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var txtLastName: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        let revealController = revealViewController()
        revealController?.panGestureRecognizer()
        revealController?.tapGestureRecognizer()
        
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        self.txtLastName.delegate = self
        self.txtLastName.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EmailViewController") as! EmailViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }

}

extension LNViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
        navigateToNextScreen()
        return false
    }
    
    func navigateToNextScreen() {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EmailViewController") as! EmailViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
