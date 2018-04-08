//
//  AccountsViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 22/02/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress

@objc protocol AccountsViewControllerDelegate {
    
    @objc optional func didSelectedAccount(_ dictAccount: NSDictionary)
    @objc optional func didCacnelled()
}

class AccountsViewController: UIViewController {

    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var tblAccounts: UITableView!
    @IBOutlet weak var btnSideMenu: UIButton!
    var accounts: [AnyObject] = []
    
    var delegate: AccountsViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        
        self.tblAccounts.dataSource = self
        self.tblAccounts.delegate = self
        
        self.lblMessage.isHidden = true
        
        
        self.getPaymentMethods()
    }

    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true) { 
            
        }
    }
    
}

extension AccountsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dictPaymentMethod = self.accounts[indexPath.row] as! [String: AnyObject]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AccountTableViewCell
        cell.lblBankAccount.text = "******\(dictPaymentMethod["account_number"] as! String)"
        cell.lblAccountName.text = dictPaymentMethod["name"] as? String
        cell.selectionStyle = .none
        return cell
    }
}

extension AccountsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: true) {
                if self.delegate != nil {
                    self.delegate?.didSelectedAccount!(self.accounts[indexPath.row] as! NSDictionary)
                }
            }
        })
        
        //self.payPendingBill(self.accounts[indexPath.row] as! NSDictionary)
    }
}

extension AccountsViewController {
    func getPaymentMethods() -> Void {
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getuserpayment?token=\(token)")
        }
        
        DispatchQueue.main.async(execute: {
            KVNProgress.show(withStatus: "Getting Payment Methods")
        })
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let result = json as? NSDictionary
                    
                    let isSuccess = result!["success"] as! Bool
                    
                    if isSuccess == false {
                        DispatchQueue.main.async(execute: {
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: result!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        return
                    }
                    
        
                    let tmpResult = result!["data"] as! NSDictionary
                    self.accounts = tmpResult["ach"] as! [AnyObject]
                    DispatchQueue.main.async(execute: {
                        self.tblAccounts.reloadData()
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
    
}

//extension AccountsViewController {
//    func payPendingBill(paymentMethod: NSDictionary) -> Void {
//        KVNProgress.show()
//        
//        var token = ""
//        let strURL = "\(APIConstants.BasePath)/api/pay"
//        
//        
//        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
//            token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
//        }
//        
//        
//        let strParams = "token=\(token)&lease_bill_id=\(self.bill!["id"] as! Int)&type=ach&user_ach_id=\(paymentMethod["id"] as! Int)"
//        
//        
//        let paramData = strParams.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!
//        
//        let url = NSURL(string: strURL)
//        var request = URLRequest(url: url!)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.HTTPMethod = "POST"
//        request.HTTPBody = paramData
//        
//        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
//            if error == nil {
//                do {
//                    
//                    dispatch_async(dispatch_get_main_queue(), {
//                        KVNProgress.show()
//                    })
//                    
//                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
//                    let tempData = json as? NSDictionary
//                    
//                    let isSuccess = tempData!["success"] as! Bool
//                    
//                    if isSuccess == false {
//                        dispatch_async(dispatch_get_main_queue(), {
//                            KVNProgress.show()
//                        })
//                        let _utils = Utils()
//                        _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
//                        return
//                    }
//                    
//                    let _utils = Utils()
//                    _utils.showOKAlert("", message: "Your bill has been paid successfully.", controller: self, isActionRequired: false)
//                    
//                    
//                }
//                catch {
//                    
//                }
//                
//                
//            }
//            else {
//                dispatch_async(dispatch_get_main_queue(), {
//                    KVNProgress.show()
//                })
//                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
//                
//            }
//        }
//        dataTask.resume()
//        
//    }
//}
