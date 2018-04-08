//
//  FNViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 10/02/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class FNViewController: UIViewController {

    
    @IBOutlet weak var viewOnboarding: UIView!
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var btnSideMenu: UIButton!
    fileprivate var responseData:NSMutableData?
    fileprivate var dataTask:URLSessionDataTask?
    
    fileprivate let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    fileprivate let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    
    var page = 0
    var dob: String?
    var customPicker: CustomPickerView?
    
    var userGeneralInfo: NSMutableDictionary?
    var dictUserGeneralReadInfo: NSDictionary?
    var isFromDitch: Bool?
    var isFromBooking: Bool?
    
    @IBAction func startNowButtonTapped(_ sender: Any) {
        self.detailCollectionView.isHidden = false
        self.detailCollectionView.reloadData()
        self.viewOnboarding.isHidden = true
        UserDefaults.standard.set(true, forKey: "isOBLoaded")
        UserDefaults.standard.synchronize()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let revealController = revealViewController()
        
        if UserDefaults.standard.bool(forKey: "isOBLoaded") == false {
            self.detailCollectionView.isHidden = true
            self.viewOnboarding.isHidden = false
            
        }
        else {
            self.viewOnboarding.isHidden = true
            self.detailCollectionView.isHidden = false
        }

        
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        self.userGeneralInfo = NSMutableDictionary()
        
        if self.isFromDitch != nil {
            let firstName = UserDefaults.standard.object(forKey: "laFN") as! String
            let lastName = UserDefaults.standard.object(forKey: "laLN") as! String
            let emailAddress = UserDefaults.standard.object(forKey: "laEA") as! String
            
            self.userGeneralInfo?.setObject(firstName, forKey: "firstName" as NSCopying)
            self.userGeneralInfo?.setObject(lastName, forKey: "lastName" as NSCopying)
            self.userGeneralInfo?.setObject(emailAddress, forKey: "emailAddress" as NSCopying)
        
        }
        
        if self.dictUserGeneralReadInfo != nil {
            self.userGeneralInfo?.setObject(self.dictUserGeneralReadInfo!["first_name"] as! String, forKey: "firstName" as NSCopying)
            self.userGeneralInfo?.setObject(self.dictUserGeneralReadInfo!["last_name"] as! String, forKey: "lastName" as NSCopying)
            self.userGeneralInfo?.setObject(self.dictUserGeneralReadInfo!["address1"] ?? "", forKey: "address" as NSCopying)
            self.userGeneralInfo?.setObject(self.dictUserGeneralReadInfo!["city"] ?? "", forKey: "city" as NSCopying)
            self.userGeneralInfo?.setObject(self.dictUserGeneralReadInfo!["state"] ?? "", forKey: "state" as NSCopying)
            self.userGeneralInfo?.setObject(self.dictUserGeneralReadInfo!["zip"] ?? "", forKey: "zip" as NSCopying)
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(FNViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(FNViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        if page > 0 {
            page = page - 1
            print(page)
            let indexPath = IndexPath(item: page, section: 0)
            self.detailCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }

}

extension FNViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isFromDitch != nil {
            return 3
        }
        if self.dictUserGeneralReadInfo != nil {
            return 6
        }
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.isFromDitch != nil {
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addressCell", for: indexPath) as! MyDetailCollectionViewCell
                
                cell.lblCaption.text = "ADDRESS"
                configureTextField(cell)
                handleTextFieldInterfaces(cell)
                
                cell.txtAddress.layer.borderColor = UIColor(hexString: "010101").cgColor
                cell.txtAddress.layer.borderWidth = 1
                let leftViewFrame = CGRect(x: 0, y: 0, width: 5, height: cell.txtAddress.frame.height)
                let leftSubview = UIView(frame: leftViewFrame)
                cell.txtAddress.leftViewMode = .always
                cell.txtAddress.leftView = leftSubview
                cell.txtAddress.tag = indexPath.item
                cell.txtAddress.minimumFontSize = 8
                cell.txtAddress.text = ""
                cell.txtAddress.returnKeyType = .next
                self.addNextButtonOnKeyboard(cell.txtAddress)
            
                cell.txtAddress.keyboardType = .emailAddress
                cell.btnNext.isHidden = false
                //cell.btnNext.setTitle("SUBMIT", forState: .Normal)
                cell.btnNext.addTarget(self, action: #selector(FNViewController.sendToNext), for: .touchUpInside)
                //self.showDatePicker()
                if UIDevice.current.screenType == .iPhone4 {
                    cell.topConstraint.constant = 5
                }
                print("address called")
                return cell
            }
            else if indexPath.item == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailCell", for: indexPath) as! MyDetailCollectionViewCell
                cell.txtField.delegate = self
                cell.txtField.layer.borderColor = UIColor(hexString: "010101").cgColor
                cell.txtField.layer.borderWidth = 1
                let leftViewFrame = CGRect(x: 0, y: 0, width: 5, height: cell.txtField.frame.height)
                let leftSubview = UIView(frame: leftViewFrame)
                cell.txtField.leftViewMode = .always
                cell.txtField.leftView = leftSubview
                cell.txtField.tag = indexPath.item
                cell.btnNext.isHidden = true
                cell.lblCaption.text = "DOB"
                cell.btnNext.isHidden = false
                cell.btnNext.addTarget(self, action: #selector(FNViewController.sendToNext), for: .touchUpInside)
                cell.txtField.returnKeyType = .default
                cell.txtField.text = ""
                //cell.txtField.becomeFirstResponder()
                if UIDevice.current.screenType == .iPhone4 {
                    cell.topConstraint.constant = 5
                }
                print("cell called")
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ssnCell", for: indexPath) as! MyDetailCollectionViewCell
                cell.lblCaption.text = "LAST 4 SSN"
                cell.txtSSN.delegate = self
                cell.txtSSN.layer.borderColor = UIColor(hexString: "010101").cgColor
                cell.txtSSN.layer.borderWidth = 1
                let leftViewFrame = CGRect(x: 0, y: 0, width: 5, height: cell.txtSSN.frame.height)
                let leftSubview = UIView(frame: leftViewFrame)
                cell.txtSSN.leftViewMode = .always
                cell.txtSSN.leftView = leftSubview
                cell.txtSSN.tag = indexPath.item
                
                cell.txtSSN.setMask("{dddd}", withMaskTemplate: "####")
                
                cell.txtSSN.keyboardType = .numberPad
                
                self.addDoneButtonOnKeyboard(cell.txtSSN)
                
                cell.btnNext.isHidden = false
                cell.btnNext.setTitle("SUBMIT", for: UIControlState())
                cell.btnNext.addTarget(self, action: #selector(FNViewController.submitButtonTapped), for: .touchUpInside)
                print("address called")
                if UIDevice.current.screenType == .iPhone4 {
                    cell.topConstraint.constant = 5
                }
                return cell
            }

        }
        if self.dictUserGeneralReadInfo != nil {
            if indexPath.row == 3 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addressCell", for: indexPath) as! MyDetailCollectionViewCell
                
                cell.lblCaption.text = "ADDRESS"
                configureTextField(cell)
                handleTextFieldInterfaces(cell)
                
                cell.txtAddress.layer.borderColor = UIColor(hexString: "010101").cgColor
                cell.txtAddress.layer.borderWidth = 1
                let leftViewFrame = CGRect(x: 0, y: 0, width: 5, height: cell.txtAddress.frame.height)
                let leftSubview = UIView(frame: leftViewFrame)
                cell.txtAddress.leftViewMode = .always
                cell.txtAddress.leftView = leftSubview
                cell.txtAddress.tag = indexPath.item
                cell.txtAddress.minimumFontSize = 8
                cell.txtAddress.text = ""
                cell.txtAddress.returnKeyType = .next
                self.addNextButtonOnKeyboard(cell.txtAddress)
                cell.txtAddress.keyboardType = .emailAddress
                cell.txtAddress.text = self.dictUserGeneralReadInfo!["address1"] as? String
                cell.btnNext.isHidden = false
                //cell.btnNext.setTitle("SUBMIT", forState: .Normal)
                cell.btnNext.addTarget(self, action: #selector(FNViewController.sendToNext), for: .touchUpInside)
                //self.showDatePicker()
                if UIDevice.current.screenType == .iPhone4 {
                    cell.topConstraint.constant = 5
                }
                print("address called")
                return cell
            }
            else if indexPath.item == 5 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ssnCell", for: indexPath) as! MyDetailCollectionViewCell
                cell.lblCaption.text = "LAST 4 SSN"
                cell.txtSSN.delegate = self
                cell.txtSSN.layer.borderColor = UIColor(hexString: "010101").cgColor
                cell.txtSSN.layer.borderWidth = 1
                let leftViewFrame = CGRect(x: 0, y: 0, width: 5, height: cell.txtSSN.frame.height)
                let leftSubview = UIView(frame: leftViewFrame)
                cell.txtSSN.leftViewMode = .always
                cell.txtSSN.leftView = leftSubview
                cell.txtSSN.tag = indexPath.item
                
                cell.txtSSN.setMask("{dddd}", withMaskTemplate: "####")
    
                cell.txtSSN.keyboardType = .numberPad
                
                self.addDoneButtonOnKeyboard(cell.txtSSN)
                
                cell.btnNext.isHidden = false
                cell.btnNext.setTitle("SUBMIT", for: UIControlState())
                cell.btnNext.addTarget(self, action: #selector(FNViewController.submitButtonTapped), for: .touchUpInside)
                print("address called")
                if UIDevice.current.screenType == .iPhone4 {
                    cell.topConstraint.constant = 5
                }
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailCell", for: indexPath) as! MyDetailCollectionViewCell
                cell.txtField.delegate = self
                cell.txtField.layer.borderColor = UIColor(hexString: "010101").cgColor
                cell.txtField.layer.borderWidth = 1
                let leftViewFrame = CGRect(x: 0, y: 0, width: 5, height: cell.txtField.frame.height)
                let leftSubview = UIView(frame: leftViewFrame)
                cell.txtField.leftViewMode = .always
                cell.txtField.leftView = leftSubview
                cell.txtField.tag = indexPath.item
                cell.btnNext.isHidden = true
                cell.txtField.text = ""
                if indexPath.item == 0 {
                    cell.lblCaption.text = "FIRST NAME (legal)"
                    cell.txtField.keyboardType = .emailAddress
                    cell.txtField.text = self.dictUserGeneralReadInfo!["first_name"] as? String
                    self.addNextButtonOnKeyboard(cell.txtField)
                }
                else if indexPath.item == 1 {
                    cell.lblCaption.text = "LAST NAME (legal)"
                    cell.txtField.keyboardType = .emailAddress
                    cell.txtField.text = self.dictUserGeneralReadInfo!["last_name"] as? String
                    self.addNextButtonOnKeyboard(cell.txtField)
                }
                else if indexPath.item == 2 {
                    cell.lblCaption.text = "EMAIL"
                    cell.txtField.keyboardType = .emailAddress
                    
                    cell.txtField.text = self.dictUserGeneralReadInfo!["email"] as? String
                    self.addNextButtonOnKeyboard(cell.txtField)
                }
                else if indexPath.item == 4 {
                    cell.lblCaption.text = "DOB"
                    cell.btnNext.isHidden = false
                    cell.btnNext.addTarget(self, action: #selector(FNViewController.sendToNext), for: .touchUpInside)
                    cell.txtField.returnKeyType = .default
                }
                
                
                print("cell called")
                if UIDevice.current.screenType == .iPhone4 {
                    cell.topConstraint.constant = 5
                }
                return cell
            }
        }
        else {
            if indexPath.row == 3 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addressCell", for: indexPath) as! MyDetailCollectionViewCell
                
                cell.lblCaption.text = "ADDRESS"
                configureTextField(cell)
                handleTextFieldInterfaces(cell)
                
                cell.txtAddress.layer.borderColor = UIColor(hexString: "010101").cgColor
                cell.txtAddress.layer.borderWidth = 1
                let leftViewFrame = CGRect(x: 0, y: 0, width: 5, height: cell.txtAddress.frame.height)
                let leftSubview = UIView(frame: leftViewFrame)
                cell.txtAddress.leftViewMode = .always
                cell.txtAddress.leftView = leftSubview
                cell.txtAddress.tag = indexPath.item
                cell.txtAddress.minimumFontSize = 8
                cell.txtAddress.text = ""
                
                cell.txtAddress.returnKeyType = .next
                self.addNextButtonOnKeyboard(cell.txtAddress)
                cell.txtAddress.keyboardType = .emailAddress
                cell.btnNext.isHidden = false
                cell.btnNext.addTarget(self, action: #selector(FNViewController.sendToNext), for: .touchUpInside)
                //self.showDatePicker()
                print("address called")
                if UIDevice.current.screenType == .iPhone4 {
                    cell.topConstraint.constant = 5
                }
                return cell
            }
            else if indexPath.item == 5 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ssnCell", for: indexPath) as! MyDetailCollectionViewCell
                cell.lblCaption.text = "LAST 4 SSN"
                cell.txtSSN.delegate = self
                cell.txtSSN.layer.borderColor = UIColor(hexString: "010101").cgColor
                cell.txtSSN.layer.borderWidth = 1
                let leftViewFrame = CGRect(x: 0, y: 0, width: 5, height: cell.txtSSN.frame.height)
                let leftSubview = UIView(frame: leftViewFrame)
                cell.txtSSN.leftViewMode = .always
                cell.txtSSN.leftView = leftSubview
                cell.txtSSN.tag = indexPath.item
                
                cell.txtSSN.setMask("{dddd}", withMaskTemplate: "####")
                
                cell.txtSSN.keyboardType = .numberPad
                
                self.addDoneButtonOnKeyboard(cell.txtSSN)
                
                cell.btnNext.isHidden = false
                cell.btnNext.setTitle("SUBMIT", for: UIControlState())
                cell.btnNext.addTarget(self, action: #selector(FNViewController.submitButtonTapped), for: .touchUpInside)
                print("address called")
                if UIDevice.current.screenType == .iPhone4 {
                    cell.topConstraint.constant = 5
                }
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailCell", for: indexPath) as! MyDetailCollectionViewCell
                cell.txtField.delegate = self
                cell.txtField.layer.borderColor = UIColor(hexString: "010101").cgColor
                cell.txtField.layer.borderWidth = 1
                let leftViewFrame = CGRect(x: 0, y: 0, width: 5, height: cell.txtField.frame.height)
                let leftSubview = UIView(frame: leftViewFrame)
                cell.txtField.leftViewMode = .always
                cell.txtField.leftView = leftSubview
                cell.txtField.tag = indexPath.item
                cell.btnNext.isHidden = true
                if indexPath.item == 0 {
                    cell.lblCaption.text = "FIRST NAME (legal)"
                    cell.txtField.keyboardType = .emailAddress
                    self.addNextButtonOnKeyboard(cell.txtField)
                }
                else if indexPath.item == 1 {
                    cell.lblCaption.text = "LAST NAME (legal)"
                    cell.txtField.keyboardType = .emailAddress
                    self.addNextButtonOnKeyboard(cell.txtField)
                }
                else if indexPath.item == 2 {
                    cell.lblCaption.text = "EMAIL"
                    cell.txtField.keyboardType = .emailAddress
                    self.addNextButtonOnKeyboard(cell.txtField)
                }
                else if indexPath.item == 4 {
                    cell.lblCaption.text = "DOB"
                    cell.btnNext.isHidden = false
                    cell.btnNext.addTarget(self, action: #selector(FNViewController.sendToNext), for: .touchUpInside)
                    cell.txtField.returnKeyType = .default
                }
                cell.txtField.text = ""
                //cell.txtField.becomeFirstResponder()
                if UIDevice.current.screenType == .iPhone4 {
                    cell.topConstraint.constant = 5
                }
                print("cell called")
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if self.isFromDitch != nil {
            if indexPath.row == 0 {
                if UserDefaults.standard.bool(forKey: "isOBLoaded") == true {
                    (cell as! MyDetailCollectionViewCell).txtAddress.becomeFirstResponder()
                }
            }
            else if indexPath.item == 1 {
                self.showDatePicker()
            }
            else if indexPath.item == 2 {
                (cell as! MyDetailCollectionViewCell).txtSSN.becomeFirstResponder()
            }
            else {
                (cell as! MyDetailCollectionViewCell).txtField.becomeFirstResponder()
                
            }
        }
        else {
            if self.dictUserGeneralReadInfo != nil {
                if indexPath.row == 3 {
                    (cell as! MyDetailCollectionViewCell).txtAddress.becomeFirstResponder()
                }
                else if indexPath.item == 4 {
                    self.showDatePicker()
                }
                else if indexPath.item == 5 {
                    (cell as! MyDetailCollectionViewCell).txtSSN.becomeFirstResponder()
                }
                else {
                    if UserDefaults.standard.bool(forKey: "isOBLoaded") == true {
                        (cell as! MyDetailCollectionViewCell).txtField.becomeFirstResponder()
                    }
                }
            }
            else {
                if indexPath.row == 3 {
                    (cell as! MyDetailCollectionViewCell).txtAddress.becomeFirstResponder()
                }
                else if indexPath.item == 4 {
                    self.showDatePicker()
                }
                else if indexPath.item == 5 {
                    (cell as! MyDetailCollectionViewCell).txtSSN.becomeFirstResponder()
                }
                else {
                    if UserDefaults.standard.bool(forKey: "isOBLoaded") == true {
                        (cell as! MyDetailCollectionViewCell).txtField.becomeFirstResponder()
                    }
                }
            }
        }
    }
    
}

extension FNViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        

        
        let indexPath = IndexPath(item: textField.tag, section: 0)
        let cell = detailCollectionView.cellForItem(at: indexPath) as! MyDetailCollectionViewCell
        
        if self.isFromDitch != nil {
            if textField.tag == 0 {
                if cell.txtAddress.autoCompleteStrings?.count > 0 {
                    cell.txtAddress.text = cell.txtAddress.autoCompleteStrings![0]
                    cell.txtAddress.resignFirstResponder()
                    cell.txtAddress.text = cell.txtAddress.text!
//                    DispatchQueue.main.async(execute: {
//                        KVNProgress.show(withStatus: "Getting Location Info")
//                    })
//                    Location.geocodeAddressString(cell.txtAddress.text!, completion: { (placemark, error) -> Void in
//                        DispatchQueue.main.async(execute: {
//                            KVNProgress.dismiss()
//
//                            cell.txtAddress.resignFirstResponder()
//                            cell.txtAddress.text = cell.txtAddress.text!
//
//                            let addressComponents = cell.txtAddress.text!.components(separatedBy: ",")
//                            let city = addressComponents[addressComponents.count - 2].trimmingCharacters(in: CharacterSet.whitespaces)
//                            let state = addressComponents.last!.trimmingCharacters(in: CharacterSet.whitespaces)
//                            let address1 = addressComponents[0]
//
//
//                            self.userGeneralInfo?.setObject(address1, forKey: "address" as NSCopying)
//                            self.userGeneralInfo?.setObject(city, forKey: "city" as NSCopying)
//                            self.userGeneralInfo?.setObject(state, forKey: "state" as NSCopying)
//                            self.userGeneralInfo?.setObject(placemark!.postalCode!, forKey: "zip" as NSCopying)
//
//                        })
//
//                    })
                }
                
                textField.resignFirstResponder()
                return true
            }
        }
        
        if self.dictUserGeneralReadInfo != nil {
            
            if textField.tag == 0 {
                if Utils.isTextFieldEmpty(cell.txtField) == true {
                    Utils.showOKAlertRO("", message: "First name is required.", controller: self)
                    return false
                }
                
                self.userGeneralInfo?.setObject(cell.txtField.text!, forKey: "firstName" as NSCopying)
                
            }
            if textField.tag == 1 {
                if Utils.isTextFieldEmpty(cell.txtField) == true {
                    Utils.showOKAlertRO("", message: "Last name is required.", controller: self)
                    return false
                }
                self.userGeneralInfo?.setObject(cell.txtField.text!, forKey: "lastName" as NSCopying)
            }
            
            if textField.tag == 2 {
                if Utils.isTextFieldEmpty(cell.txtField) == true {
                    Utils.showOKAlertRO("", message: "Email is required.", controller: self)
                    return false
                }
                if Utils.validateEmailAddress(cell.txtField.text!) == false {
                    Utils.showOKAlertRO("", message: "Email is invalid", controller: self)
                    return false
                }
                self.userGeneralInfo?.setObject(cell.txtField.text!, forKey: "emailAddress" as NSCopying)
            }
            
            if textField.tag == 3 {
                if cell.txtAddress.autoCompleteStrings?.count > 0 {
                    cell.txtAddress.text = cell.txtAddress.autoCompleteStrings![0]
                    DispatchQueue.main.async(execute: {
                        KVNProgress.show(withStatus: "Getting Location Info")
                    })
                    Location.geocodeAddressString(cell.txtAddress.text!, completion: { (placemark, error) -> Void in
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            
                            cell.txtAddress.resignFirstResponder()
                            cell.txtAddress.text = cell.txtAddress.text!
                            
                            let addressComponents = cell.txtAddress.text!.components(separatedBy: ",")
                            let city = addressComponents[addressComponents.count - 2].trimmingCharacters(in: CharacterSet.whitespaces)
                            let state = addressComponents.last!.trimmingCharacters(in: CharacterSet.whitespaces)
                            let address1 = addressComponents[0]
                            
                            
                            self.userGeneralInfo?.setObject(address1, forKey: "address" as NSCopying)
                            self.userGeneralInfo?.setObject(city, forKey: "city" as NSCopying)
                            self.userGeneralInfo?.setObject(state, forKey: "state" as NSCopying)
                            self.userGeneralInfo?.setObject(placemark!.postalCode!, forKey: "zip" as NSCopying)
                            
                        })
                        
                    })
                }
                
                textField.resignFirstResponder()
                return true
            }
        }
        else {
            if textField.tag == 0 {
                if Utils.isTextFieldEmpty(cell.txtField) == true {
                    Utils.showOKAlertRO("", message: "First name is required.", controller: self)
                    return false
                }
                
                let alert = UIAlertController(title: "", message: "Are You Sure?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
                    self.userGeneralInfo?.setObject(cell.txtField.text!, forKey: "firstName" as NSCopying)
                    self.sendToNext()
                }))
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (alertAction) in
                   return false
                }))
                present(alert, animated: true, completion: nil)
                return false
                
            }
            if textField.tag == 1 {
                if Utils.isTextFieldEmpty(cell.txtField) == true {
                    Utils.showOKAlertRO("", message: "Last name is required.", controller: self)
                    return false
                }
                let alert = UIAlertController(title: "", message: "Are You Sure?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
                    self.userGeneralInfo?.setObject(cell.txtField.text!, forKey: "lastName" as NSCopying)
                    self.sendToNext()
                }))
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (alertAction) in
                    return false
                }))
                present(alert, animated: true, completion: nil)
                return false
            }
            if textField.tag == 2 {
                if Utils.isTextFieldEmpty(cell.txtField) == true {
                    Utils.showOKAlertRO("", message: "Email is required.", controller: self)
                    return false
                }
                if Utils.validateEmailAddress(cell.txtField.text!) == false {
                    Utils.showOKAlertRO("", message: "Email is invalid", controller: self)
                    return false
                }
                self.userGeneralInfo?.setObject(cell.txtField.text!, forKey: "emailAddress" as NSCopying)
            }
            
            if textField.tag == 3 {
                if cell.txtAddress.autoCompleteStrings?.count > 0 {
                    cell.txtAddress.text = cell.txtAddress.autoCompleteStrings![0]
                    DispatchQueue.main.async(execute: {
                        KVNProgress.show(withStatus: "Getting Location Info")
                    })
                    Location.geocodeAddressString(cell.txtAddress.text!, completion: { (placemark, error) -> Void in
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            
                            cell.txtAddress.resignFirstResponder()
                            cell.txtAddress.text = cell.txtAddress.text!
                            self.userGeneralInfo?.setObject(placemark!.postalCode!, forKey: "zip" as NSCopying)
                        })
                        
                    })
                }
                
                textField.resignFirstResponder()
                return true
            }
        }
    
        
        
        sendToNext()
        return false
    }
    
