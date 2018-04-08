//
//  UCLDescriptionViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 29/11/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress

class UCLDescriptionViewController: UIViewController {
    @IBOutlet weak var constraintViewRulesHeight: NSLayoutConstraint!
    @IBOutlet weak var consraintDescriptionBottom: NSLayoutConstraint!
    @IBOutlet weak var cosntraintSecurityTop: NSLayoutConstraint!
    @IBOutlet weak var txtSecurityDeposit: UITextField!
    @IBOutlet weak var constraintAddressTop: NSLayoutConstraint!
    @IBOutlet weak var constraintSdViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintDescriptionTop: NSLayoutConstraint!
    @IBOutlet weak var constraintRulesTop: NSLayoutConstraint!
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var txtViewDescription: UITextView!
    @IBOutlet weak var txtViewRules: UITextView!
    fileprivate var responseData:NSMutableData?
    fileprivate var dataTask:URLSessionDataTask?
    
    
    
    fileprivate let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    fileprivate let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let revealController = revealViewController()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        self.txtViewRules.layer.cornerRadius = 6
        self.txtViewRules.layer.borderColor = UIColor(hexString: "d2d2d2").cgColor
        self.txtViewRules.layer.borderWidth = 1
        
        self.txtViewDescription.layer.cornerRadius = 6
        self.txtViewDescription.layer.borderColor = UIColor(hexString: "d2d2d2").cgColor
        self.txtViewDescription.layer.borderWidth = 1
        
        self.addNextButtonOnKeyboard(self.txtViewRules)
        self.addDoneButtonOnKeyboard(self.txtViewDescription)
        self.addDoneButtonOnKeyboard(self.txtSecurityDeposit)
        
        self.constraintSdViewHeight.constant = 0
        self.consraintDescriptionBottom.constant = 180
        
        if AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Relocating" || AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Ditching" {
            self.cosntraintSecurityTop.constant = 0
            self.constraintSdViewHeight.constant = 0
            self.constraintViewRulesHeight.constant = 0
            self.consraintDescriptionBottom.constant = 230
            
        }
        
//        if UIDevice.current.screenType == .iPhone4 {
//            
//            self.constraintRulesTop.constant = 10
//            self.constraintDescriptionTop.constant = 10
//        }
        
    }
    
    func addNextButtonOnKeyboard(_ view: UIView?)
    {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(btnNextTapped(_:)))
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
    
    func btnNextTapped(_ sender: AnyObject) {
        self.txtViewDescription.becomeFirstResponder()
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
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func previewButtonTapped(_ sender: AnyObject) {

        if AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Renting Out" {
            if Utils.isTextViewEmpty(self.txtViewRules) == true {
                Utils.showOKAlertRO("", message: "Rules are required.", controller: self)
                return
            }
            AppDelegate.returnAppDelegate().userProperty.setObject("0", forKey: "securityDeposits" as NSCopying)
            if (txtSecurityDeposit.text?.characters.count)! > 0 {
                AppDelegate.returnAppDelegate().userProperty.setObject(self.txtSecurityDeposit.text!, forKey: "securityDeposits" as NSCopying)
            }
            
        }
        
        
        
        if Utils.isTextViewEmpty(self.txtViewDescription) == true {
            Utils.showOKAlertRO("", message: "Description is required.", controller: self)
            return
        }
        
        
        //AppDelegate.returnAppDelegate().userProperty.setObject(self.txtAddress.text!, forKey: "address1")
    
        AppDelegate.returnAppDelegate().userProperty.setObject(self.txtViewRules.text!, forKey: "rules" as NSCopying)
        AppDelegate.returnAppDelegate().userProperty.setObject(self.txtViewDescription.text!, forKey: "description" as NSCopying)
        
        let previewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "uclPreviewVC") as! UCLPreviewViewController
        previewController.propertyImages = AppDelegate.returnAppDelegate().userProperty.object(forKey: "propertyImages") as! NSArray
        self.navigationController?.pushViewController(previewController, animated: true)
    }
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension UCLDescriptionViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            self.txtViewRules.becomeFirstResponder()
            return false
        }
        
        textField.resignFirstResponder()
        return true
    }
}

