//
//  CTAViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 19/09/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress
import CoreLocation

class CTAViewController: UIViewController {
    
    @IBOutlet weak var txtCID: AKMaskField!
    @IBOutlet weak var txtExpiry: UITextField!
    @IBOutlet weak var txtRate: UITextField!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var autocompleteTextfield: AutoCompleteTextField!
    fileprivate var responseData:NSMutableData?
    fileprivate var dataTask:URLSessionDataTask?
    var selectedCoordinates: CLLocationCoordinate2D?
    var customPicker: CustomPickerView?
    fileprivate let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    fileprivate let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    var stratDate: String!
    var receivedCode: String!
    var formattedPhoneNumber: String!
    var months: [[String: String]]!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.txtTitle.placeholder = "Expire"
        self.txtCID.setMask("({ddd}) {ddd}-{dddd}", withMaskTemplate: "(###) ###-####")
        //self.txtCID.maskDelegate = self
        self.txtCID.keyboardType = .numberPad
        self.txtExpiry.keyboardType = .numberPad
        self.addNextButtonOnKeyboard(self.txtRate)
        self.addNextButtonOnKeyboard(self.txtExpiry)
        self.addDoneButtonOnKeyboard(self.txtCID)
        configureTextField()
        handleTextFieldInterfaces()
        months = [["month": "1"], ["month": "2"], ["month": "3"], ["month": "4"], ["month": "5"], ["month": "6"], ["month": "7"], ["month": "8"], ["month": "9"], ["month": "10"], ["month": "11"], ["month": "12"]]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func submitButtonTapped(_ sender: Any) {
        
        formattedPhoneNumber = self.txtCID.text?.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        
        if self.selectedCoordinates == nil {
            Utils.showOKAlertRO("", message: "Location is required", controller: self)
            return
        }
        if Utils.isTextFieldEmpty(self.txtTitle) {
            Utils.showOKAlertRO("", message: "Expire date is required", controller: self)
            return
        }
        if Utils.isTextFieldEmpty(self.txtRate) {
            Utils.showOKAlertRO("", message: "Rate is required", controller: self)
            return
        }
        if Utils.isTextFieldEmpty(self.txtExpiry) {
            Utils.showOKAlertRO("", message: "Deposit is required", controller: self)
            return
        }
        if formattedPhoneNumber?.characters.count == 0 {
            Utils.showOKAlertRO("", message: "CID is required", controller: self)
            return
        }
        
        self.saveDitchInformation()
        
    }
}

