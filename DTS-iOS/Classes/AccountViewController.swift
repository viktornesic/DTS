//
//  AccountViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 16/06/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress

class AccountViewController: BaseViewController {
    
    @IBOutlet weak var viewGCV: UIView!
    @IBOutlet weak var btnVoiceMessage: UIButton!
    @IBOutlet weak var btnSMS: UIButton!
    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var lblGeneralSavedStamp: UILabel!
    @IBOutlet weak var lblSavedStamp: UILabel!
    @IBOutlet weak var txtpZip: UITextField!
    @IBOutlet weak var txtCCV: UITextField!
    @IBOutlet weak var txtExpiry: BKCardExpiryField!
    @IBOutlet weak var txtCreditCardNumber: BKCardNumberField!
    @IBOutlet weak var txtRouteNumber: UITextField!
    @IBOutlet weak var txtAccountNumber: UITextField!
    @IBOutlet weak var svPayment: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var viewPayment: UIView!
    @IBOutlet weak var svGeneral: UIScrollView!
    
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var txtZipCode: UITextField!
    @IBOutlet weak var txtAddress: AutoCompleteTextField!
    fileprivate var responseData:NSMutableData?
    fileprivate var dataTask:URLSessionDataTask?
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var viewGeneral: UIView!
    @IBOutlet weak var segmentAccount: UISegmentedControl!
    var dictUserGeneral: NSDictionary!
    var dictUserPayment: NSDictionary!
    var viewType: Int!
    var customPicker: CustomPickerView?
    var dob: String?
    
    @IBOutlet weak var btnVoiceCheck: UIButton!
    @IBOutlet weak var btnSMSCheck: UIButton!
    @IBOutlet weak var btnEmailCheck: UIButton!
    
    
    fileprivate let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    fileprivate let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //        Utils.setPaddingForTextFieldInView(self.svGeneral)
        //        Utils.setPaddingForTextFieldInView(self.svPayment)
        
        self.txtExpiry.clearButtonMode = .never
        self.txtCreditCardNumber.clearButtonMode = .never
        self.addDoneButtonOnKeyboard(self.txtExpiry)
        self.addDoneButtonOnKeyboard(self.txtCreditCardNumber)
        self.addDoneButtonOnKeyboard(self.txtAccountNumber)
        self.addDoneButtonOnKeyboard(self.txtRouteNumber)
        self.addDoneButtonOnKeyboard(self.txtCCV)
        
//        self.txtDOB.mask = "{dddd}-{dd}-{dd}"
//        self.txtDOB.maskTemplate = "____-__-__"
//    
//        self.txtDOB.keyboardType = .NumberPad
        
        
        
//        self.txtFirstName.text = dictUserGeneral["firstName"] as! String
        
        let revealController = revealViewController()
        revealController?.panGestureRecognizer()
        revealController?.tapGestureRecognizer()
        
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        configureTextField()
        handleTextFieldInterfaces()
        
        self.segmentAccount.isHidden = true
        self.viewGeneral.isHidden = true
        self.viewPayment.isHidden = true
        
        self.btnSMS.isEnabled = false
        self.btnEmail.isEnabled = false
        
        
        
        self.txtAddress.returnKeyType = .default
        
        self.recursiveFormatViews(forMainView: self.viewGCV)
        
