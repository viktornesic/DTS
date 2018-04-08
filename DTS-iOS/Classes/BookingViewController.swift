//
//  BookingViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 15/12/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import KVNProgress

class BookingViewController: UIViewController {

    @IBOutlet weak var btnGuests: UIButton!
    @IBOutlet weak var btnCheckOut: UIButton!
    @IBOutlet weak var btnCheckin: UIButton!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblTerm: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblCaluclatedCost: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    
    var dictProperty: [String: AnyObject]!
    var pickerView: MonthPickerView?
    var isCheckIn: Bool!
    var checkInDate: Date?
    var checkOutDate: Date?
    var totalPrice: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let priceNumber = NSNumber.init(value: dictProperty["price"] as! Int)
        let price = Utils.suffixNumber(priceNumber)
        self.lblPrice.text = "$\(price)"
        
        let term = "per \(self.dictProperty["term"]!)"
        let capitalisedTerm = term.capitalized
        self.lblTerm.text = capitalisedTerm
        self.isCheckIn = true
        
        self.btnGuests.setTitle("1", for: .normal)
        
        self.lblTotal.text = ""
        self.lblCaluclatedCost.text = ""
        self.lblDuration.text = ""
        self.lblTotal.text = "$0"
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func checkInButtonTapped(_ sender: Any) {
        if self.dictProperty["term"] as! String == "month" {
            self.isCheckIn = true
            self.showPicker()
        }
        else {
            let datePicker = ActionSheetDatePicker(title: "Check in:", datePickerMode: UIDatePickerMode.date, selectedDate: Date(), doneBlock: {
                picker, value, index in

                print("value = \(value ?? "")")
                print("index = \(index ?? 0)")
                //print("picker = \(picker ?? )")
                let df = DateFormatter()
                df.dateFormat = "MM-dd-yyyy"
                let dateSelected = value as! Date
                
                self.checkInDate = df.date(from: df.string(from: dateSelected))
                if self.checkOutDate != nil {
                    if self.checkOutDate!.compare(self.checkInDate!) == .orderedSame || self.checkOutDate!.compare(self.checkInDate!) == .orderedAscending {
                        Utils.showOKAlertRO("", message: "Check out date should be greater than check in date.", controller: self)
                        return
                    }
                }
                
                (sender as! UIButton).setTitle(df.string(from: dateSelected), for: .normal)
                
                if self.btnCheckin.titleLabel?.text != "Select" && self.btnCheckOut.titleLabel?.text != "Select" {
                    let checkInDate = df.date(from: (self.btnCheckin.titleLabel?.text)!)
                    let checkOutDate = df.date(from: (self.btnCheckOut.titleLabel?.text)!)
                    let months = checkOutDate!.months(from: checkInDate!)
                    let priceNumber = NSNumber.init(value: self.dictProperty["price"] as! Int)
                    let price = Utils.suffixNumber(priceNumber)
                    let totalPriceInteger = (self.dictProperty["price"] as! Int) * months
                    let totalPriceNumber = NSNumber.init(value: totalPriceInteger)
                    let totalPrice = Utils.suffixNumber(totalPriceNumber)
                    self.lblDuration.text = "$\(price) x \(months) month(s)"
                    self.lblCaluclatedCost.text = "$\(totalPrice)"
                    self.lblTotal.text = "$\(totalPrice)"
                    self.totalPrice = "\(totalPriceInteger)"
                }
                
                return
            }, cancel: { ActionStringCancelBlock in return }, origin: (sender as! UIButton).superview!.superview)
            let secondsInWeek: TimeInterval = 7 * 24 * 60 * 60;
            datePicker?.minimumDate = Date(timeInterval: -secondsInWeek, since: Date())
            datePicker?.maximumDate = Date(timeInterval: secondsInWeek, since: Date())
            
            datePicker?.show()
        }
    }
    