extension CTAViewController {
    
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
            accessorizedView.inputAccessoryView = doneToolbar
        } else if let accessorizedView = view as? UITextField {
            accessorizedView.inputAccessoryView = doneToolbar
            accessorizedView.inputAccessoryView = doneToolbar
        }
        
    }
    
    func btnNextTapped(_ sender: AnyObject) {
        if (sender as! UIBarButtonItem).tag == 2 {
            self.txtExpiry.becomeFirstResponder()
        }
        else if (sender as! UIBarButtonItem).tag == 3 {
            self.txtCID.becomeFirstResponder()
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
    
    fileprivate func configureTextField(){
        autocompleteTextfield.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        autocompleteTextfield.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        autocompleteTextfield.autoCompleteCellHeight = 35.0
        autocompleteTextfield.maximumAutoCompleteCount = 20
        autocompleteTextfield.hidesWhenSelected = true
        autocompleteTextfield.hidesWhenEmpty = true
        autocompleteTextfield.enableAttributedText = true
        autocompleteTextfield.isFromMap = true
        autocompleteTextfield.tag = 105
        autocompleteTextfield.delegate = self
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        autocompleteTextfield.autoCompleteAttributes = attributes
        //autocompleteTextfield.placeholder = "ZIPCODE or CITY"//"Enter City / Region"
        autocompleteTextfield.showCurrentLocation = true
    }
    
    fileprivate func handleTextFieldInterfaces(){
        autocompleteTextfield.onTextChange = {[weak self] text in
            if !text.isEmpty{
                if let dataTask = self?.dataTask {
                    dataTask.cancel()
                }
                self?.fetchAutocompletePlaces(text)
            }
        }
        
        autocompleteTextfield.onSelect = {[weak self] text, indexpath in
            //self!.autocompleteTextfield.resignFirstResponder()
            self!.txtTitle.becomeFirstResponder()
            
            if text == "Current Location" {
                //                self?.currentLocationSelected = true
                AppDelegate.returnAppDelegate().selectedSearchRegion = nil
                AppDelegate.returnAppDelegate().selectedCoordinates = AppDelegate.returnAppDelegate().currentLocation?.coordinate
                
                DispatchQueue.main.async(execute: {
                    KVNProgress.show(withStatus: "Getting Location Info")
                })
                
                Location.reverseGeocodeLocation(AppDelegate.returnAppDelegate().currentLocation!, completion: { (placemark, error) in
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    print("zip")
                    if let zipCode = placemark?.addressDictionary?["ZIP"] as? String {
                        UserDefaults.standard.set(zipCode, forKey: "adZip")
                        UserDefaults.standard.synchronize()
                    }
                    
                })
            }
            else {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                })
                
                
                
                Location.geocodeAddressString(text, completion: { (placemark, error) -> Void in
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    
                    
                    self!.selectedCoordinates = placemark?.location?.coordinate
                    
                })
            }
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
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            
                            if let status = (result as! NSDictionary)["status"] as? String{
                                if status == "OK"{
                                    if let predictions = (result as! NSDictionary)["predictions"] as? NSArray{
                                        var locations = [String]()
                                        for dict in predictions as! [NSDictionary]{
                                            let prediction = (dict["description"] as! String).replacingOccurrences(of: ", United States", with: "")
                                            locations.append(prediction)
                                        }
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            self.autocompleteTextfield.autoCompleteStrings = locations
                                        })
                                        return
                                    }
                                }
                            }
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.autocompleteTextfield.autoCompleteStrings = nil
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
    
    func showPicker(_ items: NSArray, indexPath: IndexPath, andKey key: String) {
        if self.customPicker != nil {
            self.customPicker?.removeFromSuperview()
            self.customPicker = nil
        }
        self.customPicker = CustomPickerView.createPickerViewWithItmes(items, withIndexPath: indexPath, forKey: key)
        self.customPicker?.delegate = self
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.customPicker?.frame = CGRect(x: self.customPicker!.frame.origin.x, y: self.customPicker!.frame.origin.y, width: appDelegate.window!.frame.size.width, height: self.customPicker!.frame.size.height);
        
        self.customPicker!.center = CGPoint(x: self.customPicker!.center.x, y: (appDelegate.window?.frame.size.height)!+192)
        
        self.view.addSubview(self.customPicker!)
        
        UIView.beginAnimations("bringUp", context: nil)
        UIView.setAnimationDuration(0.3)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.customPicker!.center = CGPoint(x: self.customPicker!.center.x, y: (appDelegate.window?.frame.size.height)!-170)
        UIView.commitAnimations()
    }

    
    func showDatePicker(_ selectedDate: Date, withIndexPath indexPath: IndexPath) {
        if self.customPicker != nil {
            self.customPicker?.removeFromSuperview()
            self.customPicker = nil
        }
        
        let currentDate = selectedDate
        self.customPicker = CustomPickerView.createPickerViewWithDate(true, withIndexPath: indexPath, isDateTime: false, andSelectedDate: currentDate)
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
    
    func saveDitchInformation() -> Void {
        
        KVNProgress.show(withStatus: "Saving Ditch Info")
        
        let strURL = "\(APIConstants.BasePath)/api/saveditchinfo"
        
        let strParams = "token=\(DTSConstants.Constants.guestToken)&cta_campaign_id=2&cid=\(self.formattedPhoneNumber!)&lease_value=\(self.txtRate.text!)&latitude=\(self.selectedCoordinates!.latitude)&longitude=\(self.selectedCoordinates!.longitude)&lease_expire=\(self.txtTitle.text!)"
        
        
        
        let paramData = strParams.data(using: String.Encoding.ascii, allowLossyConversion: true)!
        
        let url = URL(string: strURL)
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.httpBody = paramData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let tempData = json as? NSDictionary
                    if tempData != nil {
                        if tempData!["error"] as? String != nil {
                            let error = tempData!["error"] as! String
                            if error == "user_not_found" {
                                UserDefaults.standard.set(nil, forKey: "token")
                                AppDelegate.returnAppDelegate().logOut()
                                return
                            }
                        }
                    }
                    let isSuccess = tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        
                        return
                    }
                    
                    if let response = tempData?["data"] as? [String: AnyObject] {
                        self.receivedCode = response["code"] as! String
                        DispatchQueue.main.async(execute: {
                            let controller = self.storyboard?.instantiateViewController(withIdentifier: "validatePinVC") as! ValidatePinViewController
                            controller.code = self.receivedCode
                            self.navigationController?.pushViewController(controller, animated: true)
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
}

extension CTAViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            self.txtTitle.resignFirstResponder()
            self.autocompleteTextfield.resignFirstResponder()
            self.txtExpiry.resignFirstResponder()
            self.txtRate.resignFirstResponder()
            self.txtCID.resignFirstResponder()
            
            
            
//            let currentDate = Date()
//            let df = DateFormatter()
//            df.dateFormat = "yyyy-MM-dd"
//            self.showDatePicker(currentDate, withIndexPath: IndexPath(row: textField.tag, section: 0))
            self.showPicker(months! as NSArray, indexPath: IndexPath(row: textField.tag, section: 0), andKey: "month")
            
            return false
        }
        
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField.tag == 0 {
//            self.txtTitle.becomeFirstResponder()
//            return false
//        }
        
        
        if textField.tag == 0 {
            if (autocompleteTextfield.autoCompleteStrings?.count)! > 0 {
                self.autocompleteTextfield.text = autocompleteTextfield.autoCompleteStrings![0]
                DispatchQueue.main.async(execute: {
                    KVNProgress.show(withStatus: "Getting Location Info")
                })
                Location.geocodeAddressString(self.autocompleteTextfield.text!, completion: { (placemark, error) -> Void in
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let addressComponents = self.autocompleteTextfield.text!.components(separatedBy: ",")
                    let stringAfterComma = addressComponents[1].trimmingCharacters(in: CharacterSet.whitespaces)
                    let zipComponents = stringAfterComma.components(separatedBy: " ")
                    if zipComponents.count == 2 {
                        let zipString = zipComponents[1]
                        self.selectedCoordinates = placemark?.location?.coordinate
                        AppDelegate.returnAppDelegate().selectedSearchRegion = self.autocompleteTextfield.text!
                        AppDelegate.returnAppDelegate().selectedZip = zipString
                        AppDelegate.returnAppDelegate().selectedCoordinates = placemark?.location?.coordinate
                    }
                    else {
                        AppDelegate.returnAppDelegate().selectedZip = nil
                        self.selectedCoordinates = placemark?.location?.coordinate
                        AppDelegate.returnAppDelegate().selectedSearchRegion = self.autocompleteTextfield.text!
                        AppDelegate.returnAppDelegate().selectedCoordinates = placemark?.location?.coordinate
                    }
                    
                })
            }
            self.txtTitle.becomeFirstResponder()
            return false
        }
        
        textField.resignFirstResponder()
        return true
    }

}

extension CTAViewController: CustomPickerDelegate {
    func didCancelTapped() {
        self.hideCustomPicker()
    }
    
    func didDateSelected(_ date: Date, withIndexPath indexPath: IndexPath) {
        self.hideCustomPicker()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        
        let df1 = DateFormatter()
        df1.dateFormat = "MMM dd yyyy"
        
        self.stratDate = df.string(from: date)
        self.txtTitle.text = df1.string(from: date)
        self.txtRate.becomeFirstResponder()
        
    }
    
    func didDurationSelected(_ duration: String, withIndexPath indexPath: IndexPath) {
        
    }
    
    func didItemSelected(_ optionIndex: NSInteger, andSeletedText selectedText: String, withIndexPath indexPath: IndexPath, andSelectedObject selectedObject: NSDictionary) {
        self.hideCustomPicker()
        if indexPath.row == 1 {
            self.txtTitle.text = selectedText
            self.txtRate.becomeFirstResponder()
        }
    }
}
