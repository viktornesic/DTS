//
//  EmailViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 10/02/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit

class EmailViewController: UIViewController {

    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        let revealController = revealViewController()
        revealController?.panGestureRecognizer()
        revealController?.tapGestureRecognizer()
        
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        self.txtEmail.delegate = self
        self.txtEmail.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    

    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        if Utils.validateEmailAddress(self.txtEmail.text!) == false {
            Utils.showOKAlertRO("", message: "Email is invalid", controller: self)
            return
        }
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DwollaAddressViewController") as! DwollaAddressViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }

}

extension EmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
        self.navigateToNextScreen()
        return false
    }
    
    func navigateToNextScreen() -> Void {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DwollaAddressViewController") as! DwollaAddressViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