//    func textFieldDidBeginEditing(textField: UITextField) {
//        self.performSelector(#selector(FNViewController.addColorToUIKeyboardButton), withObject: nil, afterDelay: 0.7)
//    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.isFromDitch != nil {
            if textField.tag == 1 {
                self.showDatePicker()
                return false
            }
        }
        else {
            if textField.tag == 4 {
                self.showDatePicker()
                return false
            }
        }
        return true
    }

    func sendToNext() {
        var isAddress = false
        if self.isFromDitch != nil {
            if page == 0 {
                isAddress = true
                let indexPath = IndexPath(item: page, section: 0)
                let cell = detailCollectionView.cellForItem(at: indexPath) as! MyDetailCollectionViewCell
                
                if Utils.isTextFieldEmpty(cell.txtAddress) == true {
                    Utils.showOKAlertRO("", message: "Address 1 is required.", controller: self)
                    return
                }
               
                
                DispatchQueue.main.async(execute: {
                    KVNProgress.show(withStatus: "Getting Location Info")
                })
                
                Location.geocodeAddressString(cell.txtAddress.text!, completion: { (placemark, error) -> Void in
                    
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                        
                        cell.txtAddress.resignFirstResponder()
                        
                        
                        let addressComponents = cell.txtAddress.text!.components(separatedBy: ",")
                        let city = addressComponents[addressComponents.count - 2].trimmingCharacters(in: CharacterSet.whitespaces)
                        let state = addressComponents.last!.trimmingCharacters(in: CharacterSet.whitespaces)
                        let address1 = addressComponents[0]
                        
                        
                        self.userGeneralInfo?.setObject(address1, forKey: "address" as NSCopying)
                        self.userGeneralInfo?.setObject(city, forKey: "city" as NSCopying)
                        self.userGeneralInfo?.setObject(state, forKey: "state" as NSCopying)
                        self.userGeneralInfo?.setObject(placemark!.postalCode!, forKey: "zip" as NSCopying)
                        
                        cell.txtAddress.text = cell.txtAddress.autoCompleteStrings![0]
                        cell.txtAddress.resignFirstResponder()
                        cell.txtAddress.text = cell.txtAddress.text!
                        self.page = self.page + 1
                        print(self.page)
                        let indexPathNext = IndexPath(item: self.page, section: 0)
                        self.detailCollectionView.selectItem(at: indexPathNext, animated: true, scrollPosition: .centeredHorizontally)
                    })
                    
                })

            }
            if page == 1 {
                let indexPath = IndexPath(item: page, section: 0)
                let cell = detailCollectionView.cellForItem(at: indexPath) as! MyDetailCollectionViewCell
                if Utils.isTextFieldEmpty(cell.txtField) == true {
                    Utils.showOKAlertRO("", message: "DOB required.", controller: self)
                    return
                }
                self.userGeneralInfo?.setObject(self.dob!, forKey: "dob" as NSCopying)
                
            }
            if page == 2 {
                let indexPath = IndexPath(item: page, section: 0)
                let cell = detailCollectionView.cellForItem(at: indexPath) as! MyDetailCollectionViewCell
                if Utils.isTextFieldEmpty(cell.txtSSN) == true {
                    Utils.showOKAlertRO("", message: "SSN required.", controller: self)
                    return
                }
                self.userGeneralInfo?.setObject(cell.txtSSN.text!, forKey: "ssn" as NSCopying)
            }
        }
        else {
            if self.dictUserGeneralReadInfo != nil {
                if page == 3 {
                    isAddress = true
                    let indexPath = IndexPath(item: page, section: 0)
                    let cell = detailCollectionView.cellForItem(at: indexPath) as! MyDetailCollectionViewCell
                    
                    if Utils.isTextFieldEmpty(cell.txtAddress) == true {
                        Utils.showOKAlertRO("", message: "Address 1 is required.", controller: self)
                        return
                    }
                    //self.userGeneralInfo?.setObject(cell.txtAddress.text!, forKey: "address" as NSCopying)
                    
                    DispatchQueue.main.async(execute: {
                        KVNProgress.show(withStatus: "Getting Location Info")
                    })
                    
                    Location.geocodeAddressString(cell.txtAddress.text!, completion: { (placemark, error) -> Void in
                        
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            
                            cell.txtAddress.resignFirstResponder()
                            
                            
                            let addressComponents = cell.txtAddress.text!.components(separatedBy: ",")
                            let city = addressComponents[addressComponents.count - 2].trimmingCharacters(in: CharacterSet.whitespaces)
                            let state = addressComponents.last!.trimmingCharacters(in: CharacterSet.whitespaces)
                            let address1 = addressComponents[0]
                            
                            
                            self.userGeneralInfo?.setObject(address1, forKey: "address" as NSCopying)
                            self.userGeneralInfo?.setObject(city, forKey: "city" as NSCopying)
                            self.userGeneralInfo?.setObject(state, forKey: "state" as NSCopying)
                            self.userGeneralInfo?.setObject(placemark!.postalCode!, forKey: "zip" as NSCopying)
                            self.page = self.page + 1
                            print(self.page)
                            let indexPathNext = IndexPath(item: self.page, section: 0)
                            self.detailCollectionView.selectItem(at: indexPathNext, animated: true, scrollPosition: .centeredHorizontally)
                        })
                        
                    })

                    
                }
                if page == 4 {
                    let indexPath = IndexPath(item: page, section: 0)
                    let cell = detailCollectionView.cellForItem(at: indexPath) as! MyDetailCollectionViewCell
                    if Utils.isTextFieldEmpty(cell.txtField) == true {
                        Utils.showOKAlertRO("", message: "DOB required.", controller: self)
                        return
                    }
                    self.userGeneralInfo?.setObject(self.dob!, forKey: "dob" as NSCopying)
                }
                if page == 5 {
                    let indexPath = IndexPath(item: page, section: 0)
                    let cell = detailCollectionView.cellForItem(at: indexPath) as! MyDetailCollectionViewCell
                    if Utils.isTextFieldEmpty(cell.txtSSN) == true {
                        Utils.showOKAlertRO("", message: "SSN required.", controller: self)
                        return
                    }
                    self.userGeneralInfo?.setObject(cell.txtSSN.text!, forKey: "ssn" as NSCopying)
                }
                
            }
            else {
                if page == 3 {
                    isAddress = true
                    let indexPath = IndexPath(item: page, section: 0)
                    let cell = detailCollectionView.cellForItem(at: indexPath) as! MyDetailCollectionViewCell
                    
                    if Utils.isTextFieldEmpty(cell.txtAddress) == true {
                        Utils.showOKAlertRO("", message: "Address 1 is required.", controller: self)
                        return
                    }
                    //self.userGeneralInfo?.setObject(cell.txtAddress.text!, forKey: "address" as NSCopying)
                    
                    DispatchQueue.main.async(execute: {
                        KVNProgress.show(withStatus: "Getting Location Info")
                    })
                    
                    Location.geocodeAddressString(cell.txtAddress.text!, completion: { (placemark, error) -> Void in
                        
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            
                            cell.txtAddress.resignFirstResponder()
                            
                            
                            let addressComponents = cell.txtAddress.text!.components(separatedBy: ",")
                            let city = addressComponents[addressComponents.count - 2].trimmingCharacters(in: CharacterSet.whitespaces)
                            let state = addressComponents.last!.trimmingCharacters(in: CharacterSet.whitespaces)
                            let address1 = addressComponents[0]
                            
                            
                            self.userGeneralInfo?.setObject(address1, forKey: "address" as NSCopying)
                            self.userGeneralInfo?.setObject(city, forKey: "city" as NSCopying)
                            self.userGeneralInfo?.setObject(state, forKey: "state" as NSCopying)
                            self.userGeneralInfo?.setObject(placemark!.postalCode!, forKey: "zip" as NSCopying)
                            
                            self.page = self.page + 1
                            print(self.page)
                            let indexPathNext = IndexPath(item: self.page, section: 0)
                            self.detailCollectionView.selectItem(at: indexPathNext, animated: true, scrollPosition: .centeredHorizontally)
                        })
                        
                    })

                }
                if page == 4 {
                    let indexPath = IndexPath(item: page, section: 0)
                    let cell = detailCollectionView.cellForItem(at: indexPath) as! MyDetailCollectionViewCell
                    if Utils.isTextFieldEmpty(cell.txtField) == true {
                        Utils.showOKAlertRO("", message: "DOB required.", controller: self)
                        return
                    }
                    self.userGeneralInfo?.setObject(self.dob!, forKey: "dob" as NSCopying)
                }
                if page == 5 {
                    let indexPath = IndexPath(item: page, section: 0)
                    let cell = detailCollectionView.cellForItem(at: indexPath) as! MyDetailCollectionViewCell
                    if Utils.isTextFieldEmpty(cell.txtSSN) == true {
                        Utils.showOKAlertRO("", message: "SSN required.", controller: self)
                        return
                    }
                    self.userGeneralInfo?.setObject(cell.txtSSN.text!, forKey: "ssn" as NSCopying)
                }
            }
        }
        
        if isAddress == false {
            self.page = self.page + 1
            print(self.page)
            let indexPathNext = IndexPath(item: self.page, section: 0)
            self.detailCollectionView.selectItem(at: indexPathNext, animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    func submitButtonTapped() -> Void {
        
        var indexPath = IndexPath(item: 5, section: 0)
        if self.isFromDitch != nil {
            indexPath = IndexPath(item: 2, section: 0)
        }
        
        let cell = detailCollectionView.cellForItem(at: indexPath) as! MyDetailCollectionViewCell
        if Utils.isTextFieldEmpty(cell.txtSSN) == true {
            Utils.showOKAlertRO("", message: "SSN required.", controller: self)
            return
        }
        self.userGeneralInfo?.setObject(cell.txtSSN.text!, forKey: "ssn" as NSCopying)
        
        self.saveUserGeneralInfo()
    }
    
}


extension FNViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
}

