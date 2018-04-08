//
//  SelectBillAndAccountViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 22/02/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress
import DLRadioButton

class SelectBillAndAccountViewController: UIViewController {

    @IBOutlet weak var constraintBillTableHeight: NSLayoutConstraint!
    @IBOutlet weak var lblBillsMessage: UILabel!
    @IBOutlet weak var btnSelectBill: UIButton!
    @IBOutlet weak var btnSelectPaymentMethod: UIButton!
    @IBOutlet weak var btnPayBill: UIButton!
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var tblPaymentMethods: UITableView!
    
    @IBOutlet weak var tblBills: UITableView!
    var selectedBill: NSDictionary?
    var selectedAccount: NSDictionary?
    var bills: [AnyObject] = []
    var accounts: [AnyObject] = []
    var selectedBillIndex = -1
    var selectAccountIndex = -1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let revealController = revealViewController()
        revealController?.panGestureRecognizer()
        revealController?.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        
        
        self.tblPaymentMethods.dataSource = self
        self.tblPaymentMethods.delegate = self
        self.tblBills.dataSource = self
        self.tblBills.delegate = self
        //self.view.hidden = true
        self.btnPayBill.isEnabled = false
        self.btnSelectBill.isHidden = true
        self.btnSelectPaymentMethod.isHidden = true
        self.tblBills.isHidden = true
        self.lblBillsMessage.isHidden = true
        KVNProgress.show(withStatus: "Getting Payment Methods")
        
        if UIDevice.current.screenType == .iPhone4 {
            self.constraintBillTableHeight.constant = 80;
        }
        
        
        self.getPaymentMethods()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func updatePaymentMethodButtoTapped(_ sender: AnyObject) {
        let paymentMethodVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "paymentMethodsVC") as! PaymentMethodsViewController
        paymentMethodVC.isFromSelectBill = true
        self.navigationController?.pushViewController(paymentMethodVC, animated: true)
    }
    

    
    @IBAction func submitButtonTapped(_ sender: AnyObject) {
//        if self.selectedBill == nil {
//            Utils.showOKAlertRO("", message: "Please select a bill.", controller: self)
//            return
//        }
//        
//        if self.selectedAccount == nil {
//            Utils.showOKAlertRO("", message: "Please select a payment method.", controller: self)
//            return
//        }
        self.selectedAccount = self.accounts[self.selectAccountIndex] as! NSDictionary
        self.payPendingBill(self.selectedAccount!)
    }
    
    @IBAction func radioButtonTapped(_ sender: AnyObject) {
        let btn = sender as! DLRadioButton
        
        if btn.isSelected == false {
            self.selectedBillIndex = -1
        }
        else {
            self.selectedBillIndex = btn.tag
        }
        
        self.tblBills.reloadData()
        
        if self.selectedBillIndex >= 0 && self.selectAccountIndex >= 0 {
            self.btnPayBill.isEnabled = true
        }
    }
    
    @IBAction func accountRadioButtonTapped(_ sender: AnyObject) {
        let btn = sender as! DLRadioButton
        
        if btn.isSelected == false {
            self.selectAccountIndex = -1
        }
        else {
            self.selectAccountIndex = btn.tag
        }
        
        self.tblPaymentMethods.reloadData()
        
        if self.selectedBillIndex >= 0 && self.selectAccountIndex >= 0 {
            self.btnPayBill.isEnabled = true
        }
    }
}

extension SelectBillAndAccountViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return bills.count
        }
        return accounts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            let dictBill = bills[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "billCell", for: indexPath) as! SelectBillTableViewCell
            let priceDouble = Double.init(dictBill["amount"] as! String)
            let priceNumber = NSNumber.init(value: priceDouble! as Double)
            let price = Utils.suffixNumber(priceNumber) as String//String(dictProperty["price"] as! Int)
            let amount = dictBill["amount"] as! String
            
            let amountArray = amount.components(separatedBy: ".")
            let truncatedAmount = "$\(amountArray.first!).00"
            
            let billingMonth = (dictBill["billing_month"] as! String).uppercased()
            
            cell.lblTitle.text = "RENT > \(billingMonth) > \(price)"
            
            let createdDate = (dictBill["created_at"] as! String).components(separatedBy: " ")[0]
            
            let rawDueDateString = dictBill["due_date"] as? String ?? createdDate
            
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd "
//            let df1 = NSDateFormatter()
//            df1.dateFormat = "MMM dd"
            let dueDate = df.date(from: rawDueDateString)
