//
//  TargetDestinationViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 21/12/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress

class TargetDestinationViewController: UIViewController {

    @IBOutlet weak var lblBed: UILabel!
    @IBOutlet weak var lblBath: UILabel!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var autocompleteTextfield: AutoCompleteTextField!
    
    fileprivate var responseData:NSMutableData?
    fileprivate var dataTask:URLSessionDataTask?
    
    @IBOutlet weak var btnSideMenu: UIButton!
    fileprivate let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    fileprivate let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    
    var strBeds: String!
    var strBaths: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextField()
        handleTextFieldInterfaces()
        let revealController = revealViewController()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        strBeds = "1"
        strBaths = "1"
        
        self.txtPrice.keyboardType = .numberPad
        self.txtPrice.delegate = self
        let frameView = CGRect(x: 0, y: 0, width: 45, height: 40)
        let viewLeft = UIView(frame: frameView)
        let lblFrame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let lblCurrencySign = UILabel(frame: lblFrame)
        lblCurrencySign.text = "$"
        lblCurrencySign.backgroundColor = UIColor(hexString: "f1f1f1")
        lblCurrencySign.textAlignment = .center
        viewLeft.addSubview(lblCurrencySign)
        self.txtPrice.leftView = viewLeft
        self.txtPrice.leftViewMode = .always
        
        self.txtPrice.layer.cornerRadius = 4
        self.txtPrice.layer.borderColor = UIColor(hexString: "d2d2d2").cgColor
        self.txtPrice.layer.borderWidth = 1
        self.addDoneButtonOnKeyboard(self.txtPrice)
        self.lblBed.text = strBeds
        self.lblBath.text = strBaths
        
        self.txtPrice.tag = 100
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if Utils.isTextFieldEmpty(self.autocompleteTextfield) {
            Utils.showOKAlertRO("", message: "Location is required.", controller: self)
            return
        }
        
        if Utils.isTextFieldEmpty(self.txtPrice) {
            Utils.showOKAlertRO("", message: "Price is required.", controller: self)
            return
        }
        
        AppDelegate.returnAppDelegate().userProperty.setObject(self.txtPrice.text!, forKey: "relocationTargetPrice" as NSCopying)
        AppDelegate.returnAppDelegate().userProperty.setObject(self.lblBed.text!, forKey: "relocationTargetBed" as NSCopying)
        AppDelegate.returnAppDelegate().userProperty.setObject(self.lblBath.text!, forKey: "relocationTargetBath" as NSCopying)
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "uclclassVC") as? UCLClassViewController
        controller!.listType = "class"
        controller?.hideBackButton = false
        controller?.hideSideButton = false
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    @IBAction func btnLess_Tapped(_ sender: AnyObject) {
        let btn = sender as! UIButton
        if btn.tag == 1 {
            var beds = Int(strBeds)
            if beds! > 1 {
                beds! = beds! - 1
                self.lblBed.text = String(beds!)
                strBeds = self.lblBed.text!
            }
        }
        else {
            var baths = Int(strBaths)
            if baths! > 1 {
                baths! = baths! - 1
                self.lblBath.text = String(baths!)
                strBeds = self.lblBath.text!
            }
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

    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPlus_Tapped(_ sender: AnyObject) {
        let btn = sender as! UIButton
        if btn.tag == 2 {
            var beds = Int(strBeds)
            
            beds! = beds! + 1
            self.lblBed.text = String(beds!)
            strBeds = self.lblBed.text!
            
        }
        else {
            var baths = Int(strBaths)
            
            baths! = baths! + 1
            self.lblBath.text = String(baths!)
            strBaths = self.lblBath.text!
            
        }
    }

}

extension TargetDestinationViewController {
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
        autocompleteTextfield.showCurrentLocation = false
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        autocompleteTextfield.autoCompleteAttributes = attributes
        autocompleteTextfield.placeholder = "Enter City / Region"
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
            self!.autocompleteTextfield.resignFirstResponder()
            DispatchQueue.main.async(execute: {
                KVNProgress.show(withStatus: "Getting Location Info")
            })
            
            
            
            Location.geocodeAddressString(text, completion: { (placemark, error) -> Void in
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                    if let dictAddress = placemark?.addressDictionary {
                        
                        let city = dictAddress["City"] as? String ?? ""
                        let state = dictAddress["State"] as? String ?? ""
                        
                        
                        
                        AppDelegate.returnAppDelegate().userProperty.setObject(city, forKey: "relo_target_city" as NSCopying)
                        AppDelegate.returnAppDelegate().userProperty.setObject(state, forKey: "relo_target_state" as NSCopying)
                        
                    }
                })
            })
        }
    }
    
    fileprivate func fetchAutocompletePlaces(_ keyword:String) {
        let urlString = "\(baseURLString)?key=\(googleMapsKey)&input=\(keyword)&types=(cities)&components=country:usa"
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
}

extension TargetDestinationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