extension FNViewController {
    
    fileprivate func configureTextField(_ cell: MyDetailCollectionViewCell){
        cell.txtAddress.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        cell.txtAddress.maximumAutoCompleteCount = 20
        cell.txtAddress.hidesWhenSelected = true
        cell.txtAddress.hidesWhenEmpty = true
        cell.txtAddress.enableAttributedText = true
        cell.txtAddress.isFromMap = false
        //txtAddress.tag = 105
        cell.txtAddress.delegate = self
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        cell.txtAddress.autoCompleteAttributes = attributes
        //cell.txtAddress.placeholder = "Address"
        cell.txtAddress.showCurrentLocation = nil
    }
    
    fileprivate func handleTextFieldInterfaces(_ cell: MyDetailCollectionViewCell){
        cell.txtAddress.onTextChange = {[weak self] text in
            if !text.isEmpty{
                if let dataTask = self?.dataTask {
                    dataTask.cancel()
                }
                self?.fetchAutocompletePlaces(text, forCell: cell)
            }
        }
        
        cell.txtAddress.onSelect = {[weak self] text, indexpath in
            DispatchQueue.main.async(execute: {
                cell.txtAddress.resignFirstResponder()
                cell.txtAddress.text = text
            })
            
//            DispatchQueue.main.async(execute: {
//                KVNProgress.show(withStatus: "Getting Location Info")
//            })
//
//            Location.geocodeAddressString(text, completion: { (placemark, error) -> Void in
//
//                DispatchQueue.main.async(execute: {
//                    KVNProgress.dismiss()
//
//                    cell.txtAddress.resignFirstResponder()
//                    cell.txtAddress.text = text
//
//                    let addressComponents = text.components(separatedBy: ",")
//                    let city = addressComponents[addressComponents.count - 2].trimmingCharacters(in: CharacterSet.whitespaces)
//                    let state = addressComponents.last!.trimmingCharacters(in: CharacterSet.whitespaces)
//                    let address1 = addressComponents[0]
//
//
//                    self?.userGeneralInfo?.setObject(address1, forKey: "address" as NSCopying)
//                    self?.userGeneralInfo?.setObject(city, forKey: "city" as NSCopying)
//                    self?.userGeneralInfo?.setObject(state, forKey: "state" as NSCopying)
//                    self?.userGeneralInfo?.setObject(placemark!.postalCode!, forKey: "zip" as NSCopying)
//                })
//
//            })
        }
    }
    