    @IBAction func checkOutButtonTapped(_ sender: Any) {
        if self.dictProperty["term"] as! String == "month" {
            self.isCheckIn = false
            self.showPicker()
        }
        else {
            let datePicker = ActionSheetDatePicker(title: "Check out:", datePickerMode: UIDatePickerMode.date, selectedDate: Date(), doneBlock: {
                picker, value, index in
                
                print("value = \(value ?? "")")
                print("index = \(index ?? 0)")
                //print("picker = \(picker ?? )")
                let df = DateFormatter()
                df.dateFormat = "MM-dd-yyyy"
                let dateSelected = value as! Date
                self.checkOutDate = df.date(from: df.string(from: dateSelected))
                if self.checkInDate != nil {
                    if self.checkOutDate!.compare(self.checkInDate!) == .orderedSame || self.checkOutDate!.compare(self.checkInDate!) == .orderedAscending {
                        Utils.showOKAlertRO("", message: "Check out date should be greater than check in date.", controller: self)
                        return
                    }
                }
                
                (sender as! UIButton).setTitle(df.string(from: dateSelected), for: .normal)
                
                if self.btnCheckin.titleLabel?.text != "Select" && self.btnCheckOut.titleLabel?.text != "Select" {
                    
                    let checkInDate = df.date(from: (self.btnCheckin.titleLabel?.text)!)
                    let checkOutDate = df.date(from: (self.btnCheckOut.titleLabel?.text)!)
                    let months = checkOutDate!.months(from: checkInDate!)
                    let priceNumber = NSNumber.init(value: self.dictProperty["price"] as! Int)
                    let price = Utils.suffixNumber(priceNumber)
                    let totalPriceInteger = (self.dictProperty["price"] as! Int) * months
                    let totalPriceNumber = NSNumber.init(value: totalPriceInteger)
                    let totalPrice = Utils.suffixNumber(totalPriceNumber)
                    self.lblDuration.text = "$\(price) x \(months) month(s)"
                    self.lblCaluclatedCost.text = "$\(totalPrice)"
                    self.lblTotal.text = "$\(totalPrice)"
                    self.totalPrice = "\(totalPriceInteger)"
                }
                
                return
            }, cancel: { ActionStringCancelBlock in return }, origin: (sender as! UIButton).superview!.superview)
            let secondsInWeek: TimeInterval = 7 * 24 * 60 * 60;
            datePicker?.minimumDate = Date(timeInterval: -secondsInWeek, since: Date())
            datePicker?.maximumDate = Date(timeInterval: secondsInWeek, since: Date())
            
            datePicker?.show()
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        DispatchQueue.main.async(execute: {
            if AppDelegate.returnAppDelegate().dwollaCustomerStatus != nil {
                
                if AppDelegate.returnAppDelegate().paymentMethods.count > 0 {
                    if self.btnCheckin.titleLabel?.text == "Select" {
                        Utils.showOKAlertRO("", message: "Please select check in date.", controller: self)
                        return
                    }
                    if self.btnCheckOut.titleLabel?.text == "Select" {
                        Utils.showOKAlertRO("", message: "Please select check out date.", controller: self)
                        return
                    }
                    
                    self.submitBooking()
                }
                else {
                    let paymentMethodVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "paymentMethodsVC") as! PaymentMethodsViewController
                    paymentMethodVC.isFromBooking = true
                    self.navigationController?.pushViewController(paymentMethodVC, animated: true)
                }
            }
            else {
                let paymentMethodVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FNViewController") as! FNViewController
                paymentMethodVC.isFromBooking = true
                self.navigationController?.pushViewController(paymentMethodVC, animated: true)
            }
        })
    }
    
