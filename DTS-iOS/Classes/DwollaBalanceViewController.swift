//
//  DwollaBalanceViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 29/04/2017.
//  Copyright © 2017 Mac, Inc. All rights reserved.
//

import UIKit
import KVNProgress

class DwollaBalanceViewController: UIViewController {

    @IBOutlet weak var btnWithdraw: UIButton!
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var lblDwollaBalance: UILabel!
    
    var balanceString = "0"
    var dictACHBalance: [String: AnyObject]?
    var balance: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let revealController = revealViewController()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        //self.btnWithdraw.isEnabled = false
        self.lblDwollaBalance.text = "$0"
        getBalance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func withdrawButtonTapped(_ sender: Any) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dwDetinationAccountVC") as! DestinationAccountsViewController
//        controller.dictBalance = self.dictACHBalance!
        controller.balanceAmount = self.balanceString
        self.navigationController?.pushViewController(controller, animated: true)
        
    }

}

extension DwollaBalanceViewController {
    
    func getBalance() -> Void {
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getuserpayment?token=\(token)&source=dwolla&type=balance&include_balance=1")
        }
        
        DispatchQueue.main.async(execute: {
            KVNProgress.show(withStatus: "Loading Balance")
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
                    
                    
                    if let allAccounts = (result!["data"] as! NSDictionary)["ach"] as? [AnyObject] {
                        if allAccounts.count > 0 {
                            self.dictACHBalance = allAccounts[0] as? [String: AnyObject]
                            if let dictBalanceAmount = self.dictACHBalance!["balance"] as? [String: AnyObject] {
                                DispatchQueue.main.async(execute: {
                                    self.lblDwollaBalance.text = "$\(dictBalanceAmount["value"] as! String)"
                                    self.balanceString = "\(dictBalanceAmount["value"] as! String)"
                                })
                                if self.lblDwollaBalance.text != nil {
                                    self.balance = Double(dictBalanceAmount["value"] as! String)!
                                    if self.balance > 0 {
                                        self.btnWithdraw.isEnabled = true
                                    }
                                }
                                else {
                                    DispatchQueue.main.async(execute: {
                                        print("Value is null")
                                        self.lblDwollaBalance.text = "$0.00"
                                    })
                                }
                            }

                        }
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
    
}
