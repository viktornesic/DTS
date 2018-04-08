//
//  SignUpViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 12/04/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

import KVNProgress
import QuartzCore

@objc protocol SignupViewControllerDelegate {
    
    @objc optional func didSignedUpSuccessfully()
    @objc optional func didCacnelled()
}

class SignUpViewController: BaseViewController, UITextFieldDelegate, UtilsDelegate {
    @IBOutlet weak var lblDwollaText: UITextView!
    @IBOutlet weak var viewCheckBox: UIView!
    @IBOutlet weak var viewInnerCheck: UIView!

    @IBOutlet weak var constraintEYCC: NSLayoutConstraint!
    @IBOutlet weak var constraintCSNT: NSLayoutConstraint!
    @IBOutlet weak var constraintCN: NSLayoutConstraint!
    @IBOutlet weak var constraintCST: NSLayoutConstraint!
    @IBOutlet weak var constraintEYCClose: NSLayoutConstraint!
    @IBOutlet weak var constraintEYC: NSLayoutConstraint!
    @IBOutlet weak var constraintSN: NSLayoutConstraint!
    @IBOutlet weak var constraintPhone: NSLayoutConstraint!
    @IBOutlet weak var constraintClose: NSLayoutConstraint!
    @IBOutlet weak var constraintTMC: NSLayoutConstraint!
    @IBOutlet weak var constraintEYP: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var viewTOS: UIView!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var txtPinCode: AKMaskField!
    @IBOutlet weak var viewPinCode: UIView!
    @IBOutlet weak var viewSending: UIView!
    @IBOutlet weak var viewCID: UIView!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnSendPin: UIButton!
    @IBOutlet weak var txtPhoneNumber: AKMaskField!
    var delegate: SignupViewControllerDelegate?
    var propertyId: String?
    
    var reqType: Int?
    var selectedTag: Int!
    var formattedPhoneNumberForPin: String!
    var plainPhoneNumber: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UserDefaults.standard.object(forKey: "laFN")
        UserDefaults.standard.set(nil, forKey: "laFN")
        
        self.viewCheckBox.layer.cornerRadius = self.viewCheckBox.frame.width / 2
        self.viewInnerCheck.layer.cornerRadius = self.viewInnerCheck.frame.width / 2
        self.viewCheckBox.layer.borderColor = UIColor(hexString: "a4a4a4").cgColor
        self.viewCheckBox.layer.borderWidth = 2
        //self.view.backgroundColor = UIColor.white
        
        self.viewTOS.alpha = 0
        self.viewCID.alpha = 0
        self.viewPinCode.alpha = 0
        self.viewSending.alpha = 0
        self.viewTOS.isHidden = false
        self.viewCID.isHidden = true
        self.viewSending.isHidden = true
        self.viewPinCode.isHidden = true
        
        self.txtPhoneNumber.setMask("({ddd}) {ddd}-{dddd}", withMaskTemplate: "(###) ###-####")
        self.txtPinCode.setMask("{dddd}", withMaskTemplate: "####")
        
        
        self.txtPhoneNumber.maskDelegate = self
        self.txtPinCode.maskDelegate = self
        self.txtPhoneNumber.keyboardType = .numberPad
        self.txtPinCode.keyboardType = .numberPad
        
        self.activityIndicator.isHidden = false
        self.getTOS()
        
//        UIView.animateWithDuration(0.3, animations: {
//            self.viewCID.alpha = 1
//            self.txtPhoneNumber.becomeFirstResponder()
//            self.view.layoutIfNeeded()
//            
//        }) { (finished: Bool) in
//            
//        }
        
        
        let dwollaFont = UIFont.systemFont(ofSize: 15)
        let attriutedText = NSMutableAttributedString(string: "By signing up are agree to our Mac, LLC. Terms of Service and Privacy Policy,", attributes: [NSFontAttributeName: dwollaFont])
        let attributedDwollaText = NSMutableAttributedString(string: " as well as our partner Dwolla's Terms of Service and Privacy Policy.", attributes: [NSFontAttributeName: dwollaFont])
        _ = attributedDwollaText.setLableTextAsLink("Terms of Service", linkURL: "https://www.dwolla.com/legal/tos/")
        _ = attributedDwollaText.setLableTextAsLink("Privacy Policy", linkURL: "https://www.dwolla.com/legal/privacy/")
        
