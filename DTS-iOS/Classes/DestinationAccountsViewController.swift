//
//  DestinationAccountsViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 29/04/2017.
//  Copyright © 2017 Mac, Inc. All rights reserved.
//

import UIKit
import DLRadioButton
import KVNProgress

class DestinationAccountsViewController: UIViewController {

    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var tblAccounts: UITableView!
    @IBOutlet weak var btnSideMenu: UIButton!
    
    var dictBalance: [String: AnyObject]!
    
    var selectedAccount: NSDictionary?
    var accounts: [AnyObject] = []
    var selectAccountIndex = -1
    var balanceAmount: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let revealController = revealViewController()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        self.btnContinue.isEnabled = false
        self.tblAccounts.dataSource = self
        self.tblAccounts.delegate = self
        
        self.tblAccounts.isHidden = true
        
        getPaymentMethods()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
        self.selectedAccount = self.accounts[self.selectAccountIndex] as? NSDictionary
        transferBalanceToAccount(self.selectedAccount!)
    }
    
    @IBAction func accountRadioButtonTapped(_ sender: AnyObject) {
        let btn = sender as! DLRadioButton
        
        if btn.isSelected == false {
            self.selectAccountIndex = -1
        }
        else {
            self.selectAccountIndex = btn.tag
        }
        
        self.tblAccounts.reloadData()
        
        if self.selectAccountIndex >= 0 {
            self.btnContinue.isEnabled = true
        }
    }

}

extension DestinationAccountsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return accounts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dictPaymentMethod = self.accounts[indexPath.row] as! [String: AnyObject]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! SelectAccountTableViewCell
        cell.lblTitle.text = "Bank Account ****\(dictPaymentMethod["account_number"] as! String) / \(dictPaymentMethod["name"] as! String)"
        cell.btnRadio.tag = indexPath.row
        cell.btnRadio.addTarget(self, action: #selector(SelectBillAndAccountViewController.accountRadioButtonTapped(_:)), for: .touchUpInside)
        cell.btnRadio.isSelected = false
        if indexPath.row == self.selectAccountIndex {
            cell.btnRadio.isSelected = true
        }
        cell.selectionStyle = .none
        return cell
    }
}

extension DestinationAccountsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension DestinationAccountsViewController {
    
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
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: result!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        
                        return
                    }
                    
                    
                    let allAccounts = (result!["data"] as! NSDictionary)["ach"] as! [AnyObject]
                    
                    for account in allAccounts {
                        let dictAccount = account as! [String: AnyObject]
                        if dictAccount["status"] as? String ?? "" == "verified" {
                            self.accounts.append(account)
                        }
                    }
                    
                    DispatchQueue.main.async(execute: {
                        if self.accounts.count > 0 {
                            self.tblAccounts.isHidden = false
                            self.tblAccounts.reloadData()
                        }
                    })
                    
                   
                    
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
    
}

extension DestinationAccountsViewController {
    func transferBalanceToAccount(_ paymentMethod: NSDictionary) -> Void {
        KVNProgress.show(withStatus: "Transferring Balance")
        
        var token = ""
        let strURL = "\(APIConstants.BasePath)/api/createtransfer"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
        }
        
        
        let strParams = "token=\(token)&destination_user_ach_id=\(paymentMethod["id"] as! Int)&from_balance=1&amount=\(self.balanceAmount!)"
        
        
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
                        successVC.successMessage = "Your transfer has been successful."
                        self.navigationController?.pushViewController(successVC, animated: true)
                    })
                    
                    //                        let _utils = Utils()
                    //                        _utils.showOKAlert("", message: "Your bill has been paid successfully.", controller: self, isActionRequired: false)
                    
                    
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
            return()
            }.resume()
        
    }
}
