//
//  DisclosureViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 10/04/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress
protocol DisclosureViewControllerDelegate {
    func didCancelTapped()
    func didAgreeTapped()
    func didAgreeTappedAfterSavingProperty()
}

class DisclosureViewController: UIViewController {
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var viewAgree: UIView!
    @IBOutlet weak var viewNext: UIView!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var btnClickToSign: UIButton!
    @IBOutlet weak var btnAgree: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    var imgCount: Int!
    
    
    var propertyImages: NSArray!
    var delegate: DisclosureViewControllerDelegate?
    var disclosureDocsIds = [AnyObject]()
    var docCount: Int!
    var isSigned: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        imgCount = 0
        self.btnClickToSign.isHidden = true
        isSigned = true
        
        self.segment.selectedSegmentIndex = 1
        
        self.txtFirstName.returnKeyType = .default
        self.txtLastName.returnKeyType = .default
        self.txtEmailAddress.keyboardType = .emailAddress
        
        self.addNextButtonOnKeyboard(self.txtFirstName)
        self.addNextButtonOnKeyboard(self.txtLastName)
        self.addDoneButtonOnKeyboard(self.txtEmailAddress)
        
        let frameView = CGRect(x: 0, y: 0, width: 5, height: 40)
        let viewLeft = UIView(frame: frameView)
        self.txtFirstName.leftView = viewLeft
        self.txtFirstName.leftViewMode = .always
        
        let viewLeftLN = UIView(frame: frameView)
        self.txtLastName.leftView = viewLeftLN
        self.txtLastName.leftViewMode = .always
        
        let viewEmail = UIView(frame: frameView)
        self.txtEmailAddress.leftView = viewEmail
        self.txtEmailAddress.leftViewMode = .always
        
        
        self.viewAgree.isHidden = true
        self.viewNext.isHidden = false
        