        switch viewType {
        case 0:
            self.viewGeneral.isHidden = false
            self.getUserGeneralInfo()
        case 1:
            self.viewPayment.isHidden = false
            self.getUserPaymentInfo()
        default:
            break
        }
    }
    
    @IBAction func voiceMessageButtonTapped(_ sender: AnyObject) {
        if self.btnVoiceMessage.isSelected == true {
            self.btnVoiceMessage.isSelected = false
        }
        else {
            self.btnVoiceMessage.isSelected = true
        }
    }
    @IBAction func confirmEmailButtonTapped(_ sender: AnyObject) {
        self.sendConfirmation()
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
    
    func getUserGeneralInfo() -> Void {
        
        KVNProgress.show(withStatus: "Loading User Info")
        
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
                        })
                        
                        return
                    }
                    self.dictUserGeneral = tempData!["data"] as! NSDictionary
                    DispatchQueue.main.async(execute: {
                        self.populateUserGeneralFields()
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
    
    func populateUserGeneralFields() -> Void {
        
        self.txtFirstName.text = self.dictUserGeneral["first_name"] as? String
        self.txtLastName.text = self.dictUserGeneral["last_name"] as? String
        self.txtEmailAddress.text = self.dictUserGeneral["email"] as? String
        self.txtAddress.text = self.dictUserGeneral["address1"] as? String
        //self.txtAddress2.text = self.dictUserGeneral["address2"] as? String
        self.txtZipCode.text = self.dictUserGeneral["zip"] as? String
        
//        if self.dictUserGeneral["pref_email"] as! Int == 1 {
//            self.btnEmail.selected = true
//        }
//        if self.dictUserGeneral["pref_sms"] as! Int == 1 {
//            self.btnSMS.selected = true
//        }
        if self.dictUserGeneral["pref_voice"] as! Int == 1 {
            self.btnVoiceMessage.isSelected = true
        }
        
//        self.dob = self.dictUserGeneral["dob"] as? String
//        let df = NSDateFormatter()
//        df.dateFormat = "yyyy-MM-dd"
//    
//        
//        if self.dob != nil {
//            let dateDOB = df.dateFromString(self.dob!)
//            let df1 = NSDateFormatter()
//            df1.dateFormat = "dd-MM-yyyy"
//            self.txtDOB.text = df1.stringFromDate(dateDOB!)
//        }
//        
//        self.txtSSN.text = self.dictUserGeneral["ssn"] as? String
        
    }
    
    func populateUserPaymentFields() -> Void {
        if self.dictUserPayment["ach"] as? NSDictionary != nil {
            let dictACH = self.dictUserPayment["ach"] as! NSDictionary
            self.txtAccountNumber.text = dictACH["bank_acct"] as? String
            self.txtRouteNumber.text = dictACH["bank_route"] as? String
        }
        if self.dictUserPayment["cc"] as? NSDictionary != nil {
            let dictCC = self.dictUserPayment["cc"] as! NSDictionary
            self.txtCreditCardNumber.text = dictCC["cc"] as? String
            self.txtCCV.text = dictCC["ccv"] as? String
            self.txtExpiry.text = dictCC["expiration"] as? String
            self.txtpZip.text = dictCC["zip"] as? String
        }
    }
    
    func getUserPaymentInfo() -> Void {
        
        DispatchQueue.main.async(execute: {
            KVNProgress.dismiss()
        })
        
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getuserpayment?token=\(token)")
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
                        })
                        
                        return
                    }
                    self.dictUserPayment = tempData!["data"] as! NSDictionary
                    DispatchQueue.main.async(execute: {
                        self.populateUserPaymentFields()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnPaymentSave_Tapped(_ sender: AnyObject) {
        self.saveUserPayment()
    }
    @IBAction func btnGeneralSave_Tapped(_ sender: AnyObject) {
        self.saveUserGeneralInfo()
    }
    
    func saveUserGeneralInfo() -> Void {
        
        if Utils.isTextFieldEmpty(self.txtFirstName) == true {
            Utils.showOKAlertRO("", message: "First name is required.", controller: self)
            return
        }
        
        if Utils.isTextFieldEmpty(self.txtLastName) == true {
            Utils.showOKAlertRO("", message: "Last name is required.", controller: self)
            return
        }
        
        if Utils.isTextFieldEmpty(self.txtEmailAddress) == true {
            Utils.showOKAlertRO("", message: "Email is required.", controller: self)
            return
        }
        
        if Utils.isTextFieldEmpty(self.txtAddress) == true {
            Utils.showOKAlertRO("", message: "Address 1 is required.", controller: self)
            return
        }
        
        
        if Utils.validateEmailAddress(self.txtEmailAddress.text!) == false {
            Utils.showOKAlertRO("", message: "Email is invalid", controller: self)
            return
        }
        
        
        KVNProgress.show(withStatus: "Saving User Info")
        
        var token = ""
        let strURL = "\(APIConstants.BasePath)/api/saveusergeneral"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
        }
        
        
        /*var address2 = ""
        if self.txtAddress2.text != nil {
            address2 = self.txtAddress2.text!
        }*/
        
        var voiceSelected = "1"
        
        if self.btnVoiceMessage.isSelected == false {
            voiceSelected = "0"
        }
        
        let paramDict: NSDictionary = ["token": token, "first_name": self.txtFirstName.text!, "last_name": self.txtLastName.text!, "email": self.txtEmailAddress.text!, "address1": self.txtAddress.text!, "address2": "", "zip": "", "pref_email": "1", "pref_sms": "1", "pref_voice": voiceSelected, "provider": "dts"]
       
        
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
                                _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                                return
                            })
                            
                        }
                        
                        let currentDate = Date()
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        self.lblGeneralSavedStamp.text = "Saved \(df.string(from: currentDate))"
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
                    })
                    Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                    
                }
            }.resume()
        }
        catch {
            
        }
        
    }
    
    func saveUserPayment() -> Void {
        
        
        if Utils.isTextFieldEmpty(self.txtAccountNumber) == false || Utils.isTextFieldEmpty(self.txtRouteNumber) == false {
            if Utils.isTextFieldEmpty(self.txtAccountNumber) == true {
                Utils.showOKAlertRO("", message: "Account number is required.", controller: self)
                return
            }
            
            if Utils.isTextFieldEmpty(self.txtRouteNumber) == true {
                Utils.showOKAlertRO("", message: "Route number is required.", controller: self)
                return
            }
        }
        else {
            if Utils.isTextFieldEmpty(self.txtCreditCardNumber) == false || Utils.isTextFieldEmpty(self.txtExpiry) == false || Utils.isTextFieldEmpty(self.txtCCV) == false || Utils.isTextFieldEmpty(self.txtpZip) == false {
                if Utils.isTextFieldEmpty(self.txtCreditCardNumber) == true {
                    Utils.showOKAlertRO("", message: "Card number is required.", controller: self)
                    return
                }
                
                if Utils.isTextFieldEmpty(self.txtExpiry) == true {
                    Utils.showOKAlertRO("", message: "Expiry is required.", controller: self)
                    return
                }
                
                if Utils.isTextFieldEmpty(self.txtCCV) == true {
                    Utils.showOKAlertRO("", message: "CCV is required.", controller: self)
                    return
                }
                
                if Utils.isTextFieldEmpty(self.txtpZip) == true {
                    Utils.showOKAlertRO("", message: "Zip code is required.", controller: self)
                    return
                }
            }
        }
        
        
        
        KVNProgress.show(withStatus: "Saving Payment Info")
        
        var token = ""
        let strURL = "\(APIConstants.BasePath)/api/saveuserpayment"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
        }
        
        var accountNumber = ""
        var bankRoute = ""
        var ccno = ""
        var expirey = ""
        var ccv = ""
        var zip = ""
        
        if self.txtAccountNumber.text != nil {
            accountNumber = self.txtAccountNumber.text!
        }
        if self.txtRouteNumber.text != nil {
            bankRoute = self.txtRouteNumber.text!
        }
        if self.txtCreditCardNumber.text != nil {
            ccno = self.txtCreditCardNumber.text!
        }
        if self.txtExpiry.text != nil {
            expirey = self.txtExpiry.text!
        }
        if self.txtCCV.text != nil {
            ccv = self.txtCCV.text!
        }
        if self.txtpZip.text != nil {
            zip = self.txtpZip.text!
        }
        
        let paramDict: NSDictionary = ["token": token, "bank_acct": accountNumber, "bank_route": bankRoute, "cc": ccno, "expiration": expirey, "ccv": ccv, "zip": zip]
        
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
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        }
                        
                        let currentDate = Date()
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        self.lblSavedStamp.text = "Saved \(df.string(from: currentDate))"
                        
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
                    })
                    Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                    
                }
            }.resume()
        }
        catch {
            
        }
    }
    
    @IBAction func btnBack_Tapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func Toggle(_ sender: AnyObject) {
        let segment = sender as! UISegmentedControl
        self.viewGeneral.isHidden = true
        self.viewPayment.isHidden = true
        
        if segment.selectedSegmentIndex == 0 {
            self.viewGeneral.isHidden = false
        }
        else {
            self.viewPayment.isHidden = false;
        }
    }
    
    
}