//            let dueDateString = df1.stringFromDate(dueDate!)
            
            let dueDateString = self.convertDateFormate(dueDate!)
            
            cell.lblDueDate.text = "Due \(dueDateString)"
            
            
            cell.btnRadio.tag = indexPath.row
            cell.btnRadio.addTarget(self, action: #selector(SelectBillAndAccountViewController.radioButtonTapped(_:)), for: .touchUpInside)
            cell.btnRadio.isSelected = false
            if indexPath.row == self.selectedBillIndex {
                cell.btnRadio.isSelected = true
            }
            cell.selectionStyle = .none
            return cell
        }
        else {
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
}

extension SelectBillAndAccountViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension SelectBillAndAccountViewController {
    
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
                        if let status = dictAccount["status"] as? String {
                            if status  == "verified" {
                                self.accounts.append(account)
                            }
                        }
                    }
                    
                    //self.accounts = (result!["data"] as! NSDictionary)["ach"] as! [AnyObject]
                    DispatchQueue.main.async(execute: {
                        self.getPendingBills()
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
    
    func getPendingBills() -> Void {
        
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getbill?token=\(token)&status=pending&paginated=0")
        }
        
        
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        self.btnSelectPaymentMethod.isHidden = false
                        self.btnSelectBill.isHidden = false
                        KVNProgress.dismiss()
                        
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let result = json as? NSDictionary
                    
                    let isSuccess = result!["success"] as! Bool
                    
                    if isSuccess == false {
                        let _utils = Utils()
                        DispatchQueue.main.async(execute: {
                            _utils.showOKAlert("Error:", message: result!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        })
                        
                    }
                    
                    if let dictData = result?["data"] as? NSDictionary {
                        self.bills = dictData["data"] as! [AnyObject]
                        DispatchQueue.main.async(execute: {
                            if self.bills.count > 0 {
                                self.tblBills.isHidden = false
                                self.lblBillsMessage.isHidden = true
                                
                            }
                            else {
                                self.tblBills.isHidden = true
                                self.lblBillsMessage.isHidden = false
                                
                            }
                            self.tblPaymentMethods.reloadData()
                            self.tblBills.reloadData()
                        
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
}

extension SelectBillAndAccountViewController {
        func payPendingBill(_ paymentMethod: NSDictionary) -> Void {
            KVNProgress.show(withStatus: "Paying Bill")
    
            var token = ""
            let strURL = "\(APIConstants.BasePath)/api/pay"
    
    
            if UserDefaults.standard.object(forKey: "token") != nil {
                token = UserDefaults.standard.object(forKey: "token") as! String
            }
    
            self.selectedBill = self.bills[self.selectedBillIndex] as! NSDictionary
    
            let strParams = "token=\(token)&lease_bill_id=\(self.selectedBill!["id"] as! Int)&type=ach&user_ach_id=\(paymentMethod["id"] as! Int)"
    
    
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
                            successVC.successMessage = "Your bill has been paid successfully."
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
                    })
                    Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                    
                }
                return()
            }.resume()
            
        }
    func convertDateFormate(_ date : Date) -> String{
        // Day
        let calendar = Calendar.current
        let anchorComponents = (calendar as NSCalendar).components([.day, .month, .year], from: date)
        
        // Formate
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "MMM"
        let newDate = dateFormate.string(from: date)
        
        var day  = "\(anchorComponents.day!)"
        switch (day) {
        case "1" , "21" , "31":
            day = day + "st"
        case "2" , "22":
            day = day + "nd"
        case "3" ,"23":
            day = day + "rd"
        default:
            day = day + "th"
        }
        return newDate + " " + day
    }
}