        attriutedText.append(attributedDwollaText)
        
        
        
        self.lblDwollaText.attributedText = attriutedText
        self.lblDwollaText.textColor = UIColor.white
        self.viewTOS.bringSubview(toFront: self.lblDwollaText)
        //self.lblDwollaText.attributedText = newd
        
        self.btnSendPin.isEnabled = false
        
        
        if UIDevice.current.screenType == .iPhone4 {
            self.constraintEYP.constant = 15
            self.constraintTMC.constant = 10
            self.constraintPhone.constant = 5
            self.constraintClose.constant = 5
            self.constraintSN.constant = 60
            
            self.constraintEYC.constant = 12
            self.constraintCST.constant = 5
            self.constraintCN.constant = 2
            self.constraintEYCClose.constant = 0
            self.constraintCSNT.constant = 5
            self.constraintEYCC.constant = 5
        }
        
//        switch UIDevice.current.userInterfaceIdiom {
//        case .phone:
//            break
//        case .pad:
//            self.constraintEYP.constant = 10
//        case .unspecified:
//            break;
//        default:
//            break
//        }
        
    }
    @IBAction func btnChangePhone_Tapped(_ sender: AnyObject) {
        resetInputs()
    }
    @IBAction func btnCIDClose_Tapped(_ sender: AnyObject) {
        self.txtPhoneNumber.resignFirstResponder()
        UIView.animate(withDuration: 0.6, animations: {
            self.viewCID.alpha = 0
            
        }, completion: { (finished: Bool) in
            self.viewCID.isHidden = true
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    @IBAction func btnPCClose_Tapped(_ sender: AnyObject) {
        self.txtPinCode.resignFirstResponder()
        UIView.animate(withDuration: 0.6, animations: {
            self.viewPinCode.alpha = 0
            
        }, completion: { (finished: Bool) in
            self.viewPinCode.isHidden = true
            self.dismiss(animated: false, completion: nil)
        }) 
    }
    
    func  resetInputs() -> Void {
        self.txtPhoneNumber.text = ""
        self.txtPhoneNumber.text = ""
        self.txtPinCode.text = ""
        
        self.viewCID.isHidden = false
        
        UIView.animate(withDuration: 0.6, animations: {
            self.viewCID.alpha = 1
            
        }, completion: { (finished: Bool) in
            self.viewPinCode.alpha = 0
            self.viewPinCode.isHidden = true
            self.txtPhoneNumber.becomeFirstResponder()
        }) 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.6, animations: {
            self.viewTOS.alpha = 1
            
        }, completion: { (finished: Bool) in
            
        }) 
    }
    
    @IBAction func checkBoxButtonTapped(_ sender: Any) {
        let btn = sender as! UIButton
        
        
        if btn.isSelected == true {
            self.viewInnerCheck.backgroundColor = UIColor.white
            btn.isSelected = false
            self.btnAccept.backgroundColor = UIColor.lightGray
        }
        else {
            self.viewInnerCheck.backgroundColor = UIColor(hexString: "4c93d0")
            btn.isSelected = true
            self.btnAccept.backgroundColor = UIColor(hexString: "00AF50")
        }
        

        //print("\(selectedButtons.count)")
        
//        if selectedButton.isSelected == false {
//            selectedButton.isSelected == true
//        }
//        else {
//            selectedButton.isSelected = false
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func btnSendPin_Tapped(_ sender: AnyObject) {
        if self.txtPhoneNumber.text?.characters.count == 0 {
            let _utils = Utils()
            _utils.showOKAlert("", message: "Please enter phone number", controller: self, isActionRequired: false)
            return
        }
        
        
        self.formattedPhoneNumberForPin = self.txtPhoneNumber.text?.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: ".").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: ".")
        
        self.lblPhoneNumber.text = self.formattedPhoneNumberForPin
        
        self.plainPhoneNumber = self.txtPhoneNumber.text?.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        
        self.viewSending.isHidden = false
        self.viewPinCode.isHidden = true
        
        UIView.animate(withDuration: 0.4, animations: {
            self.viewSending.alpha = 1
            
        }, completion: { (finished: Bool) in
            self.viewCID.alpha = 0
            self.viewCID.isHidden = true
        }) 

        
        requestPinCode(self.plainPhoneNumber)
    }
    
    @IBAction func btnSignUp_Tapped(_ sender: AnyObject) {
        if self.txtPhoneNumber.text?.characters.count == 0 {
            let _utils = Utils()
            _utils.showOKAlert("", message: "Please enter phone number", controller: self, isActionRequired: false)
            return
        }
        if self.txtPinCode.text?.characters.count == 0 {
            let _utils = Utils()
            _utils.showOKAlert("", message: "Please enter pin code", controller: self, isActionRequired: false)
            return
        }
        
        self.txtPinCode.resignFirstResponder()
        self.txtPhoneNumber.resignFirstResponder()
        
        let params = ["token": DTSConstants.Constants.guestToken, "cid": self.txtPhoneNumber.text!, "country_code": "", "code": self.txtPinCode.text!]
        self.registerUser(params as NSDictionary)

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
    @IBAction func tosSavedButtonTapped(_ sender: AnyObject) {
        if self.btnCheckBox.isSelected {
            self.viewCID.isHidden = false
            UIView.animate(withDuration: 0.6, animations: {
                self.viewTOS.alpha = 0
                self.viewCID.alpha = 1
                self.txtPhoneNumber.becomeFirstResponder()
                
            }, completion: { (finished: Bool) in
                self.viewTOS.isHidden = true
            }) 
        }
    }
    @IBAction func tosCancelButtonTapped(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.6, animations: {
            self.viewTOS.alpha = 0
            
        }, completion: { (finished: Bool) in
            self.viewTOS.isHidden = true
            self.dismiss(animated: false, completion: nil)
        }) 
    }
    
    func UpdateRootVC() -> Void {
//        let revealVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("revealVC") as! SWRevealViewController
//        AppDelegate.returnAppDelegate().window?.rootViewController = revealVC
        
        let tabbarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabbarVC") as! UITabBarController
        AppDelegate.returnAppDelegate().window?.rootViewController = tabbarVC

    }
    
    func hideActiveView() -> Void {
        self.txtPinCode.resignFirstResponder()
        UIView.animate(withDuration: 0.6, animations: {
            self.viewPinCode.alpha = 0
            
        }, completion: { (finished: Bool) in
            self.viewPinCode.isHidden = true
            self.dismiss(animated: false, completion: nil)
        }) 
    }
    
    func registerUser(_ dictParam: NSDictionary) -> Void {
//        KVNProgress.show()
    
        let strURL = "\(APIConstants.BasePath)/api/registeruser?token=\(dictParam["token"] as! String)&cid=\(dictParam["cid"] as! String)&code=\(dictParam["code"] as! String)&tos_accepted=1&pp_accepted=1"
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let dict = json as? NSDictionary
                
                if dict!["success"] as! Bool == true {
                    
                    AppDelegate.returnAppDelegate().isAppLoading = true
                    
                    let token = dict!["data"] as! String
                    if let dicMetaData = dict!["metadata"] as? NSDictionary {
                        if let cid = dicMetaData["cid"] as? String {
                            UserDefaults.standard.set(cid, forKey: "cid")
                        }
                    }
                    if self.reqType != nil {
                        if self.reqType! == 0 {
                            self.inquireProperty(token, propertyId: self.propertyId!)
                        }
                        else if self.reqType! == 2 {
                            self.likeProperty(token, propertyId: self.propertyId!)
                        }
                        else if self.reqType! == 5 {
                            self.hideProperty(token, propertyId: self.propertyId!)
                        }
                        else {
                            
                            DispatchQueue.main.async(execute: {
                                self.txtPinCode.textColor = UIColor.green
                                self.txtPinCode.resignFirstResponder()
                            })
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(2200 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                
                                UIView.animate(withDuration: 0.5, animations: {
                                    self.viewPinCode.alpha = 0
                                    
                                }, completion: { (finished: Bool) in
                                    
                                    DispatchQueue.main.async(execute: {
                                        self.txtPinCode.textColor = UIColor.green
                                        self.txtPinCode.resignFirstResponder()
                                    })
                                    self.viewPinCode.isHidden = true
                                    self.dismiss(animated: true, completion: {
                                        UserDefaults.standard.set(token, forKey: "token")
                                        AppDelegate.returnAppDelegate().isFromSignUp = true
                                        AppDelegate.returnAppDelegate().showAnimation = false
                                        
                                        self.UpdateRootVC()
                                    })
                                    
                                }) 

                            })
                            
    
                        }
                        
                    }
                    else {
                        
                        DispatchQueue.main.async(execute: {
                            self.txtPinCode.textColor = UIColor.green
                            self.txtPinCode.resignFirstResponder()
                        })
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(2000 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                            
                            UIView.animate(withDuration: 0.5, animations: {
                                self.viewPinCode.alpha = 0
                                
                                
                            }, completion: { (finished: Bool) in
                                self.viewPinCode.isHidden = true
                                self.dismiss(animated: true, completion: {
                                    UserDefaults.standard.set(token, forKey: "token")
                                    AppDelegate.returnAppDelegate().isFromSignUp = true
                                    AppDelegate.returnAppDelegate().showAnimation = false
                                    self.UpdateRootVC()
                                })
                            }) 
                        })


                    }
                
                    
               
                }
                else {
                    DispatchQueue.main.async(execute: {
                        self.txtPinCode.textColor = UIColor.red
                        self.txtPinCode.shake()
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
    
    func requestPinCode(_ cid: String) -> Void {
        let strURL = ("\(APIConstants.BasePath)/api/requestpin?token=\(DTSConstants.Constants.guestToken)&cid=\(cid)&country_code=")
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let dict = json as? NSDictionary
//                self.btnSendPin.setTitle("Click to send pin to your phone number", forState: .Normal)
                if dict!["success"] as! Bool == true {
                    
                    DispatchQueue.main.async(execute: {
                        self.viewPinCode.isHidden = false
                        
                        UIView.animate(withDuration: 0.5, animations: {
                            self.viewPinCode.alpha = 1
                            
                        }, completion: { (finished: Bool) in
                            self.txtPinCode.becomeFirstResponder()
                            self.viewSending.alpha = 0
                            self.viewSending.isHidden = true
                        }) 
                    })
                    
                    
                }
                else {
                    
                    DispatchQueue.main.async(execute: {
                        self.viewPinCode.isHidden = false
                        self.txtPinCode.textColor = UIColor.black
                    })
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(2000 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                        
                        UIView.animate(withDuration: 0.5, animations: {
                            self.viewPinCode.alpha = 1
                            
                        }, completion: { (finished: Bool) in
                            self.txtPinCode.becomeFirstResponder()
                            self.viewSending.alpha = 0
                            self.viewSending.isHidden = true
                        }) 
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
    
    func didPressedOkayButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func hideProperty(_ token: String, propertyId: String) -> Void {
        //        KVNProgress.show()
        let strURL = ("\(APIConstants.BasePath)/api/hideproperty?token=\(token)&property_id=\(propertyId)")
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    _ = json as? NSDictionary
                    
                    DispatchQueue.main.async(execute: {
                        self.txtPinCode.textColor = UIColor.green
                        self.txtPinCode.resignFirstResponder()
                    })
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(2000 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                        
                        UIView.animate(withDuration: 0.5, animations: {
                            self.viewPinCode.alpha = 0
                            
                        }, completion: { (finished: Bool) in
                            self.viewPinCode.isHidden = true
                            self.dismiss(animated: true, completion: {
                                DispatchQueue.main.async(execute: {
                                    UserDefaults.standard.set(token, forKey: "token")
                                    AppDelegate.returnAppDelegate().isFromSignUp = true
                                    AppDelegate.returnAppDelegate().showAnimation = false
                                    self.UpdateRootVC()
                                })
                                
                            })
                        }) 
                    })
                    
                    
                    
                    //                if dict["success"] as! Bool == true {
                    //                    self.txtPinCode.textColor = UIColor.greenColor()
                    //
                    //                    UIView.animateWithDuration(2.5, animations: {
                    //                        self.viewPinCode.alpha = 0
                    //
                    //                    }) { (finished: Bool) in
                    //                        self.viewPinCode.hidden = true
                    //                        self.dismissViewControllerAnimated(true, completion: {
                    //                            NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
                    //                            AppDelegate.returnAppDelegate().isFromSignUp = true
                    //                            AppDelegate.returnAppDelegate().showAnimation = false
                    //                            self.UpdateRootVC()
                    //                        })
                    //                    }
                    //
                    //                }
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
    
    func inquireProperty(_ token: String, propertyId: String) -> Void {
//        KVNProgress.show()
        let strURL = ("\(APIConstants.BasePath)/api/inquireproperty?token=\(token)&property_id=\(propertyId)")
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    _ = json as? NSDictionary
                    
                    DispatchQueue.main.async(execute: {
                        self.txtPinCode.textColor = UIColor.green
                        self.txtPinCode.resignFirstResponder()
                    })
                
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(2000 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                
                    UIView.animate(withDuration: 0.5, animations: {
                        self.viewPinCode.alpha = 0
                        
                    }, completion: { (finished: Bool) in
                        self.viewPinCode.isHidden = true
                        self.dismiss(animated: true, completion: {
                            UserDefaults.standard.set(token, forKey: "token")
                            AppDelegate.returnAppDelegate().isFromSignUp = true
                            AppDelegate.returnAppDelegate().showAnimation = false
                            self.UpdateRootVC()
                        })
                    }) 
                })
                
                
                
//                if dict["success"] as! Bool == true {
//                    self.txtPinCode.textColor = UIColor.greenColor()
//                
//                    UIView.animateWithDuration(2.5, animations: {
//                        self.viewPinCode.alpha = 0
//                        
//                    }) { (finished: Bool) in
//                        self.viewPinCode.hidden = true
//                        self.dismissViewControllerAnimated(true, completion: {
//                            NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
//                            AppDelegate.returnAppDelegate().isFromSignUp = true
//                            AppDelegate.returnAppDelegate().showAnimation = false
//                            self.UpdateRootVC()
//                        })
//                    }
//                    
//                }
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
    
    func likeProperty(_ token: String, propertyId: String) -> Void {
        let strURL = ("\(APIConstants.BasePath)/api/likeproperty?token=\(token)&property_id=\(propertyId)")
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let dict = json as? NSDictionary
                if dict!["success"] as! Bool == true {
                    
//                    if self.delegate != nil {
//                        self.delegate?.didSignedUpSuccessfully!()
//                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.txtPinCode.textColor = UIColor.green
                        self.txtPinCode.resignFirstResponder()
                    })
                    
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(2000 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                        
                        UIView.animate(withDuration: 0.5, animations: {
                            self.viewPinCode.alpha = 0
                            
                        }, completion: { (finished: Bool) in
                            self.viewPinCode.isHidden = true
                            self.dismiss(animated: true, completion: {
                                UserDefaults.standard.set(token, forKey: "token")
                                AppDelegate.returnAppDelegate().isFromSignUp = true
                                AppDelegate.returnAppDelegate().showAnimation = false
                                self.UpdateRootVC()
                                if self.delegate != nil {
                                    self.delegate?.didSignedUpSuccessfully!()
                                }
                            })
                        }) 
                        
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
    
    @IBAction func btnAccount_Tapped(_ sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "accountVC") as! AccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func btnCross_Tapped(_ sender: AnyObject) {
        
//        UIView.animateWithDuration(0.5, animations: { 
//            self.mainScrollCenterConstraint.constant = -600
//            self.view.layoutIfNeeded()
//        }) { (finished: Bool) in
//            self.dismissViewControllerAnimated(false, completion: { 
////                if self.delegate != nil {
////                    self.delegate?.didCacnelled!()
////                }
//            })
//
//        }
        
//        UIView.beginAnimations("bringDown", context:nil)
//        UIView.setAnimationDuration(0.5)
//        UIView.setAnimationBeginsFromCurrentState(true)
//        self.mainScrollCenterConstraint.constant = -600
//        self.view.layoutIfNeeded()
//        UIView.commitAnimations()
    }
}

extension SignUpViewController: AKMaskFieldDelegate {
    func maskFieldDidBeginEditing(_ maskField: AKMaskField) {
    }
    
    func maskField(_ maskField: AKMaskField, didChangedWithEvent event: AKMaskFieldEvent) {
        
        if maskField.tag == 0 {
            switch maskField.maskStatus {
            case .clear:
                self.btnSendPin.isEnabled = false
            case .incomplete:
                self.btnSendPin.isEnabled = false
            case .complete:
                self.btnSendPin.isEnabled = true
            }
        }
        else {
            
            switch maskField.maskStatus {
            case .clear:
                break
            case .incomplete:
                break
            case .complete:
                let params = ["token": DTSConstants.Constants.guestToken, "cid": self.plainPhoneNumber, "country_code": "", "code": self.txtPinCode.text!]
                UserDefaults.standard.set(self.plainPhoneNumber, forKey: "userCID")
                UserDefaults.standard.synchronize()
                self.registerUser(params as NSDictionary)
            }
        }
        
        
    }
    
    func maskField(_ maskField: AKMaskField, didChangeCharactersInRange range: NSRange, replacementString string: String, withEvent event: AKMaskFieldEvent) {
        if maskField.tag == 0 {
            switch maskField.maskStatus {
            case .clear:
                self.btnSendPin.isEnabled = false
            case .incomplete:
                self.btnSendPin.isEnabled = false
            case .complete:
                self.btnSendPin.isEnabled = true
            }
        }
        else {
            
            switch maskField.maskStatus {
            case .clear:
                break
            case .incomplete:
                break
            case .complete:
                let params = ["token": DTSConstants.Constants.guestToken, "cid": self.plainPhoneNumber, "country_code": "", "code": self.txtPinCode.text!]
                self.registerUser(params as NSDictionary)
            }
        }
    }
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

extension SignUpViewController {
    func getTOS() -> Void {
        
//        KVNProgress.show()
        var strURL = "\(APIConstants.BasePath)/api/tos?token=\(DTSConstants.Constants.guestToken)"
        
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/tos?token=\(token)")
        }
        
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        self.activityIndicator.isHidden = true
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let dictData = json as? NSDictionary
                    
                    let isSuccess = dictData!["success"] as! Bool
                    
                    if isSuccess == false {
                        
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: dictData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        
                        return
                    }
                    
                    if let html = dictData!["data"] as? String {
                        let htmlWithArial = "<font face='Arial' color='white'>\(html)</font>"
                        self.webView.loadHTMLString(htmlWithArial, baseURL: nil)
                    }
                    
                }
                catch {
                    
                }
            }
            else {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                    self.activityIndicator.isHidden = true
                })
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                
            }
        }.resume()
    }
}

extension NSMutableAttributedString {
    
    public func setLableTextAsLink(_ textToFind:String, linkURL:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            let urlLink = URL(string: linkURL)
            self.addAttribute(NSLinkAttributeName, value: urlLink!, range: foundRange)
            self.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: foundRange)
            return true
        }
        return false
    }
}

extension UIDevice {
    var iPhone: Bool {
        return UIDevice().userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhone4
        case iPhone5
        case iPhone6
        case iPhone6Plus
        case unknown
    }
    var screenType: ScreenType {
        guard iPhone else { return .unknown }
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4
        case 1136:
            return .iPhone5
        case 1334:
            return .iPhone6
        case 2208:
            return .iPhone6Plus
        default:
            return .unknown
        }
    }
}


//enum UIUserInterfaceIdiom : Int {
//    case unspecified
//    case phone // iPhone and iPod touch style UI
//    case pad // iPad style UI
//}