extension AccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            self.txtLastName.becomeFirstResponder()
            return false
        }
        else if textField.tag == 1 {
            self.txtEmailAddress.becomeFirstResponder()
            return false
        }
        else if textField.tag == 2 {
            self.txtAddress.becomeFirstResponder()
            return false
        }
//        else if textField.tag == 3 {
//            //self.txtDOB.becomeFirstResponder()
//            textField.resignFirstResponder()
//            self.showDatePicker()
//            return false
//        }
//        else if textField.tag == 4 {
//            
//            return false
//        }
        
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 5 {
            self.txtCCV.resignFirstResponder()
            self.txtFirstName.resignFirstResponder()
            self.txtEmailAddress.resignFirstResponder()
            
            self.showDatePicker()
            return false
        }
        
        return true
    }
}

extension AccountViewController {
    
    fileprivate func configureTextField(){
        txtAddress.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        txtAddress.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        txtAddress.autoCompleteCellHeight = 35.0
        txtAddress.maximumAutoCompleteCount = 20
        txtAddress.hidesWhenSelected = true
        txtAddress.hidesWhenEmpty = true
        txtAddress.enableAttributedText = true
        txtAddress.isFromMap = false
        //txtAddress.tag = 105
        txtAddress.delegate = self
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        txtAddress.autoCompleteAttributes = attributes
        txtAddress.placeholder = "ADDRESS"
        txtAddress.showCurrentLocation = nil
    }
    