    @IBAction func guestButtonTapped(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "Guests", rows: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"], initialSelection: 1, doneBlock: {
            picker, value, index in

            (sender as! UIButton).setTitle(index as? String ?? "", for: .normal)
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
}

extension BookingViewController {
    func showPicker() {
        if self.pickerView != nil {
            self.pickerView?.removeFromSuperview()
            self.pickerView = nil
        }
        self.pickerView = MonthPickerView.setUpMonthPickerView(selectedDateListener: { (pickerViwe, month, year) in
            self.hideCustomPicker()

            let dateSelectedString = "\(month)-01-\(year)"
            let df = DateFormatter()
            df.dateFormat = "MM-dd-yyyy"
            let dateConverted = df.date(from: dateSelectedString)
            let dateSelected = df.string(from: dateConverted!)
            
            if self.isCheckIn == true {
                self.checkInDate = dateConverted!
                if self.checkOutDate != nil {
                    if self.checkOutDate!.compare(self.checkInDate!) == .orderedSame || self.checkOutDate!.compare(self.checkInDate!) == .orderedAscending {
                        Utils.showOKAlertRO("", message: "Check out date should be greater than check in date.", controller: self)
                        return
                    }
                }
                self.btnCheckin.setTitle(dateSelected, for: .normal)
            }
            else {
                self.checkOutDate = dateConverted!
                if self.checkInDate != nil {
                    if self.checkOutDate!.compare(self.checkInDate!) == .orderedSame || self.checkOutDate!.compare(self.checkInDate!) == .orderedAscending {
                        Utils.showOKAlertRO("", message: "Check out date should be greater than check in date.", controller: self)
                        return
                    }
                }
                self.btnCheckOut.setTitle(dateSelected, for: .normal)
            }
            
            
            if self.btnCheckin.titleLabel?.text != "Select" && self.btnCheckOut.titleLabel?.text != "Select" {
                
                let checkInDate = df.date(from: (self.btnCheckin.titleLabel?.text)!)
                let checkOutDate = df.date(from: (self.btnCheckOut.titleLabel?.text)!)
                let months = checkOutDate!.months(from: checkInDate!)
                let priceNumber = NSNumber.init(value: self.dictProperty["price"] as! Int)
                let price = Utils.suffixNumber(priceNumber)
                let totalPriceInteger = (self.dictProperty["price"] as! Int) * months
                let totalPriceNumber = NSNumber.init(value: totalPriceInteger)
                let totalPrice = Utils.suffixNumber(totalPriceNumber)
                self.lblDuration.text = "$\(price) x \(months) month(s)"
                self.lblCaluclatedCost.text = "$\(totalPrice)"
                self.lblTotal.text = "$\(totalPrice)"
                self.totalPrice = "\(totalPriceInteger)"
            }
            
        }, cancelButtonListener: { (pickerView) in
            self.hideCustomPicker()
        })
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.pickerView?.frame = CGRect(x: self.pickerView!.frame.origin.x, y: self.pickerView!.frame.origin.y, width: UIScreen.main.bounds.width, height: self.pickerView!.frame.size.height)
        
        
        self.pickerView!.center = CGPoint(x: self.pickerView!.center.x, y: (appDelegate.window?.frame.size.height)!+192)
        
        self.view.addSubview(self.pickerView!)
        
        UIView.beginAnimations("bringUp", context: nil)
        UIView.setAnimationDuration(0.3)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.pickerView!.center = CGPoint(x: self.pickerView!.center.x, y: (appDelegate.window?.frame.size.height)!-130)
        UIView.commitAnimations()
    }
    
    func hideCustomPicker() {
        if self.pickerView == nil {
            return
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        UIView.beginAnimations("bringDown", context: nil)
        UIView.setAnimationDuration(0.3)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.pickerView!.center = CGPoint(x: self.pickerView!.center.x, y: (appDelegate.window?.frame.size.height)!+192)
        UIView.commitAnimations()
    }
}

extension BookingViewController {
    func submitBooking() -> Void {
        KVNProgress.show(withStatus: "Submitting Booking Request")
        
        var token = ""
        let strURL = "\(APIConstants.BasePath)/api/generateleaseproposal"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
        }
        
        
        let strParams = "token=\(token)&property_id=\(self.dictProperty["id"]!)&amount=\(self.totalPrice!)&start_date=\((self.btnCheckin.titleLabel?.text)!)&end_date=\((self.btnCheckOut.titleLabel?.text)!)"
        
        
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
                    
                    let isSuccess = tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                        })
                        let _utils = Utils()
                        _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        return
                    }
                    
                    DispatchQueue.main.async(execute: {
                        let successVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "successVC") as! SuccessViewController
                        successVC.successMessage = "Your booking request has been sent."
                        self.navigationController?.pushViewController(successVC, animated: true)
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
            return()
            }.resume()
        
    }

}