    fileprivate func fetchAutocompletePlaces(_ keyword:String, forCell cell: MyDetailCollectionViewCell) {
        let urlString = "\(baseURLString)?key=\(googleMapsKey)&input=\(keyword)&types=address&components=country:usa"
        let s = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        s.addCharacters(in: "+&")
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            if let url = URL(string: encodedString) {
                let request = URLRequest(url: url)
                dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                    if let data = data{
                        
                        do{
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                            
                            if let status = result["status"] as? String{
                                if status == "OK"{
                                    if let predictions = result["predictions"] as? NSArray{
                                        var locations = [String]()
                                        for dict in predictions as! [NSDictionary]{
                                            let prediction = (dict["description"] as! String).replacingOccurrences(of: ", United States", with: "")
                                            locations.append(prediction)
                                        }
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            cell.txtAddress.autoCompleteStrings = locations
                                        })
                                        return
                                    }
                                }
                            }
                            DispatchQueue.main.async(execute: { () -> Void in
                                cell.txtAddress.autoCompleteStrings = nil
                            })
                        }
                        catch let error as NSError{
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                })
                dataTask?.resume()
            }
        }
    }
}

extension FNViewController {
    func showDatePicker() {
        if self.customPicker != nil {
            self.customPicker?.removeFromSuperview()
            self.customPicker = nil
        }
        
        
        let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let currentDate: Date = Date()
        var components: DateComponents = DateComponents()
        
        components.year = -18
        let maxDate: Date = (gregorian as NSCalendar).date(byAdding: components, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
        
        if self.isFromDitch == nil {
            self.customPicker = CustomPickerView.createPickerViewWithDateForDOB(true, withIndexPath: IndexPath(row: 4, section: 0), isDateTime: false, andSelectedDate: maxDate)
        }
        else {
            self.customPicker = CustomPickerView.createPickerViewWithDateForDOB(true, withIndexPath: IndexPath(row: 1, section: 0), isDateTime: false, andSelectedDate: maxDate)
        }

        self.customPicker?.delegate = self
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.customPicker?.frame = CGRect(x: self.customPicker!.frame.origin.x, y: self.customPicker!.frame.origin.y, width: appDelegate.window!.frame.size.width, height: self.customPicker!.frame.size.height);
        
        self.customPicker!.center = CGPoint(x: self.customPicker!.center.x, y: (appDelegate.window?.frame.size.height)!+192)
        
        
        
        self.view.addSubview(self.customPicker!)
        
        UIView.beginAnimations("bringUp", context: nil)
        UIView.setAnimationDuration(0.3)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.customPicker!.center = CGPoint(x: self.customPicker!.center.x, y: (appDelegate.window?.frame.size.height)!-130)
        UIView.commitAnimations()
    }
    func hideCustomPicker() {
        if self.customPicker == nil {
            return
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        UIView.beginAnimations("bringDown", context: nil)
        UIView.setAnimationDuration(0.3)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.customPicker!.center = CGPoint(x: self.customPicker!.center.x, y: (appDelegate.window?.frame.size.height)!+192)
        UIView.commitAnimations()
    }
}

extension FNViewController: CustomPickerDelegate {
    func didCancelTapped() {
        self.hideCustomPicker()
    }
    
    func didDateSelected(_ date: Date, withIndexPath indexPath: IndexPath) {
        self.hideCustomPicker()
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        
        let dfServer = DateFormatter()
        dfServer.dateFormat = "yyyy-MM-dd"
        
        self.dob = dfServer.string(from: date)
        let cell = self.detailCollectionView.cellForItem(at: indexPath) as! MyDetailCollectionViewCell
        cell.txtField.text = df.string(from: date)
    }
    
    func didDurationSelected(_ duration: String, withIndexPath indexPath: IndexPath) {
        
    }
    
    func didItemSelected(_ optionIndex: NSInteger, andSeletedText selectedText: String, withIndexPath indexPath: IndexPath, andSelectedObject selectedObject: NSDictionary) {
        self.hideCustomPicker()
        
    }
}

extension FNViewController {
    
    func saveUserGeneralInfo() -> Void {
        
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
        
        
        
        var paramDict: NSDictionary!
        
        if self.dictUserGeneralReadInfo != nil {
            paramDict = ["token": token, "provider": "dwolla", "first_name": self.userGeneralInfo!["firstName"]!, "last_name": self.userGeneralInfo!["lastName"]!, "email": self.userGeneralInfo!["emailAddress"]!, "address1": self.userGeneralInfo!["address"]!, "city": self.userGeneralInfo!["city"] as! String, "state": self.userGeneralInfo!["state"] as! String, "zip": self.userGeneralInfo!["zip"]!, "dob": self.userGeneralInfo!["dob"]!, "ssn": self.userGeneralInfo!["ssn"]!, "recreate": "1"]
        }
        else {
            paramDict = ["token": token, "provider": "dwolla", "customer_type": "personal", "first_name": self.userGeneralInfo!["firstName"]!, "last_name": self.userGeneralInfo!["lastName"]!, "email": self.userGeneralInfo!["emailAddress"]!, "address1": self.userGeneralInfo!["address"]!, "city": self.userGeneralInfo!["city"] as! String, "state": self.userGeneralInfo!["state"] as! String, "zip": self.userGeneralInfo!["zip"]!, "dob": self.userGeneralInfo!["dob"]!, "ssn": self.userGeneralInfo!["ssn"]!]
        }
        
        
        print(paramDict)
        
        
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
                                let message = tempData!["message"] as! String
                                var title = "Error:"
                                if message.contains("verified email") {
                                    title = "VERIFY EMAIL"
                                }
                                _utils.showOKAlert(title, message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            })
                            
                            return
                        }
                        
                        self.getUserGeneralInfo()
                        
                        DispatchQueue.main.async(execute: {
                            if self.dictUserGeneralReadInfo != nil {
                                self.navigationController?.popViewController(animated: true)
                            }
                            else {
                                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "paymentMethodsVC") as! PaymentMethodsViewController
                                controller.isFromBooking = self.isFromBooking
                                self.navigationController?.pushViewController(controller, animated: true)
                            }
                        })
//                        let currentDate = NSDate()
//                        let df = NSDateFormatter()
//                        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                        self.lblGeneralSavedStamp.text = "Saved \(df.stringFromDate(currentDate))"
                        //                let _utils = Utils()
                        //                _utils.showOKAlert("", message: tempData["message"] as! String, controller: self, isActionRequired: false)
                        //                return
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
        catch {
            
        }
        
    }
    
}

