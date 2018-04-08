//
//  FeedbackViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 20/10/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress

class FeedbackViewController: UIViewController {

    @IBOutlet weak var lblRemainingCharacters: UILabel!
    @IBOutlet weak var btnDisLike: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var tvMessage: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnSideMenu: UIButton!
    var customPicker: CustomPickerView?
    
    var isLiked: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let revealController = revealViewController()
        revealController?.panGestureRecognizer()
        revealController?.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        let likedDefaultImage = UIImage(named: "smile_face.png")
        let likedSelectedImage = likedDefaultImage?.withRenderingMode(.alwaysTemplate)
        btnLike.setImage(likedSelectedImage, for: .selected)
        btnLike.imageView?.maskWith(color: UIColor.white)
        
        let dislikedDefaultImage = UIImage(named: "sad_face.png")
        let dislikedSelectedImage = dislikedDefaultImage?.withRenderingMode(.alwaysTemplate)
        btnDisLike.setImage(dislikedSelectedImage, for: .selected)
        btnDisLike.imageView?.maskWith(color: UIColor.white)
        
        
        self.lblRemainingCharacters.text = "120 remaining"
        self.tvMessage.layer.cornerRadius = 6
        self.tvMessage.layer.borderColor = UIColor(hexString: "d2d2d2").cgColor
        self.tvMessage.layer.borderWidth = 1
        self.tvMessage.delegate = self
        //self.addDoneButtonOnKeyboard(self.tvMessage)
        
        self.tvMessage.becomeFirstResponder()
    }

    @IBAction func dislikeButtonTapped(_ sender: AnyObject) {
        self.btnDisLike.isSelected = true
        self.btnLike.isSelected = false
        self.isLiked = false
        btnLike.imageView?.maskWith(color: UIColor.white)
        btnDisLike.imageView?.maskWith(color: UIColor.green)
    }
    
    @IBAction func likeButtonTapped(_ sender: AnyObject) {
        self.btnDisLike.isSelected = false
        self.btnLike.isSelected = true
        self.isLiked = true
        btnLike.imageView?.maskWith(color: UIColor.green)
        btnDisLike.imageView?.maskWith(color: UIColor.white)
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
    
    @IBAction func submitButtonTapped(_ sender: AnyObject) {
        if self.customPicker != nil {
            self.hideCustomPicker()
        }
        self.tvMessage.resignFirstResponder()
        if isLiked == nil || Utils.isTextViewEmpty(self.tvMessage) {
            return
        }
        KVNProgress.show(withStatus: "Submitting Feedback")
        if let token = UserDefaults.standard.object(forKey: "token") as? String {
            var feedback = "POSITIVE"
            if isLiked == false {
                feedback = "NEGATIVE"
            }
            let dictParams = ["token": token, "type": feedback, "message": self.tvMessage.text!]
            self.sendSupport(dictParams as NSDictionary)
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
    
    func sendSupport(_ dictParam: NSDictionary) -> Void {
        let strURL = "\(APIConstants.BasePath)/api/feedback"
        
        do {
            let jsonParamsData = try JSONSerialization.data(withJSONObject: dictParam, options: [])
            
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
                        let dict = json as? NSDictionary
                        let isSuccess = dict!["success"] as! Bool
                        
                        if isSuccess == false {
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: dict!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        }
                        
                        DispatchQueue.main.async(execute: {
                            let successVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "successVC") as! SuccessViewController
                            self.navigationController?.pushViewController(successVC, animated: true)
                        })
                        
                        
//                        let _utils = Utils()
//                        _utils.showOKAlert("", message: "Your feedback has been sent.", controller: self, isActionRequired: false)
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
}

extension FeedbackViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let types = [["id": "1", "title": "Cannot login"], ["id": "1", "title": "Site error"], ["id": "1", "title": "Page won't load"], ["id": "1", "title": "Account issue"], ["id": "1", "title": "General"], ["id": "1", "title": "Other"]]
        self.showPicker(types as NSArray, indexPath: IndexPath(row: textField.tag, section: 0), andKey: "title")
        return false
    }
}

extension FeedbackViewController: CustomPickerDelegate {
    func didCancelTapped() {
        self.hideCustomPicker()
    }
    
    func didDateSelected(_ date: Date, withIndexPath indexPath: IndexPath) {
        self.hideCustomPicker()
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        
    }
    
    func didDurationSelected(_ duration: String, withIndexPath indexPath: IndexPath) {
        
    }
    
    func didItemSelected(_ optionIndex: NSInteger, andSeletedText selectedText: String, withIndexPath indexPath: IndexPath, andSelectedObject selectedObject: NSDictionary) {
        self.hideCustomPicker()
        
    }
}

extension FeedbackViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        self.lblRemainingCharacters.text = String(120 - newText.characters.count + 1) + " remaining"
        return numberOfChars <= 120;
    }
}

extension UIImageView {
    
    func maskWith(color: UIColor) {
        guard let tempImage = image?.withRenderingMode(.alwaysTemplate) else { return }
        image = tempImage
        tintColor = color
    }
    
}
