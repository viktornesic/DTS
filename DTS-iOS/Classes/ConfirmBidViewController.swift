//
//  ConfirmBidViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 03/07/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit

class ConfirmBidViewController: UIViewController {

    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var mainStack: UIStackView!
    
    
    var originalPrice: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtPrice.keyboardType = .numberPad
        
        self.btnSideMenu.isHidden = true
//        let revealController = revealViewController()
//        revealController?.panGestureRecognizer().isEnabled = false
//        revealController?.tapGestureRecognizer()
//        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        let btn = UIButton(frame: self.btnConfirm.bounds)
        btn.addTarget(self, action: #selector(confirmBidButtonTapped(_:)), for: .touchUpInside)
        btn.backgroundColor = self.btnConfirm.backgroundColor
        btn.setTitle("Confirm Bid", for: .normal)
        btn.titleLabel?.font = btnConfirm.titleLabel?.font
        
        //self.txtPrice.delegate = self
        btnConfirm.isHidden = true
        
        self.txtPrice.inputAccessoryView = btn
        self.txtPrice.becomeFirstResponder()
        
        self.txtPrice.addTarget(self, action: #selector(textFieldTextDidChange(textField:)), for: .editingChanged)
    }
    
    func textFieldTextDidChange(textField: UITextField) {
        textField.invalidateIntrinsicContentSize()
    }

    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func confirmBidButtonTapped(_ sender: Any) {
        
    }
    
    
    
}

//extension ConfirmBidViewController: UITextFieldDelegate {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        textField.invalidateIntrinsicContentSize()
//        textField.layoutIfNeeded()
//        return true
//    }
//    
//}