extension FNViewController {
    func getUserGeneralInfo() -> Void {
        
        
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getusergeneral?token=\(token)&source=dts")
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
                    let dictUserGeneral = tempData!["data"] as! NSDictionary
                    let dwollaCustomerStatus = dictUserGeneral["dwolla_customer_status"] as? String
                    if dwollaCustomerStatus != nil {
                        AppDelegate.returnAppDelegate().dwollaCustomerStatus = dwollaCustomerStatus
                    }
                    
                }
                catch {
                    
                }
            }
            else {
                //                dispatch_async(dispatch_get_main_queue(), {
                //                    KVNProgress.show()
                //                })
                //                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                
            }
        }.resume()
    }
}

//extension FNViewController {
//    
//    func subviewsOfView(view : UIView, withType type:NSString) -> NSArray {
//        let prefix = NSString(format: "<%@",type) as String
//        let subViewsArray = NSMutableArray()
//        for subview in view.subviews {
//            let tempArray = subviewsOfView(subview, withType: type)
//            for view in tempArray {
//                subViewsArray.addObject(view)
//            }
//        }
//        if view.description.hasPrefix(prefix) {
//            subViewsArray.addObject(view)
//        }
//        return NSArray(array: subViewsArray)
//    }
//    
//    func addColorToUIKeyboardButton() {
//        for keyboardWindow in UIApplication.sharedApplication().windows {
//            for keyboard in keyboardWindow.subviews {
//                for view in self.subviewsOfView(keyboard, withType: "UIKBKeyplaneView") {
//                    let newView = UIView(frame: (self.subviewsOfView(keyboard, withType: "UIKBKeyView").lastObject as! UIView).frame)
//                    newView.frame = CGRectMake(newView.frame.origin.x + 2, newView.frame.origin.y + 1, newView.frame.size.width - 4, newView.frame.size.height - 3)
//                    newView.backgroundColor = UIColor.redColor() //Or whatever color you want
//                    newView.layer.cornerRadius = 4.0
//                    view.insertSubview(newView, belowSubview: self.subviewsOfView(keyboard, withType: "UIKBKeyView").lastObject as! UIView)
//                }
//            }
//        }
//    }
//}


