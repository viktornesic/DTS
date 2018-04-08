//
//  Utils.swift
//  ConnetBexio-iOS
//
//  Created by Viktor on 21/02/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import QuartzCore

protocol UtilsDelegate {
    func didPressedOkayButton()
}

class Utils: NSObject {
    
    var delegate: UtilsDelegate?
    
    class func formateButtonInView(_ view: UIView) -> Void {
        for subView in view.subviews {
            if subView.isKind(of: UIButton.self) {
                let button = subView as! UIButton
                if button.tag < 100 {
                    button.setBackgroundImage(UIImage(named: "filter_default.png"), for: UIControlState())
                    button.setBackgroundImage(UIImage(named: "filter_selected.png"), for: .selected)
                    button.contentHorizontalAlignment = .left
                    button.contentEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 0)
                }
            }
        }
    }
    
    class func formateStringToDate(_ strDate: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = df.date(from: strDate)
        return date!
    }
    
    class func calculateDaysBetweenDates(_ currentDate: String, createdDate: String) -> Int {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let fromDate = df.date(from: createdDate)
        let toDate = Date()
        let currentCalendar = Calendar.current
        let daysBetween = currentCalendar.dateComponents([.day], from: fromDate!, to: toDate).day ?? 0
        return daysBetween
    }
    
    class func suffixNumber(_ number:NSNumber) -> NSString {
        
        var num:Double = number.doubleValue;
        let sign = ((num < 0) ? "-" : "" );
        
        num = fabs(num);
        
        if (num < 1000.0){
            let numAsInt = Int(num)
            return "\(sign)\(numAsInt)" as NSString;
        }
        
        let exp:Int = Int(log10(num) / 3.0 ); //log10(1000));
        
        let units:[String] = ["K","M","G","T","P","E"];
        
//        let roundedNum:Double = round(10 * num / pow(1000.0,Double(exp))) / 10;
        
        let roundedNum:Double = round(100 * num / pow(1000.0,Double(exp))) / 100;
        
        var strRoundedNum = String(roundedNum)
        
        strRoundedNum = strRoundedNum.replacingOccurrences(of: ".0", with: "")
        
        let digitstAfterDecimal = strRoundedNum.components(separatedBy: ".")
        if digitstAfterDecimal.count > 0 {
            let strDecimalDigits = digitstAfterDecimal.last
            if strDecimalDigits!.characters.count > 1 {
                strRoundedNum = String(strRoundedNum.characters.dropLast())
            }
        }
        
        
        return "\(sign)\(strRoundedNum)\(units[exp-1])" as NSString;
        
        
//        if num % 100 == 0 {
//            let roundedNumToBeReturned = Int(roundedNum)
//            return "\(sign)\(roundedNumToBeReturned)\(units[exp-1])";
//        }
//        else {
//            return "\(sign)\(roundedNum)\(units[exp-1])";
//        }
    }
    
    class func resetAllBttonsInView(_ view: UIView) -> Void {
        for subView in view.subviews {
            if subView.isKind(of: UIButton.self) {
                let button = subView as! UIButton
                if button.tag < 100 {
                    button.isSelected = false
                }
            }
        }
    }
    
    class func formateSingleButton(_ button: UIButton) -> Void {
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor(hexString: "e7e7e7")
        button.clipsToBounds = true
    }
    
    class func setPaddingForTextFieldInView(_ view: UIView) ->Void {
        for subView in view.subviews {
            if subView.isKind(of: UITextField.self) {
                let textField = subView as! UITextField
                let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 20))
                textField.leftView = paddingView
                textField.leftViewMode = .always
                textField.layer.borderColor = UIColor.gray.cgColor
                textField.layer.borderWidth = 1
            }
        }
    }

    
    func showOKAlert(_ title: String, message: String, controller: UIViewController, isActionRequired: Bool)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (alertAction) in
            if isActionRequired == true {
                if self.delegate != nil {
                    self.delegate?.didPressedOkayButton()
                }
            }
        }))
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func showOKAlertRO(_ title: String, message: String, controller: UIViewController)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func isTextFieldEmpty(_ textField: UITextField) -> Bool {
        if textField.text!.trimmingCharacters(in: CharacterSet.whitespaces).characters.count == 0 {
            return true
        }
        return false
    }
    
    class func isTextViewEmpty(_ textView: UITextView) -> Bool {
        if textView.text!.trimmingCharacters(in: CharacterSet.whitespaces).characters.count == 0 {
            return true
        }
        return false
    }
    
    class func validateEmailAddress(_ candidate: String) -> Bool {
        let emailRegex = "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: candidate)
    }
    
    class func archiveSearch(_ array: NSArray, keyTitle: String) -> Void {
        let data = NSKeyedArchiver.archivedData(withRootObject: array)
        UserDefaults.standard.set(data, forKey: keyTitle)
        UserDefaults.standard.synchronize()
    }
    
    class func unarchiveSearch(_ keyTitle: String) -> NSArray? {
        let data = UserDefaults.standard.object(forKey: keyTitle) as? Data
        if data == nil {
            return nil
        }
        let arrayToReturn = NSKeyedUnarchiver.unarchiveObject(with: data!) as? NSArray
        return arrayToReturn
    }
    
    class func archiveDict(_ dict: NSDictionary!) -> Void {
        let data = NSKeyedArchiver.archivedData(withRootObject: dict)
        UserDefaults.standard.set(data, forKey: "dictMetaData")
        UserDefaults.standard.synchronize()
    }
    
    class func unarchiveData() -> NSDictionary {
        let data = UserDefaults.standard.object(forKey: "dictMetaData") as! Data
        let dictToReturn = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
        return dictToReturn
    }
    
    class func archiveArray(_ array: NSArray, forKey key: String) -> Void {
        let data = NSKeyedArchiver.archivedData(withRootObject: array)
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func unarchiveDataForKey(_ key: String) -> NSArray? {
        if let data = UserDefaults.standard.object(forKey: key) as? Data {
            let arrToReturn = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSArray
            return arrToReturn
        }
        return nil
    }
    
    class func saveImageJPG(_ image: UIImage, projectID: Int) -> Bool
    {
        var documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        documentsPath = ("\(documentsPath)/\(projectID).jpg")
        print(documentsPath)
        let imageData = UIImageJPEGRepresentation(image, 0.75)
        if (try? imageData!.write(to: URL(fileURLWithPath: documentsPath), options: [.atomic])) != nil {
            return true
        }
        return false
    }
    
    class func scaleUIImageToSize( _ image: UIImage, size: CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    class func getAbbreviationByStateName(stateName: String) -> String? {
        let stateDictionary: [String : String] = [ "Alaska" : "AK", "Alabama" : "AL", "Arkansas" : "AR", "American Samoa" : "AS", "Arizona" : "AZ", "California" : "CA", "Colorado" : "CO", "Connecticut" : "CT", "District of Columbia" : "DC", "Delaware" : "DE", "Florida" : "FL", "Georgia" : "GA", "Guam" : "GU", "Hawaii" : "HI", "Iowa" : "IA", "Idaho" : "ID", "Illinois" : "IL", "Indiana" : "IN", "Kansas" : "KS", "Kentucky" : "KY", "Louisiana" : "LA", "Massachusetts" : "MA", "Maryland" : "MD", "Maine" : "ME", "Michigan" : "MI", "Minnesota" : "MN", "Missouri" : "MO", "Mississippi" : "MS", "Montana" : "MT", "North Carolina" : "NC", "North Dakota" : "ND", "Nebraska" : "NE", "New Hampshire" : "NH", "New Jersey" : "NJ", "New Mexico" : "NM", "Nevada" : "NV", "New York" : "NY", "Ohio" : "OH", "Oklahoma" : "OK", "Oregon" : "OR", "Pennsylvania" : "PA", "Puerto Rico" : "PR", "Rhode Island" : "RI", "South Carolina" : "SC", "South Dakota" : "SD", "Tennessee" : "TN", "Texas" : "TX", "Utah" : "UT", "Virginia" : "VA", "Virgin Islands" : "VI", "Vermont" : "VT", "Washington" : "WA", "Wisconsin" : "WI", "West Virginia" : "WV", "Wyoming" : "WY"]
        return stateDictionary[stateName]
    }
    
    class func getStateByAbbreviation(abbreviation: String) -> String? {
        let stateDictionary: [String : String] = [
            "AK" : "Alaska",
            "AL" : "Alabama",
            "AR" : "Arkansas",
            "AS" : "American Samoa",
            "AZ" : "Arizona",
            "CA" : "California",
            "CO" : "Colorado",
            "CT" : "Connecticut",
            "DC" : "District of Columbia",
            "DE" : "Delaware",
            "FL" : "Florida",
            "GA" : "Georgia",
            "GU" : "Guam",
            "HI" : "Hawaii",
            "IA" : "Iowa",
            "ID" : "Idaho",
            "IL" : "Illinois",
            "IN" : "Indiana",
            "KS" : "Kansas",
            "KY" : "Kentucky",
            "LA" : "Louisiana",
            "MA" : "Massachusetts",
            "MD" : "Maryland",
            "ME" : "Maine",
            "MI" : "Michigan",
            "MN" : "Minnesota",
            "MO" : "Missouri",
            "MS" : "Mississippi",
            "MT" : "Montana",
            "NC" : "North Carolina",
            "ND" : " North Dakota",
            "NE" : "Nebraska",
            "NH" : "New Hampshire",
            "NJ" : "New Jersey",
            "NM" : "New Mexico",
            "NV" : "Nevada",
            "NY" : "New York",
            "OH" : "Ohio",
            "OK" : "Oklahoma",
            "OR" : "Oregon",
            "PA" : "Pennsylvania",
            "PR" : "Puerto Rico",
            "RI" : "Rhode Island",
            "SC" : "South Carolina",
            "SD" : "South Dakota",
            "TN" : "Tennessee",
            "TX" : "Texas",
            "UT" : "Utah",
            "VA" : "Virginia",
            "VI" : "Virgin Islands",
            "VT" : "Vermont",
            "WA" : "Washington",
            "WI" : "Wisconsin",
            "WV" : "West Virginia",
            "WY" : "Wyoming"]
        return stateDictionary[abbreviation]
    }


}

extension UIImageView {
    
    public func sd_setImageWithURLWithFade(url: URL?, placeholderImage placeholder: UIImage?)
    {
        self.sd_setImage(with: url, placeholderImage: placeholder) { (image, error, cacheType, url) -> Void in
            
            if let downLoadedImage = image
            {
                if cacheType == .none
                {
                    self.alpha = 0
                    UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.image = downLoadedImage
                        self.alpha = 1
                        self.contentMode = .scaleAspectFill
                        
                    }, completion: nil)
                }
            }
            else
            {
                self.contentMode = .scaleToFill
                self.image = placeholder
            }
        }
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}



