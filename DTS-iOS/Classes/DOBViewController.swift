//
//  DOBViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 10/02/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit

class DOBViewController: UIViewController {

    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var txtDOB: AKMaskField!
    var customPicker: CustomPickerView?
    var dob: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtDOB.delegate = self
        let revealController = revealViewController()
        revealController?.panGestureRecognizer()
        revealController?.tapGestureRecognizer()
        
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        self.showDatePicker()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SSNViewController") as! SSNViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }

}

extension DOBViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.showDatePicker()
        return false
    }
}

extension DOBViewController {
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

extension DOBViewController: CustomPickerDelegate {
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
        self.txtDOB.text = df.string(from: date)
    }
    
    func didDurationSelected(_ duration: String, withIndexPath indexPath: IndexPath) {
        
    }
    
    func didItemSelected(_ optionIndex: NSInteger, andSeletedText selectedText: String, withIndexPath indexPath: IndexPath, andSelectedObject selectedObject: NSDictionary) {
        self.hideCustomPicker()
        
    }
}