extension FNViewController {
    
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
        let indexPath = IndexPath(item: sender.tag, section: 0)
        let cell = detailCollectionView.cellForItem(at: indexPath) as! MyDetailCollectionViewCell
        
        if self.isFromDitch != nil {
            if sender.tag == 0 {
                if cell.txtAddress.autoCompleteStrings?.count > 0 {
                    cell.txtAddress.text = cell.txtAddress.autoCompleteStrings![0]
                    cell.txtAddress.resignFirstResponder()
                    cell.txtAddress.text = cell.txtAddress.text!
                }
                
                cell.txtAddress.resignFirstResponder()
                return
            }
        }
        
        if self.dictUserGeneralReadInfo != nil {
            
            if sender.tag == 0 {
                if Utils.isTextFieldEmpty(cell.txtField) == true {
                    Utils.showOKAlertRO("", message: "First name is required.", controller: self)
                    return
                }
                
                self.userGeneralInfo?.setObject(cell.txtField.text!, forKey: "firstName" as NSCopying)
                
            }
            if sender.tag == 1 {
                if Utils.isTextFieldEmpty(cell.txtField) == true {
                    Utils.showOKAlertRO("", message: "Last name is required.", controller: self)
                    return
                }
                self.userGeneralInfo?.setObject(cell.txtField.text!, forKey: "lastName" as NSCopying)
            }
            
            if sender.tag == 2 {
                if Utils.isTextFieldEmpty(cell.txtField) == true {
                    Utils.showOKAlertRO("", message: "Email is required.", controller: self)
                    return
                }
                if Utils.validateEmailAddress(cell.txtField.text!) == false {
                    Utils.showOKAlertRO("", message: "Email is invalid", controller: self)
                    return
                }
                
                let alert = UIAlertController(title: "", message: "VERIFY EMAIL NOW to PROCEED", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "PROCEED", style: .default, handler: { (alertAction) in
                    self.userGeneralInfo?.setObject(cell.txtField.text!, forKey: "emailAddress" as NSCopying)
                    self.sendToNext()
                }))
                alert.addAction(UIAlertAction(title: "CHANGE EMAIL", style: .default, handler: { (alertAction) in
                    return
                }))
                present(alert, animated: true, completion: nil)
                return
                
                
            }
            
