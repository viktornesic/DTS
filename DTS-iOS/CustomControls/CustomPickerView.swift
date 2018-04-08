//
//  CustomPickerView.swift
//  ConnetBexio-iOS
//
//  Created by Viktor on 27/02/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

protocol CustomPickerDelegate {
    func didItemSelected(_ optionIndex: NSInteger, andSeletedText selectedText: String, withIndexPath indexPath: IndexPath, andSelectedObject selectedObject: NSDictionary)
    func didCancelTapped()
    func didDateSelected(_ date: Date, withIndexPath indexPath: IndexPath)
    func didDurationSelected(_ duration: String, withIndexPath indexPath: IndexPath)
}

class CustomPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var customPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    var items: NSArray!
    var isDate: Bool!
    var isCountDown: Bool!
    var option: NSInteger!
    var delegate: CustomPickerDelegate?
    var indexPath: IndexPath!
    var key: String!
    class func createPickerViewWithItmes(_ items: NSArray, withIndexPath indexPath: IndexPath, forKey key: String) ->CustomPickerView {
        let pickerView = Bundle.main.loadNibNamed("CustomPickerView", owner: self, options: nil)![0] as! CustomPickerView
        pickerView.items = items
        pickerView.indexPath = indexPath
        pickerView.isDate = false
        pickerView.isCountDown = false
        pickerView.key = key
        pickerView.option = 0
        return pickerView
    }
    
    class func createPickerViewWithDateOnly(_ isDate: Bool, withIndexPath indexPath: IndexPath) ->CustomPickerView {
        let pickerView = Bundle.main.loadNibNamed("CustomPickerView", owner: self, options: nil)![1] as! CustomPickerView
        pickerView.indexPath = indexPath
        pickerView.isDate = isDate
        pickerView.isCountDown = false
        
        return pickerView
    }

    class func createPickerViewWithDate(_ isDate: Bool, withIndexPath indexPath: IndexPath, isDateTime: Bool, andSelectedDate selectedDate: Date) -> CustomPickerView {
        let pickerView = Bundle.main.loadNibNamed("CustomPickerView", owner: self, options: nil)![3] as! CustomPickerView
        pickerView.indexPath = indexPath
        pickerView.isDate = isDate
        pickerView.isCountDown = false
        pickerView.datePicker.date = selectedDate
        
        return pickerView
    }
    
    class func createPickerViewWithDateForDOB(_ isDate: Bool, withIndexPath indexPath: IndexPath, isDateTime: Bool, andSelectedDate selectedDate: Date) -> CustomPickerView {
        let pickerView = Bundle.main.loadNibNamed("CustomPickerView", owner: self, options: nil)![3] as! CustomPickerView
        pickerView.indexPath = indexPath
        pickerView.isDate = isDate
        pickerView.isCountDown = false
        pickerView.datePicker.date = selectedDate
        pickerView.datePicker.maximumDate = selectedDate
        return pickerView
    }
    
    class func createCountDownPickerView(_ indexPath: IndexPath) ->CustomPickerView {
        let pickerView = Bundle.main.loadNibNamed("CustomPickerView", owner: self, options: nil)![2] as! CustomPickerView
        pickerView.indexPath = indexPath
        pickerView.isDate = false
        pickerView.isCountDown = true
        return pickerView
    }
    
    /*class func createPickerViewWithDate(isDate: Bool, withIndexPath indexPath: NSIndexPath, isDateTime: Bool, andSelectedDate selectedDate: NSDate) -> CustomPickerView {
        let pickerView = NSBundle.mainBundle().loadNibNamed("CustomPickerView", owner: self, options: nil)![3] as! CustomPickerView
        pickerView.indexPath = indexPath
        pickerView.isDate = isDate
        pickerView.isCountDown = false
        pickerView.datePicker.date = selectedDate
        return pickerView
    }*/
    

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let item = self.items[row] as? NSDictionary
        return item![self.key] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        option = row
    }

    @IBAction func btnCancel_Tapped(_ sender: AnyObject) {
        if self.delegate != nil {
            self.delegate?.didCancelTapped()
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
    }
    @IBAction func btnDone_Tapped(_ sender: AnyObject) {
        if self.isCountDown == true {
            if self.delegate != nil {
                let hours = Int(self.datePicker.countDownDuration/3600)
                let minutes = Int((self.datePicker.countDownDuration.truncatingRemainder(dividingBy: 3600)) / 60)
                var strHours = ("\(hours)")
                var strMinutes = ("\(minutes)")
                if strHours.characters.count == 1 {
                    strHours = ("0\(strHours)")
                }
                
                if (strMinutes.characters.count == 1) {
                    strMinutes = ("0\(strMinutes)")
                }
                
                let strDuration = ("\(strHours):\(strMinutes)")
                self.delegate?.didDurationSelected(strDuration, withIndexPath: self.indexPath)
            }
        }
        else {
            if self.isDate == true {
                if self.delegate != nil {
                    self.delegate?.didDateSelected(self.datePicker.date, withIndexPath: self.indexPath)
                }
            }
            else {
                if self.delegate != nil {
                    let item = self.items[option] as? NSDictionary
                    self.delegate?.didItemSelected(option, andSeletedText: item![self.key] as! String, withIndexPath: self.indexPath, andSelectedObject: item!)
                }
            }
        }
        
    }
}