    fileprivate func handleTextFieldInterfaces(){
        txtAddress.onTextChange = {[weak self] text in
            if !text.isEmpty{
                if let dataTask = self?.dataTask {
                    dataTask.cancel()
                }
                self?.fetchAutocompletePlaces(text)
            }
        }
        
        txtAddress.onSelect = {[weak self] text, indexpath in
            self?.txtAddress.resignFirstResponder()
            self?.txtAddress.text = text
        }
    }
    
    
    
    fileprivate func fetchAutocompletePlaces(_ keyword:String) {
        let urlString = "\(baseURLString)?key=\(googleMapsKey)&input=\(keyword)&components=country:usa"
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
                                            self.txtAddress.autoCompleteStrings = locations
                                        })
                                        return
                                    }
                                }
                            }
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.txtAddress.autoCompleteStrings = nil
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

extension AccountViewController: CustomPickerDelegate {
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
        
    }
    
    func didDurationSelected(_ duration: String, withIndexPath indexPath: IndexPath) {
        
    }
    
    func didItemSelected(_ optionIndex: NSInteger, andSeletedText selectedText: String, withIndexPath indexPath: IndexPath, andSelectedObject selectedObject: NSDictionary) {
        self.hideCustomPicker()
        
    }
}

extension AccountViewController {
    func showDatePicker() {
        if self.customPicker != nil {
            self.customPicker?.removeFromSuperview()
            self.customPicker = nil
        }
        
        let currentDate = Date()
        self.customPicker = CustomPickerView.createPickerViewWithDate(true, withIndexPath: IndexPath(row: 0, section: 0), isDateTime: false, andSelectedDate: currentDate)
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

extension AccountViewController {
    func sendConfirmation() -> Void {
        
        KVNProgress.show(withStatus: "Sending Confirmation Email")
        
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
                        })
                        
                        return
                    }
                    
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
    
    func recursiveFormatViews(forMainView mainView: UIView) {
        for view in mainView.subviews {
            if view is UITextField {
                (view as! UITextField).attributedPlaceholder = NSAttributedString(string:(view as! UITextField).placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.white])
                //0275f3
                (view as! UITextField).textColor = UIColor(hexString: "0275f3")
            }
        }
    }
}