            if sender.tag == 3 {
                if cell.txtAddress.autoCompleteStrings?.count > 0 {
                    cell.txtAddress.text = cell.txtAddress.autoCompleteStrings![0]
                    cell.txtAddress.resignFirstResponder()
                    cell.txtAddress.text = cell.txtAddress.text!
                    
                }
                
                cell.txtAddress.resignFirstResponder()
                return
            }
        }
        else {
            if sender.tag == 0 {
                if Utils.isTextFieldEmpty(cell.txtField) == true {
                    Utils.showOKAlertRO("", message: "First name is required.", controller: self)
                    return
                }
                
                let alert = UIAlertController(title: "", message: "Are You Sure?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
                    self.userGeneralInfo?.setObject(cell.txtField.text!, forKey: "firstName" as NSCopying)
                    self.sendToNext()
                }))
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (alertAction) in
                    return
                }))
                present(alert, animated: true, completion: nil)
                return
                
            }
            if sender.tag == 1 {
                if Utils.isTextFieldEmpty(cell.txtField) == true {
                    Utils.showOKAlertRO("", message: "Last name is required.", controller: self)
                    return
                }
                let alert = UIAlertController(title: "", message: "Are You Sure?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
                    self.userGeneralInfo?.setObject(cell.txtField.text!, forKey: "lastName" as NSCopying)
                    self.sendToNext()
                }))
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (alertAction) in
                    return
                }))
                present(alert, animated: true, completion: nil)
                return
            }
            if sender.tag == 2 {
                if Utils.isTextFieldEmpty(cell.txtField) == true {
                    Utils.showOKAlertRO("", message: "Email is required.", controller: self)
                    return
                }
                if Utils.validateEmailAddress(cell.txtField.text!) == false {
                    Utils.showOKAlertRO("", message: "Email is invalid", controller: self)
                    return
                }
                let alert = UIAlertController(title: "", message: "VERIFY EMAIL NOW to PROCEED", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "PROCEED", style: .default, handler: { (alertAction) in
                    self.userGeneralInfo?.setObject(cell.txtField.text!, forKey: "emailAddress" as NSCopying)
                    self.sendToNext()
                }))
                alert.addAction(UIAlertAction(title: "CHANGE EMAIL", style: .default, handler: { (alertAction) in
                    return
                }))
                present(alert, animated: true, completion: nil)
                return
            }
            
            if sender.tag == 3 {
                if cell.txtAddress.autoCompleteStrings?.count > 0 {
                    cell.txtAddress.text = cell.txtAddress.autoCompleteStrings![0]
                    DispatchQueue.main.async(execute: {
                        KVNProgress.show()
                    })
                    Location.geocodeAddressString(cell.txtAddress.text!, completion: { (placemark, error) -> Void in
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            
                            cell.txtAddress.resignFirstResponder()
                            cell.txtAddress.text = cell.txtAddress.text!
                            self.userGeneralInfo?.setObject(placemark!.postalCode!, forKey: "zip" as NSCopying)
                        })
                        
                    })
                }
                
                cell.txtAddress.resignFirstResponder()
                return
            }
        }
        
        
        
        sendToNext()
        return
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
    
    func subviewsOfView(_ view : UIView, withType type:NSString) -> NSArray {
        let prefix = NSString(format: "<%@",type) as String
        let subViewsArray = NSMutableArray()
        for subview in view.subviews {
            let tempArray = subviewsOfView(subview, withType: type)
            for view in tempArray {
                subViewsArray.add(view)
            }
        }
        if view.description.hasPrefix(prefix) {
            subViewsArray.add(view)
        }
        return NSArray(array: subViewsArray)
    }
    
    func addColorToUIKeyboardButton() {
        for keyboardWindow in UIApplication.shared.windows {
            for keyboard in keyboardWindow.subviews {
                for view in self.subviewsOfView(keyboard, withType: "UIKBKeyplaneView") {
                    let newView = UIView(frame: (self.subviewsOfView(keyboard, withType: "UIKBKeyView").lastObject as! UIView).frame)
                    newView.frame = CGRect(x: newView.frame.origin.x + 2, y: newView.frame.origin.y + 1, width: newView.frame.size.width - 5, height: newView.frame.size.height - 4)
                    newView.backgroundColor = UIColor(hexString: "007bff")//UIColor.redColor() //Or whatever color you want
                    newView.layer.cornerRadius = 5.0
                    
                    let titleFrame = CGRect(x: 0, y: -2, width: newView.frame.size.width, height: newView.frame.size.height)
                    let lblTitle = UILabel(frame: titleFrame)
                    lblTitle.textColor = UIColor.white
                    lblTitle.text = "Next"
                    lblTitle.font = UIFont.systemFont(ofSize: 15)
                    lblTitle.backgroundColor = UIColor.clear
                    lblTitle.textAlignment = .center
                    newView.addSubview(lblTitle)
                    
                    (view as AnyObject).insertSubview(newView, aboveSubview: self.subviewsOfView(keyboard, withType: "UIKBKeyView").lastObject as! UIView)
                    (view as AnyObject).bringSubview(toFront: newView)
                }
            }
        }
    }
    
    
    
//    func keyboardWillShow(_ notification: Notification) -> Void {
//        print("keyboard will be shown")
//        //FNViewController.addColorToUIKeyboardButton
//        if page != 5 {
//            addColorToUIKeyboardButton()
//        }
//        //self.performSelector(#selector(FNViewController.addColorToUIKeyboardButton), withObject: nil, afterDelay: 0.7)
//    }
    
    
    
    func keyboardWillHide(_ notification: Notification) -> Void {
        print("keyboard will be hidden")
    }
    
}
