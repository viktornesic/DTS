//
//  SSNViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 10/02/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit

class SSNViewController: UIViewController {
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var txtEmail: AKMaskField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let revealController = revealViewController()
        revealController?.panGestureRecognizer()
        revealController?.tapGestureRecognizer()
        
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        self.txtEmail.delegate = self
        
        self.txtEmail.setMask("{dddd}", withMaskTemplate: "####")
        
        self.txtEmail.keyboardType = .numberPad
        
        self.addDoneButtonOnKeyboard(self.txtEmail)
        
        self.txtEmail.becomeFirstResponder()
        
    }
    
    func addDoneButtonOnKeyboard(_ view: UIView?)
    {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: view, action: #selector(UIResponder.resignFirstResponder))
        let items = [flexSpace, done]
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        if let accessorizedView = view as? UITextView {
            accessorizedView.inputAccessoryView = doneToolbar
            accessorizedView.inputAccessoryView = doneToolbar
        } else if let accessorizedView = view as? UITextField {
            accessorizedView.inputAccessoryView = doneToolbar
            accessorizedView.inputAccessoryView = doneToolbar
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "paymentMethodsVC") as! PaymentMethodsViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension SSNViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