        if UserDefaults.standard.object(forKey: "laFN") != nil {
            self.txtFirstName.text = UserDefaults.standard.object(forKey: "laFN") as? String
            self.txtLastName.text = UserDefaults.standard.object(forKey: "laLN") as? String
            self.txtEmailAddress.text = UserDefaults.standard.object(forKey: "laEA") as? String
            self.txtFirstName.isEnabled = false
            self.txtLastName.isEnabled = false
            self.txtEmailAddress.isEnabled = false
        }
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

    
    func addNextButtonOnKeyboard(_ view: UIView?)
    {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(btnNextTapped(_:)))
        let items = [flexSpace, done]
        done.tag = (view?.tag)!
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        if let accessorizedView = view as? UITextView {
            accessorizedView.inputAccessoryView = doneToolbar
        } else if let accessorizedView = view as? UITextField {
            accessorizedView.inputAccessoryView = doneToolbar
        }
        
    }

    func btnNextTapped(_ sender: AnyObject) {
        if sender.tag == 0 {
            self.txtLastName.becomeFirstResponder()
        }
        else if sender.tag == 1 {
            self.txtEmailAddress.becomeFirstResponder()
        }
        else {
            self.txtEmailAddress.resignFirstResponder()
        }
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        AppDelegate.returnAppDelegate().userProperty.setObject("no_agent", forKey: "represented_by" as NSCopying)
        if self.segment.selectedSegmentIndex == 0 {
            AppDelegate.returnAppDelegate().userProperty.setObject("agent", forKey: "represented_by" as NSCopying)
        }

        if UserDefaults.standard.object(forKey: "laFN") == nil {
            
//            if Utils.isTextFieldEmpty(self.txtFirstName) {
//                Utils.showOKAlertRO("", message: "First name is required", controller: self)
//                return
//            }
//
//            if Utils.isTextFieldEmpty(self.txtLastName) {
//                Utils.showOKAlertRO("", message: "Last name is required", controller: self)
//                return
//            }
//
//            if Utils.isTextFieldEmpty(self.txtEmailAddress) {
//                Utils.showOKAlertRO("", message: "Email address is required", controller: self)
//                return
//            }
//
//
//            UserDefaults.standard.set(self.txtFirstName.text!, forKey: "laFN")
//            UserDefaults.standard.set(self.txtLastName.text!, forKey: "laLN")
//            UserDefaults.standard.set(self.txtEmailAddress.text!, forKey: "laEA")
//            UserDefaults.standard.synchronize()
            
            self.saveUserGeneralInfo()
        }
        else {
            KVNProgress.show()
            self.getListingAgreeemntDocs(propertyId: String(AppDelegate.returnAppDelegate().newlyCreatedPropertyId))
        }
    }
    
    @IBAction func ditchButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        let segment = sender as! UISegmentedControl
        if segment.selectedSegmentIndex == 0 {
            self.viewAgree.isHidden = false
            self.viewNext.isHidden = true
            self.getSignedDocs()
        }
        else {
            self.viewAgree.isHidden = true
            self.viewNext.isHidden = false
            self.btnClickToSign.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    @IBAction func clickToSignButtonTapped(_ sender: Any) {
        
        //self.getDisclosureDocs()
        if segment.selectedSegmentIndex == 0 {
            self.signDisclosureDocs(docId: self.disclosureDocsIds[self.docCount] as! String)
        }
        else {
            if UserDefaults.standard.object(forKey: "laFN") != nil {
                //self.saveProperty()
                self.getListingAgreeemntDocs(propertyId: String(AppDelegate.returnAppDelegate().newlyCreatedPropertyId))
            }
            else {
                self.saveUserGeneralInfo()
            }
        }
    }
    
    @IBAction func agreeButtonTapped(_ sender: Any) {
        
        if self.segment.selectedSegmentIndex == 0 {
            if self.disclosureDocsIds.count > 0 {
                if UserDefaults.standard.object(forKey: "laFN") != nil {
                    self.signDisclosureDocs(docId: self.disclosureDocsIds[self.docCount] as! String)
                }
                else {
                    self.saveUserGeneralInfo()
                }
            }
            else {
                if UserDefaults.standard.object(forKey: "laFN") != nil {
                    if AppDelegate.returnAppDelegate().dwollaCustomerStatus != nil {
                        
                        if AppDelegate.returnAppDelegate().paymentMethods.count > 0 {
                            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myDitchVC") as! MyDitchViewController
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                        else {
                            let paymentMethodVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "paymentMethodsVC") as! PaymentMethodsViewController
                            self.navigationController?.pushViewController(paymentMethodVC, animated: true)
                        }
                    }
                    else {
                        let paymentMethodVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FNViewController") as! FNViewController
                        paymentMethodVC.isFromDitch = true
                        self.navigationController?.pushViewController(paymentMethodVC, animated: true)
                    }
                }
                else {
                    self.saveUserGeneralInfo()
                }
            }
        }
        else {
            if UserDefaults.standard.object(forKey: "laFN") != nil {
                //self.saveProperty()
                self.getListingAgreeemntDocs(propertyId: String(AppDelegate.returnAppDelegate().newlyCreatedPropertyId))
            }
            else {
                self.saveUserGeneralInfo()
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
//        dismiss(animated: true, completion: {
//            if self.delegate != nil {
//                self.delegate?.didCancelTapped()
//            }
//        })
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
}

extension DisclosureViewController {
    
    func getSignedListingAgreements() -> Void {
        
        var strURL = ""
        
        let state = AppDelegate.returnAppDelegate().userProperty["state"] as! String
        
//        if UserDefaults.standard.object(forKey: "token") != nil {
//            let token = UserDefaults.standard.object(forKey: "token") as! String
//            strURL = "\(APIConstants.BasePath)/api/getsigneddocumentation?token=\(token)&type=listing_agreement&target_user_cid=\(targeted_cid)&target_property_id=\(propertyId)&state=\(state)&paginated=0"
//        }
        
        
        
        
        
        
        DispatchQueue.main.async(execute: {
            KVNProgress.show(withStatus: "Getting Listing Agreements")
        })
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let tempData = json as? NSDictionary
                    
                    let isSuccess = tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        let _utils = Utils()
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        return
                    }
                    
                    let documents = (tempData!["data"] as! NSDictionary)["data"] as! NSArray
                    
                    if documents.count > 0 {
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                        })
                        
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            
                            self.getDisclosureDocs()
                        })
                    }
                    
                }
                catch {
                    
                }
            }
            else {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                    Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                })
                
                
            }
            }.resume()
        
    }
    
    func getSignedDocs() -> Void {
        
        var strURL = ""
        
        let state = AppDelegate.returnAppDelegate().userProperty["state"] as! String
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = "\(APIConstants.BasePath)/api/getsigneddocumentation?token=\(token)&type=disclosure&state=\(state)&represented_by=agent&paginated=0"
        }
        
        
        
        
        
        
        DispatchQueue.main.async(execute: {
            KVNProgress.show(withStatus: "Getting Documents")
        })
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let tempData = json as? NSDictionary
                    
                    let isSuccess = tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        let _utils = Utils()
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        return
                    }
                    
                    let documents = (tempData!["data"] as! NSDictionary)["data"] as! NSArray
                    
                    if documents.count > 0 {
                        self.btnClickToSign.isHidden = true
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                        })
                        
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            self.btnClickToSign.isHidden = true
                            self.getDisclosureDocs()
                        })
                    }
                    
                }
                catch {
                    
                }
            }
            else {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                    Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                })

                
            }
            }.resume()

    }
    
    func saveUserGeneralInfo() -> Void {
        
        if UserDefaults.standard.object(forKey: "laFN") == nil {
            
            if Utils.isTextFieldEmpty(self.txtFirstName) {
                Utils.showOKAlertRO("", message: "First name is required", controller: self)
                return
            }
            
            if Utils.isTextFieldEmpty(self.txtLastName) {
                Utils.showOKAlertRO("", message: "Last name is required", controller: self)
                return
            }
            
            if Utils.isTextFieldEmpty(self.txtEmailAddress) {
                Utils.showOKAlertRO("", message: "Email address is required", controller: self)
                return
            }
            
            
            
            UserDefaults.standard.set(self.txtFirstName.text!, forKey: "laFN")
            UserDefaults.standard.set(self.txtLastName.text!, forKey: "laLN")
            UserDefaults.standard.set(self.txtEmailAddress.text!, forKey: "laEA")
            UserDefaults.standard.synchronize()
        }
        
        
        
        KVNProgress.show(withStatus: "Saving General Info")
        
        var token = ""
        let strURL = "\(APIConstants.BasePath)/api/saveusergeneral"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
        }
        
        
        /*var address2 = ""
         if self.txtAddress2.text != nil {
         address2 = self.txtAddress2.text!
         }*/
        
        
        
        
        let paramDict: NSDictionary = ["token": token, "first_name": self.txtFirstName.text!, "last_name": self.txtLastName.text!, "email": self.txtEmailAddress.text!, "pref_email": "1", "pref_sms": "1", "pref_voice": "0", "provider": "dts"]
        
        
        do {
            let jsonParamsData = try JSONSerialization.data(withJSONObject: paramDict, options: [])
            
            let url = URL(string: strURL)
            var request = URLRequest(url: url!)
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            request.httpBody = jsonParamsData
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil {
                    do {
                        
                        let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                        let tempData = json as? NSDictionary
                        
                        let isSuccess = tempData!["success"] as! Bool
                        
                        if isSuccess == false {
                            DispatchQueue.main.async(execute: {
                                KVNProgress.dismiss()
                            })
                            DispatchQueue.main.async(execute: {
                                KVNProgress.dismiss()
                                let _utils = Utils()
                                _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                                return
                            })
                            
                        }
                        
                        let currentDate = Date()
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        DispatchQueue.main.async(execute: {
                            if self.segment.selectedSegmentIndex == 0 {
                                if self.disclosureDocsIds.count > 0 {
                                    self.signDisclosureDocs(docId: self.disclosureDocsIds[self.docCount] as! String)
                                }
                                else {
                                    DispatchQueue.main.async(execute: {
                                        KVNProgress.dismiss()
                                    })
                                    if AppDelegate.returnAppDelegate().dwollaCustomerStatus != nil {
                                        
                                        if AppDelegate.returnAppDelegate().paymentMethods.count > 0 {
                                            DispatchQueue.main.async(execute: {
                                                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myDitchVC") as! MyDitchViewController
                                                self.navigationController?.pushViewController(controller, animated: true)
                                            })
                                        }
                                        else {
                                            DispatchQueue.main.async(execute: {
                                                let paymentMethodVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "paymentMethodsVC") as! PaymentMethodsViewController
                                                self.navigationController?.pushViewController(paymentMethodVC, animated: true)
                                            })
                                        }
                                    }
                                    else {
                                        DispatchQueue.main.async(execute: {
                                            let paymentMethodVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FNViewController") as! FNViewController
                                            paymentMethodVC.isFromDitch = true
                                            self.navigationController?.pushViewController(paymentMethodVC, animated: true)
                                        })
                                    }
                                }
                            }
                            else {
                                self.getListingAgreeemntDocs(propertyId: String(AppDelegate.returnAppDelegate().newlyCreatedPropertyId))
                            }
                        })
    
                    }
                    catch {
                        
                    }
                    
                    
                }
                else {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                    
                }
                }.resume()
        }
        catch {
            
        }
        
    }
    
    func sendConfirmation() -> Void {
        
        
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/sendconfirmation?token=\(token)&type=confirm_email")
        }
        
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let tempData = json as? NSDictionary
                    
                    
                    let isSuccess = tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        
                        return
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.saveProperty()
                    })
                    
                    //self.getUserPaymentInfo()
                }
                catch {
                    
                }
            }
            else {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                })
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                
            }
            }.resume()
    }
    
    func getListingAgreeemntDocs(propertyId: String) {
        
        docCount = 0
        let targeted_cid = UserDefaults.standard.object(forKey: "userCID") as! String
        //self.btnClickToSign.isHidden = true
        var strURL = ""
        //let address = AppDelegate.returnAppDelegate().userProperty["state"] as! String
        let state = AppDelegate.returnAppDelegate().userProperty["state"] as! String
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = "\(APIConstants.BasePath)/api/getdocumentation?token=\(token)&type=listing_agreement&target_user_cid=\(targeted_cid)&target_property_id=\(propertyId)&state=\(state)&paginated=0"
        }
        
        
        
        
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let tempData = json as? NSDictionary
                    
                    let isSuccess = tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        })
                        
                    }
                    
                    let documents = (tempData!["data"] as! NSDictionary)["data"] as! NSArray
                    
                    if documents.count > 0 {
                        DispatchQueue.main.async(execute: {
                            self.btnClickToSign.isHidden = true
                        })
                        
                        self.isSigned = false
                        for doc in documents {
                            self.disclosureDocsIds.append(String((doc as! NSDictionary)["id"] as! Int) as AnyObject)
                            
                        }
                        
                        DispatchQueue.main.async(execute: {
                            if self.segment.selectedSegmentIndex == 1 {
                                //self.signListingAgreement(docId: self.disclosureDocsIds[self.docCount] as! String, propertyId: propertyId)
                                let dictDoc = documents[0] as! [String: AnyObject]
                                let laPreviewVC = self.storyboard?.instantiateViewController(withIdentifier: "laPreviewVC") as! ListingAgreementPreviewViewController
                                laPreviewVC.propertyId = propertyId
                                laPreviewVC.dictDoc = dictDoc
                                laPreviewVC.pdfLink = dictDoc["url"] as! String
                                laPreviewVC.listingAgreementDocIds = self.disclosureDocsIds
                                self.navigationController?.pushViewController(laPreviewVC, animated: true)
                            }
                        })
                        
                    }
                    else {
                        //self.isSigned = true
                        let alert = UIAlertController(title: "", message: "Property Saved - Unsupported State", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                            DispatchQueue.main.async(execute: {
                                if AppDelegate.returnAppDelegate().dwollaCustomerStatus != nil {
                                    
                                    if AppDelegate.returnAppDelegate().paymentMethods.count > 0 {
                                        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myDitchVC") as! MyDitchViewController
                                        self.navigationController?.pushViewController(controller, animated: true)
                                    }
                                    else {
                                        let paymentMethodVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "paymentMethodsVC") as! PaymentMethodsViewController
                                        self.navigationController?.pushViewController(paymentMethodVC, animated: true)
                                    }
                                }
                                else {
                                    let paymentMethodVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FNViewController") as! FNViewController
                                    paymentMethodVC.isFromDitch = true
                                    self.navigationController?.pushViewController(paymentMethodVC, animated: true)
                                }
                            })
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                }
                catch {
                    
                }
            }
            else {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                })
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                
            }
            }.resume()
        
    }
    
    func getDisclosureDocs() {
        
        docCount = 0
        self.btnClickToSign.isHidden = true
        var strURL = ""
        //let address = AppDelegate.returnAppDelegate().userProperty["state"] as! String
        let state = AppDelegate.returnAppDelegate().userProperty["state"] as! String
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = "\(APIConstants.BasePath)/api/getdocumentation?token=\(token)&type=disclosure&state=\(state)&represented_by=agent&paginated=0"
        }
        
        
        
        DispatchQueue.main.async(execute: {
            KVNProgress.show(withStatus: "Getting Documents")
        })
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let tempData = json as? NSDictionary
                    
                    let isSuccess = tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        let _utils = Utils()
                        _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        return
                    }
                   
                    let documents = (tempData!["data"] as! NSDictionary)["data"] as! NSArray
                    
                    if documents.count > 0 {
                        DispatchQueue.main.async(execute: {
                            self.btnClickToSign.isHidden = true
                        })
                        
                        self.isSigned = false
                        for doc in documents {
                            self.disclosureDocsIds.append(String((doc as! NSDictionary)["id"] as! Int) as AnyObject)
                        }
                    }
                    else {
                        self.isSigned = true
                    }
                    
                }
                catch {
                    
                }
            }
            else {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                })
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                
            }
            }.resume()

    }
    
    func signDisclosureDocs(docId: String) {
        var strURL = ""
        
        
        
        DispatchQueue.main.async(execute: {
            KVNProgress.show(withStatus: "Getting Documents")
        })
        
        let token = UserDefaults.standard.object(forKey: "token") as! String
        strURL = "\(APIConstants.BasePath)/api/signdocumentation"
        
        let url = URL(string: strURL)
        
        
        let strParams = "token=\(token)&documentation_id=\(docId)"
        
        
        let paramData = strParams.data(using: String.Encoding.ascii, allowLossyConversion: true)!
        
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.httpBody = paramData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let tempData = json as? NSDictionary
                    
                    let isSuccess = tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        let _utils = Utils()
                        
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        return
                    }
                    
                    self.docCount = self.docCount + 1
                    if self.docCount < self.disclosureDocsIds.count {
                        self.signDisclosureDocs(docId: self.disclosureDocsIds[self.docCount] as! String)
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
//                            self.isSigned = true
//                            self.btnClickToSign.setTitle("Signed", for: .normal)
                            if AppDelegate.returnAppDelegate().dwollaCustomerStatus != nil {
                                
                                if AppDelegate.returnAppDelegate().paymentMethods.count > 0 {
                                    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myDitchVC") as! MyDitchViewController
                                    self.navigationController?.pushViewController(controller, animated: true)
                                }
                                else {
                                    let paymentMethodVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "paymentMethodsVC") as! PaymentMethodsViewController
                                    self.navigationController?.pushViewController(paymentMethodVC, animated: true)
                                }
                            }
                            else {
                                let paymentMethodVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FNViewController") as! FNViewController
                                paymentMethodVC.isFromDitch = true
                                self.navigationController?.pushViewController(paymentMethodVC, animated: true)
                            }
                        })
                    }
                    
                    
                }
                catch {
                    
                }
            }
            else {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                })
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                
            }
            }.resume()
    }
    
    func signListingAgreement(docId: String, propertyId: String) {
        var strURL = ""
        
        
        
        DispatchQueue.main.async(execute: {
            KVNProgress.show(withStatus: "Signing Document")
        })
        
        let token = UserDefaults.standard.object(forKey: "token") as! String
        strURL = "\(APIConstants.BasePath)/api/signdocumentation"
        
        let url = URL(string: strURL)
        
        let targeted_cid = UserDefaults.standard.object(forKey: "userCID") as! String
        
        let strParams = "token=\(token)&documentation_id=\(docId)&target_property_id=\(propertyId)&target_user_cid=\(targeted_cid)"
        
        
        let paramData = strParams.data(using: String.Encoding.ascii, allowLossyConversion: true)!
        
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.httpBody = paramData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let tempData = json as? NSDictionary
                    
                    let isSuccess = tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        let _utils = Utils()
                        
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        return
                    }
                    
                    self.docCount = self.docCount + 1
                    if self.docCount < self.disclosureDocsIds.count {
                        self.signListingAgreement(docId: self.disclosureDocsIds[self.docCount] as! String, propertyId: propertyId)
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
//                            self.isSigned = true
//                            self.btnClickToSign.setTitle("Signed", for: .normal)
                            if AppDelegate.returnAppDelegate().dwollaCustomerStatus != nil {
                                
                                if AppDelegate.returnAppDelegate().paymentMethods.count > 0 {
                                    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myDitchVC") as! MyDitchViewController
                                    self.navigationController?.pushViewController(controller, animated: true)
                                }
                                else {
                                    let paymentMethodVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "paymentMethodsVC") as! PaymentMethodsViewController
                                    self.navigationController?.pushViewController(paymentMethodVC, animated: true)
                                }
                            }
                            else {
                                let paymentMethodVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FNViewController") as! FNViewController
                                paymentMethodVC.isFromDitch = true
                                self.navigationController?.pushViewController(paymentMethodVC, animated: true)
                            }
                        })
                    }
                    
                    
                }
                catch {
                    
                }
            }
            else {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                })
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                
            }
            }.resume()
    }
    
    func updateProperty(propertyId: String) -> Void {
        
        //KVNProgress.show()
        
        var token = ""
        
        var strURL = "\(APIConstants.BasePath)/api/savepropertyfield"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(strURL)?token=\(token)")
        }
        
        
        
        let relocation_target_price = AppDelegate.returnAppDelegate().userProperty["relocationTargetPrice"] as? String ?? ""
        let relocation_target_bed = AppDelegate.returnAppDelegate().userProperty["relocationTargetBed"] as? String ?? ""
        let relocation_target_bath = AppDelegate.returnAppDelegate().userProperty["relocationTargetBath"] as? String ?? ""
        
        
        let body: NSDictionary = ["property_id": propertyId,
                                  "data": [["field": "status", "value": "active"],
                                           ["field": "relocation_target_price", "value": relocation_target_price],
                                           ["field": "relocation_target_bed", "value": relocation_target_bed],
                                           ["field": "relocation_target_bath", "value": relocation_target_bath]
            ]
        ]
        
        
        
        
        //KVNProgress.show()
        
        do {
            let jsonParamsData = try JSONSerialization.data(withJSONObject: body, options: [])
            
            let url = URL(string: strURL)
            var request = URLRequest(url: url!)
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            request.httpBody = jsonParamsData
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil {
                    do {
                        
                        let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                        let tempData = json as? NSDictionary
                        
                        let isSuccess = tempData!["success"] as! Bool
                        
                        if isSuccess == false {
                            
                            DispatchQueue.main.async(execute: {
                                KVNProgress.dismiss()
                                let _utils = Utils()
                                _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            })
                            
                            return
                        }
                        
                        
                        DispatchQueue.main.async(execute: {
                            self.getListingAgreeemntDocs(propertyId: propertyId)
                        })
                        
                        
                    }
                    catch {
                        
                    }
                }
                else {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                        Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                    })
                    
                }
                return()
                }.resume()
        }
        catch {
            
        }
        
    }
    
    func saveProperty() -> Void {
        
        KVNProgress.show(withStatus: "Saving Property")
        
        var token = ""
        var strURL = "\(APIConstants.BasePath)/api/addproperty"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(strURL)?token=\(token)")
        }
        
        //var uclClass = ""
        var uclType = ""
        //let uclGuests = ""
        var beds = ""
        var baths = ""
        var pTitle = ""
        var pPrice = ""
        var pDescription = ""
        
        //uclClass = AppDelegate.returnAppDelegate().userProperty["uclClass"] as! String
        uclType = AppDelegate.returnAppDelegate().userProperty["uclType"] as! String
        
        beds = AppDelegate.returnAppDelegate().userProperty["beds"] as! String
        baths = AppDelegate.returnAppDelegate().userProperty["baths"] as! String
        pTitle = AppDelegate.returnAppDelegate().userProperty["title"] as! String
        pPrice = AppDelegate.returnAppDelegate().userProperty["price"] as! String
        pDescription = AppDelegate.returnAppDelegate().userProperty["description"] as! String
        
        let address1 = AppDelegate.returnAppDelegate().userProperty["address1"] as! String
        let zip = AppDelegate.returnAppDelegate().userProperty["zip"] as! String
        let city = AppDelegate.returnAppDelegate().userProperty["city"] as! String
        let state = AppDelegate.returnAppDelegate().userProperty["state"] as! String
        let country = AppDelegate.returnAppDelegate().userProperty["country"] as! String
        let security = AppDelegate.returnAppDelegate().userProperty["securityDeposits"] as! String
        let rules = AppDelegate.returnAppDelegate().userProperty["rules"] as! String
        let lotSize = AppDelegate.returnAppDelegate().userProperty["lotSize"] as? String ?? "500"
        let relocation_target_city = AppDelegate.returnAppDelegate().userProperty["relo_target_city"] as? String ?? ""
        let relocation_target_state = AppDelegate.returnAppDelegate().userProperty["relo_target_state"] as? String ?? ""
        let representedBy = AppDelegate.returnAppDelegate().userProperty["represented_by"] as? String ?? "no_agent"
        
        let body: NSDictionary = ["type": uclType,
                                  "title": pTitle,
                                  "listing_category": "rent",
                                  "description": pDescription,
                                  "status": "active",
                                  "year_built": "2016",
                                  "lot_size": lotSize,
                                  "lease_price": pPrice,
                                  "security_deposit": security,
                                  "details_rules": rules,
                                  "cat": 0,
                                  "dog": 0,
                                  "bed": beds,
                                  "bath": baths,
                                  "price": pPrice,
                                  "term": "month",
                                  "lease_term": "short",
                                  "relocation_target_location_city": relocation_target_city,
                                  "relocation_target_location_state": relocation_target_state,
                                  "address1": address1,
                                  "address2": "",
                                  "zip": zip,
                                  "city": city,
                                  "state_or_province": state,
                                  "country": country,
                                  "unit_amen_ac": 0,
                                  "unit_amen_parking_reserved": 0,
                                  "unit_amen_balcony": 0,
                                  "unit_amen_deck": 0,
                                  "unit_amen_ceiling_fan": 0,
                                  "unit_amen_dishwasher": 0,
                                  "unit_amen_fireplace": 0,
                                  "unit_amen_furnished": 0,
                                  "unit_amen_laundry": 0,
                                  "unit_amen_floor_carpet": 0,
                                  "unit_amen_floor_hard_wood": 0,
                                  "unit_amen_carpet": 0,
                                  "build_amen_fitness_center": 0,
                                  "build_amen_biz_center": 0,
                                  "build_amen_concierge": 0,
                                  "build_amen_doorman": 0,
                                  "build_amen_dry_cleaning": 0,
                                  "build_amen_elevator": 0,
                                  "build_amen_park_garage": 0,
                                  "build_amen_swim_pool": 0,
                                  "build_amen_secure_entry": 0,
                                  "build_amen_storage": 0,
                                  "keywords": "keyword1, keyword2",
                                  "represented_by": representedBy
        ]
        
        
        
        
        do {
            let jsonParamsData = try JSONSerialization.data(withJSONObject: body, options: [])
            
            let url = URL(string: strURL)
            var request = URLRequest(url: url!)
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            request.httpBody = jsonParamsData
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil {
                    do {
                        
                        let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                        let tempData = json as? NSDictionary
                        
                        let isSuccess = tempData!["success"] as! Bool
                        
                        if isSuccess == false {
                            DispatchQueue.main.async(execute: {
                                KVNProgress.dismiss()
                                let _utils = Utils()
                                _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            })
                            
                            return
                        }
                        
                        let propertyId = tempData!["data"] as! Int
                        let strPropertyId = String(propertyId)
                        AppDelegate.returnAppDelegate().newlyCreatedPropertyId = propertyId
                        
                        let dictParams = ["token": token, "property_id": strPropertyId]
                        
                        for img in self.propertyImages {
                            
                            let pImage = img as! UIImage
                            
                            self.uploadMultipartImage(pImage, dictParams: dictParams as NSDictionary)
                        }
                        
                    }
                    catch {
                        
                    }
                }
                else {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                        Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                    })
                    
                }
                return()
                }.resume()
        }
        catch {
            
        }
        
    }
    
    func imageWithSize(_ image: UIImage, size:CGSize) -> UIImage
    {
        var scaledImageRect = CGRect.zero;
        
        let aspectWidth:CGFloat = size.width / image.size.width;
        let aspectHeight:CGFloat = size.height / image.size.height;
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight);
        
        scaledImageRect.size.width = image.size.width * aspectRatio;
        scaledImageRect.size.height = image.size.height * aspectRatio;
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0;
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0;
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        
        image.draw(in: scaledImageRect);
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return scaledImage!;
    }
    
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func uploadMultipartImage(_ image: UIImage, dictParams: NSDictionary) -> Void {
        let myUrl = URL(string: "\(APIConstants.BasePath)/api/addpropertyimg");
        //let myUrl = NSURL(string: "http://www.boredwear.com/utils/postImage.php");
        let resizedImage = self.resizeImage(image, newWidth: 1000)
        var request = URLRequest(url:myUrl!);
        request.httpMethod = "POST";
        
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let imageData = UIImageJPEGRepresentation(resizedImage, 0.75)
        
        if(imageData==nil)  { return; }
        
        request.httpBody = createBodyWithParameters(dictParams as? [String : String], filePathKey: "image", imageDataKey: imageData!, boundary: boundary)
        
        
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            
            
            if error != nil {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                    Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                })
                
                return
            }
            
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                let tempData = json as? NSDictionary
                
                if tempData!["error"] as? String != nil {
                    let error = tempData!["error"] as! String
                    let _utils = Utils()
                    DispatchQueue.main.async(execute: {
                        _utils.showOKAlert("Error:", message: error, controller: self, isActionRequired: false)
                    })
                    
                    return
                }
                
                let isSuccess = tempData!["success"] as! Bool
                
                if isSuccess == false {
                    
                    let _utils = Utils()
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                        _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                    })
                    
                    
                    return
                }
                
                self.imgCount = self.imgCount + 1
                
                if self.imgCount == self.propertyImages.count {
                    DispatchQueue.main.async(execute: {
                        
                        self.updateProperty(propertyId: String(AppDelegate.returnAppDelegate().newlyCreatedPropertyId))
                        //                        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myDitchVC") as! MyDitchViewController
                        //                        self.navigationController?.pushViewController(controller, animated: true)
                    })
                }
                
                
                
            }catch
            {
                print(error)
            }
            
        })
        
        task.resume()
    }
    
    
    func createBodyWithParameters(_ parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        let body = NSMutableData()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "propertyFile.jpg"
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body as Data
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
}

extension DisclosureViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField.tag == 0 {
//            self.txtLastName.becomeFirstResponder()
//            return false
//        }
//        else if textField.tag == 1 {
//            self.txtEmailAddress.becomeFirstResponder()
//            return false
//        }
        
        textField.resignFirstResponder()
        return true
    }
}
