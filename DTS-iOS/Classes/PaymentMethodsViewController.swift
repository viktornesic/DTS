//
//  PaymentMethodsViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 16/01/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress

class PaymentMethodsViewController: UIViewController {

    @IBOutlet weak var viewAcocount: UIView!
    @IBOutlet weak var lblNavigationTitel: UILabel!
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblPaymentMessage: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var btnUpdateMyData: UIButton!
    @IBOutlet weak var btnAddACH: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var tblLeases: FZAccordionTableView!
    @IBOutlet weak var viewPayment: UIView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtType: UITextField!
    @IBOutlet weak var txtRouteNumber: UITextField!
    @IBOutlet weak var txtAccountNumber: UITextField!
    @IBOutlet weak var contraintHeightAddAccountView: NSLayoutConstraint!
    @IBOutlet weak var tblPaymentMethods: UITableView!
    @IBOutlet weak var btnSideMenu: UIButton!
    
    @IBOutlet weak var btnBalance: UIButton!
    @IBOutlet weak var segment: UISegmentedControl!
    var paymentMethods: [AnyObject] = []
    @IBOutlet weak var viewLeases: UIView!
    
    var customPicker: CustomPickerView?
    var confirmVerificationIndex = -1
    var leases: [AnyObject] = []
    var selectedSegIndex: Int?
    var payBill: Bool?
    var bill: NSDictionary?
    var dictUserGeneral: NSDictionary?
    var isFromSelectBill: Bool?
    var bills: [AnyObject] = []
    var isFromBooking: Bool?
    var depositVerified = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblMessage.textColor = UIColor.white
        self.contraintHeightAddAccountView.constant = 0
        
        let revealController = revealViewController()
        revealController?.panGestureRecognizer().isEnabled = false
        revealController?.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
//        self.view.backgroundColor = UIColor(hexString: "191919")
        
        self.addDoneButtonOnKeyboard(self.txtAccountNumber)
        self.addDoneButtonOnKeyboard(self.txtRouteNumber)
        
        self.tblPaymentMethods.dataSource = self
        self.tblPaymentMethods.delegate = self
        
        self.tblLeases.dataSource = self
        self.tblLeases.delegate = self
        self.tblLeases.allowMultipleSectionsOpen = false
        
        self.tblLeases.isHidden = true
        self.lblMessage.isHidden = true
        
        tblLeases.register(UINib(nibName: "LeaseView", bundle: nil), forHeaderFooterViewReuseIdentifier: AccordionHeaderView.kAccordionHeaderViewReuseIdentifier)
        
        self.recursiveFormatViews(forMainView: self.viewAcocount)
        
        
    }
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func balanceButtonTapped(_ sender: Any) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dwBalanceVC") as! DwollaBalanceViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.btnBack.isHidden = true
        self.ivLogo.isHidden = false
        
        //self.btnBalance.isHidden = true
        
        if self.selectedSegIndex == nil {
//            self.view.backgroundColor = UIColor(hexString: "191919")
            if self.isFromSelectBill != nil {
                self.ivLogo.isHidden = true
                self.btnBack.isHidden = false
            }
            self.lblPaymentMessage.isHidden = true
            self.tblPaymentMethods.isHidden = true
            if payBill != nil {
                self.contraintHeightAddAccountView.constant = 0
                self.btnAddACH.isHidden = true
            }
            
            self.segment.selectedSegmentIndex = 1
            self.viewLeases.isHidden = true
            self.viewPayment.isHidden = false
            self.getUserGeneralInfo()
        }
        else {
            
            //self.getPaymentMethods()
            //self.view.backgroundColor = UIColor(hexString: "191919")
            self.lblNavigationTitel.text = "My Leases";
            self.segment.selectedSegmentIndex = self.selectedSegIndex!
            self.viewLeases.isHidden = false
            self.viewPayment.isHidden = true
            self.getLeases()
        }
    }
    
    @IBAction func addAccountButtonTapped(_ sender: AnyObject) {
        contraintHeightAddAccountView.constant = 207
    }
    
    @IBAction func updateMyDataButtonTapped(_ sender: AnyObject) {
        let fnViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FNViewController") as! FNViewController
        fnViewController.dictUserGeneralReadInfo = self.dictUserGeneral
        self.navigationController?.pushViewController(fnViewController, animated: true)
//        self.getUserGeneralInfo()
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        contraintHeightAddAccountView.constant = 0
    }
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        if Utils.isTextFieldEmpty(self.txtAccountNumber) == true {
            Utils.showOKAlertRO("", message: "Account number is required.", controller: self)
            return
        }
        
        if Utils.isTextFieldEmpty(self.txtRouteNumber) == true {
            Utils.showOKAlertRO("", message: "Route number is required.", controller: self)
            return
        }
        
        if Utils.isTextFieldEmpty(self.txtName) == true {
            Utils.showOKAlertRO("", message: "Name is required.", controller: self)
            return
        }
        
        
        self.saveACHPaymentMethod()
    }
    @IBAction func verifyAccountButtonTapped(_ sender: AnyObject) {
        let btn = sender as! UIButton
        let dictPaymentMethod = self.paymentMethods[btn.tag] as! [String: AnyObject]
        let strId = String(dictPaymentMethod["id"] as! Int)
        self.initiateVerification(strId)
    }

    @IBAction func verifyDepositsButtonTapped(_ sender: AnyObject) {
        confirmVerificationIndex = (sender as! UIButton).tag
        self.tblPaymentMethods.reloadData()
    }
    
    @IBAction func confirmVerifyDepositsButtonTapped(_ sender: AnyObject) {
        let btn = sender as! UIButton
        let dictPaymentMethod = self.paymentMethods[btn.tag] as! [String: AnyObject]
        let strId = String(dictPaymentMethod["id"] as! Int)
        let selIndexPath = IndexPath(row: (sender as! UIButton).tag, section: 0)
        let cell = self.tblPaymentMethods.cellForRow(at: selIndexPath) as! PaymentMethodTableViewCell
        if Utils.isTextFieldEmpty(cell.txtAmount1) == true {
            Utils.showOKAlertRO("", message: "Amount 1 is required.", controller: self)
            return
        }
        
        if Utils.isTextFieldEmpty(cell.txtAmount2) == true {
            Utils.showOKAlertRO("", message: "Amount 2 is required.", controller: self)
            return
        }
        
        self.verifyDeposits(strId, amount1: cell.txtAmount1.text!, amount2: cell.txtAmount2.text!)

    }

    
    @IBAction func toggle(_ sender: AnyObject) {
        self.viewLeases.isHidden = true
        self.viewPayment.isHidden = true
        
        switch (sender as! UISegmentedControl).selectedSegmentIndex {
        case 0:
            self.viewLeases.isHidden = false
            self.getLeases()
            break
        case 1:
            self.viewPayment.isHidden = false
            self.getPaymentMethods()
            break
        default:
            break
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func addNextButtonOnKeyboard(_ view: UIView?)
    {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(btnNextTapped(_:)))
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
    
    func btnNextTapped(_ sender: AnyObject) {
        //self.txtViewDescription.becomeFirstResponder()
    }
}

extension PaymentMethodsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 0 {
            return 1
        }
        else {
            return leases.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return paymentMethods.count
        }
        else {
            let lease = self.leases[section] as! NSDictionary
            return ((lease["bills"] as AnyObject).count)!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 0 {
            return 0
        }
        return LeaseView.kDefaultAccordionHeaderViewHeight;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 0 {
            return nil
        }
        let dictLease = self.leases[section] as! NSDictionary
        let dictProperty = dictLease["property_fields"] as! NSDictionary
        let accordionHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LeaseView.kAccordionHeaderViewReuseIdentifier)
        if let lblTitle = accordionHeaderView?.viewWithTag(10) as? UILabel {
            lblTitle.text = dictProperty["name"] as? String
        }
        if let lblAddress = accordionHeaderView?.viewWithTag(11) as? UILabel {
            lblAddress.text = dictProperty["address"] as? String
        }
        return accordionHeaderView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 {
            let dictPaymentMethod = self.paymentMethods[indexPath.row] as! [String: AnyObject]
            let isVerified = dictPaymentMethod["status"] as? String ?? ""
            let verificationInitiated = dictPaymentMethod["verification_initiated"] as! Bool
            if verificationInitiated {
                if indexPath.row == confirmVerificationIndex {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "confirmVerifyDepositCell", for: indexPath) as! PaymentMethodTableViewCell
                    cell.lblBankAccount.text = "******\(dictPaymentMethod["account_number"] as! String)"
                    cell.lblRoute.text = "******\(dictPaymentMethod["routing_number"] as! String)"
                    cell.lblName.text = dictPaymentMethod["name"] as? String
                    cell.btnConfirmVerifyDeposit.tag = indexPath.row
                    
                    cell.txtAmount1.text = ""
                    cell.txtAmount1.layer.cornerRadius = 4
                    cell.txtAmount1.layer.borderColor = UIColor(hexString: "d2d2d2").cgColor
                    cell.txtAmount1.layer.borderWidth = 1
                    cell.txtAmount1.keyboardType = .decimalPad
                    self.addDoneButtonOnKeyboard(cell.txtAmount1)
                    
                    cell.txtAmount2.text = ""
                    cell.txtAmount2.layer.cornerRadius = 4
                    cell.txtAmount2.layer.borderColor = UIColor(hexString: "d2d2d2").cgColor
                    cell.txtAmount2.layer.borderWidth = 1
                    cell.txtAmount2.keyboardType = .decimalPad
                    self.addDoneButtonOnKeyboard(cell.txtAmount2)
                    
                    cell.btnConfirmVerifyDeposit.addTarget(self, action: #selector(PaymentMethodsViewController.confirmVerifyDepositsButtonTapped(_:)), for: .touchUpInside)
                    self.recursiveFormatViews(forMainView: cell.contentView)
                    cell.selectionStyle = .none
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "verifyDepositCell", for: indexPath) as! PaymentMethodTableViewCell
                    cell.lblBankAccount.text = "******\(dictPaymentMethod["account_number"] as! String)"
                    cell.lblRoute.text = "******\(dictPaymentMethod["routing_number"] as! String)"
                    cell.lblName.text = dictPaymentMethod["name"] as? String
                    cell.btnVerifyDeposits.tag = indexPath.row
                    cell.btnVerifyDeposits.addTarget(self, action: #selector(PaymentMethodsViewController.verifyDepositsButtonTapped(_:)), for: .touchUpInside)
                    cell.selectionStyle = .none
                    return cell
                }
                
            }
            else {
                if isVerified == "verified" {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "verifiedMethodCell", for: indexPath) as! PaymentMethodTableViewCell
                    cell.lblBankAccount.text = "******\(dictPaymentMethod["account_number"] as! String)"
                    cell.lblRoute.text = "******\(dictPaymentMethod["routing_number"] as! String)"
                    cell.lblName.text = dictPaymentMethod["name"] as? String
                    cell.selectionStyle = .none
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "unverifiedMethodCell", for: indexPath) as! PaymentMethodTableViewCell
                    cell.lblBankAccount.text = "******\(dictPaymentMethod["account_number"] as! String)"
                    cell.lblRoute.text = "******\(dictPaymentMethod["routing_number"] as! String)"
                    cell.lblName.text = dictPaymentMethod["name"] as? String
                    cell.btnRequestInfo.tag = indexPath.row
                    cell.btnRequestInfo.addTarget(self, action: #selector(PaymentMethodsViewController.verifyAccountButtonTapped(_:)), for: .touchUpInside)
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "billCell1", for: indexPath) as! BillTableViewCell
            
            let dictLease = self.leases[indexPath.section] as! NSDictionary
            let bills = dictLease["bills"] as! NSArray
            let dictBill = bills[indexPath.row] as! NSDictionary
            
            cell.lblTItle.text = dictBill["description"] as? String
            
            let amount = dictBill["amount"] as! String
            let amountArray = amount.components(separatedBy: ".")
            let truncatedAmount = "$\(amountArray.first!).00"
            
            cell.lblDescription.text = truncatedAmount//"$\(dictBill["amount"] as! String)"
            
            
            cell.lblStatus.textColor = UIColor.red//UIColor(hexString: "155e72")
            if (dictBill["status"] as? String ?? "").lowercased() == "processed" {
                cell.lblStatus.textColor = UIColor.green;
                
            }
            
            
            let createDateString = (dictBill["created_at"] as! String).components(separatedBy: " ").first
            
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            
            let createdDate = df.date(from: createDateString!)
            
            let df1 = DateFormatter()
            df1.dateFormat = "MMM dd yyyy"
            cell.lblDate.text = df1.string(from: createdDate!)
            
            cell.lblStatus.text = "\((dictBill["status"] as! String).capitalized) : \(cell.lblDate.text!)"
            
            //cell.lblDate.text = (dictBill["created_at"] as! String).componentsSeparatedByString(" ").first
            cell.selectionStyle = .none
            return cell


        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView.tag == 0 {
            self.tblLeases.beginUpdates()
            if editingStyle == .delete {
                
                let dictPaymentMethod = self.paymentMethods[indexPath.row] as! [String: AnyObject]
                self.paymentMethods.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                if UserDefaults.standard.object(forKey: "token") != nil {
                    let token = UserDefaults.standard.object(forKey: "token") as! String
                    self.deletePaymentMethod(token, methodId: String(dictPaymentMethod["id"] as! Int))
                }
                
            }
            self.tblPaymentMethods.endUpdates()
        }
        
    }
}

extension PaymentMethodsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 1 {
            return 108
        }
        let dictPaymentMethod = self.paymentMethods[indexPath.row] as! [String: AnyObject]
        let isVerified = dictPaymentMethod["status"] as? String ?? ""
        if isVerified == "verified" {
            return 145
        }
        return 195
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1 {
//            let dictLease = self.leases[indexPath.row] as! NSDictionary
//            let billController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("billsVC") as! BillsViewController
//            billController.isFromLeases = true
//            billController.bills = dictLease["bills"] as! [AnyObject]
//            self.navigationController?.pushViewController(billController, animated: true)
        }
        else {
            if payBill != nil {
                self.payPendingBill(self.paymentMethods[indexPath.row] as! NSDictionary)
            }
        }
    }
}

extension PaymentMethodsViewController {
    
    func verifyDeposits(_ id: String, amount1: String, amount2: String) -> Void {
        KVNProgress.show(withStatus: "Verifying Deposit")
        
        var token = ""
        let strURL = "\(APIConstants.BasePath)/api/saveuserpaymentaction"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
        }
        
        
        let strParams = "token=\(token)&action=verify&type=ach&id=\(id)&amount1=\(amount1)&amount2=\(amount2)"
        
        
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
                    
        
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let tempData = json as? NSDictionary
                    
                    let isSuccess = tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        })
                        
                    }
                    if self.isFromBooking != nil {
                        self.depositVerified = true
                        self.getPaymentMethods()
                        
                    }
                    else {
                        self.getPaymentMethods()
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
    
    func initiateVerification(_ id: String) -> Void {
        KVNProgress.show(withStatus: "Verifying Payment Method")
        
        var token = ""
        let strURL = "\(APIConstants.BasePath)/api/saveuserpaymentaction"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
        }
        
        
        let strParams = "token=\(token)&action=initiate_verification&type=ach&id=\(id)"
        
        
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
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let tempData = json as? NSDictionary
                    
                    let isSuccess = tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        })
                        
                    }
                    
                    self.getPaymentMethods()
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
    
    func saveACHPaymentMethod() -> Void {
        KVNProgress.show(withStatus: "Saving Account")
        
        var token = ""
        let strURL = "\(APIConstants.BasePath)/api/saveuserpayment"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
        }
        
        
        let strParams = "token=\(token)&type=ach&name=\(self.txtName.text!)&account_number=\(self.txtAccountNumber.text!)&routing_number=\(self.txtRouteNumber.text!)&account_type=\(self.txtType.text!)"
        
        
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
                       
                        let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                        let tempData = json as? NSDictionary
                        
                        let isSuccess = tempData!["success"] as! Bool
                        
                        if isSuccess == false {
                            DispatchQueue.main.async(execute: {
                                KVNProgress.dismiss()
                                let _utils = Utils()
                                _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                                return
                            })
                            
                        }
                        else {
                            DispatchQueue.main.async(execute: {
                                self.contraintHeightAddAccountView.constant = 0
                            })
                        }
                
                        self.getPaymentMethods()
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
}

extension PaymentMethodsViewController {
    
    func getUserGeneralInfo() -> Void {
        
        KVNProgress.show(withStatus: "Getting User General Info")
        
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getusergeneral?token=\(token)&source=dwolla")
        }
        
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
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
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        })
                        
                    }
                    
                    self.dictUserGeneral = tempData!["data"] as? NSDictionary
                    
                    DispatchQueue.main.async(execute: {
                        self.populateFields(self.dictUserGeneral!)
                    })
                    
    
                    self.getPaymentMethods()
                    
        
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
    
    func getPaymentMethods() -> Void {
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getuserpayment?token=\(token)")
        }
        
        DispatchQueue.main.async(execute: {
            KVNProgress.show(withStatus: "Loading Payment Methods")
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
                            return
                        })
                        
                    }
                    
                    self.confirmVerificationIndex = -1
                    self.paymentMethods = (result!["data"] as! NSDictionary)["ach"] as! [AnyObject]
                    
                    AppDelegate.returnAppDelegate().paymentMethods = []
                    
                    for dictPaymentMethod in self.paymentMethods {
                        if dictPaymentMethod["status"] as? String ?? "" == "verified" {
                            AppDelegate.returnAppDelegate().paymentMethods.append(dictPaymentMethod)
                        }
                    }
                    
                    if self.depositVerified == false {
                        DispatchQueue.main.async(execute: {
                            if self.paymentMethods.count > 0 {
                                self.lblPaymentMessage.isHidden = true
                                self.tblPaymentMethods.isHidden = false
                            }
                            else {
                                self.lblPaymentMessage.isHidden = false
                                self.tblPaymentMethods.isHidden = true
                            }
                            self.tblPaymentMethods.reloadData()
                        })
                    }
                    else {
                        
                        if self.isFromBooking != nil {
                            if self.isFromBooking! == true {
                                DispatchQueue.main.async(execute: {
                                    KVNProgress.dismiss()
                                    if let bookingController = self.navigationController?.viewControllers[1] {
                                        self.navigationController?.popToViewController(bookingController, animated: true)
                                    }
                                })
                            }
                            else {
                                DispatchQueue.main.async(execute: {
                                    if self.paymentMethods.count > 0 {
                                        self.lblPaymentMessage.isHidden = true
                                        self.tblPaymentMethods.isHidden = false
                                    }
                                    else {
                                        self.lblPaymentMessage.isHidden = false
                                        self.tblPaymentMethods.isHidden = true
                                    }
                                    self.tblPaymentMethods.reloadData()
                                })
                            }
                        }
                        else {
                            DispatchQueue.main.async(execute: {
                                if self.paymentMethods.count > 0 {
                                    self.lblPaymentMessage.isHidden = true
                                    self.tblPaymentMethods.isHidden = false
                                }
                                else {
                                    self.lblPaymentMessage.isHidden = false
                                    self.tblPaymentMethods.isHidden = true
                                }
                                self.tblPaymentMethods.reloadData()
                            })
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
    
    func getPaymentMethodsCondtion() -> Void {
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
                            return
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

extension PaymentMethodsViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 2 {
            self.txtAccountNumber.resignFirstResponder()
            self.txtName.resignFirstResponder()
            self.txtType.resignFirstResponder()
            self.txtRouteNumber.resignFirstResponder()
            let indexPath = IndexPath(row: 0, section: 0)
            self.showPicker([["title": "Checking"], ["title": "Savings"]], indexPath: indexPath, andKey: "title")
            
            return false
            
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension PaymentMethodsViewController: CustomPickerDelegate {
    func didCancelTapped() {
        self.hideCustomPicker()
    }
    
    func didDateSelected(_ date: Date, withIndexPath indexPath: IndexPath) {
        
    }
    
    func didDurationSelected(_ duration: String, withIndexPath indexPath: IndexPath) {
        
    }
    
    func didItemSelected(_ optionIndex: NSInteger, andSeletedText selectedText: String, withIndexPath indexPath: IndexPath, andSelectedObject selectedObject: NSDictionary) {
        self.hideCustomPicker()
        self.txtType.text = selectedText
    }
}

extension PaymentMethodsViewController {
    func getLeases() -> Void {
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getlease?token=\(token)&status=&paginated=0")
        }
        
        DispatchQueue.main.async(execute: {
            KVNProgress.show(withStatus: "")
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
                            return
                        })
                    }
                    
                    if let dictData = result?["data"] as? NSDictionary {
                        self.leases = dictData["data"] as! [AnyObject]
                        DispatchQueue.main.async(execute: {
                            if self.leases.count > 0 {
                                self.tblLeases.isHidden = false
                                self.lblMessage.isHidden = true
                            }
                            else {
                                self.tblLeases.isHidden = true
                                self.lblMessage.isHidden = false
                            }
                            self.tblLeases.reloadData()
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
    
    func payPendingBill(_ paymentMethod: NSDictionary) -> Void {
        KVNProgress.show(withStatus: "Paying Bill")
        
        var token = ""
        let strURL = "\(APIConstants.BasePath)/api/pay"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
        }
        
        
        let strParams = "token=\(token)&lease_bill_id=\(self.bill!["id"] as! Int)&type=ach&user_ach_id=\(paymentMethod["id"] as! Int)"
        
        
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
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        })
                        
                    }
                    
                    DispatchQueue.main.async(execute: {
                        let _utils = Utils()
                        _utils.showOKAlert("", message: "Your bill has been paid successfully.", controller: self, isActionRequired: false)
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

extension PaymentMethodsViewController {
    func populateFields(_ dictUserInfo: NSDictionary) -> Void {
        self.lblFirstName.text = dictUserInfo["first_name"] as? String
        self.lblLastName.text = dictUserInfo["last_name"] as? String
        self.lblEmail.text = dictUserInfo["email"] as? String
        self.lblAddress.text = dictUserInfo["address1"] as? String
    }
    
    func deletePaymentMethod(_ token: String, methodId: String) -> Void {
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/deleteuserpayment?token=\(token)&id=\(methodId)&type=ach")
        }
        
        
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
                    
                    if self.paymentMethods.count == 0 {
                        AppDelegate.returnAppDelegate().paymentMethods = []
                    }
//                    if isSuccess == false {
//                        dispatch_async(dispatch_get_main_queue(), {
//                            KVNProgress.show()
//                            let _utils = Utils()
//                            _utils.showOKAlert("Error:", message: result!["message"] as! String, controller: self, isActionRequired: false)
//                            return
//                        })
//                        
//                    }
                    
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

extension PaymentMethodsViewController {
    func recursiveFormatViews(forMainView mainView: UIView) {
        for view in mainView.subviews {
            if view is UITextField {
                if (view as! UITextField).placeholder != nil {
                    (view as! UITextField).attributedPlaceholder = NSAttributedString(string:(view as! UITextField).placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.white])
                }
                
                //0275f3
                (view as! UITextField).textColor = UIColor(hexString: "0275f3")
            }
        }
    }
}

// MARK: - <FZAccordionTableViewDelegate> -

extension PaymentMethodsViewController : FZAccordionTableViewDelegate {
    
    func tableView(_ tableView: FZAccordionTableView, willOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        
    }
    
    func tableView(_ tableView: FZAccordionTableView, didOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        
    }
    
    func tableView(_ tableView: FZAccordionTableView, willCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        
    }
    
    func tableView(_ tableView: FZAccordionTableView, didCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        
    }
    
    func tableView(_ tableView: FZAccordionTableView, canInteractWithHeaderAtSection section: Int) -> Bool {
        return true
    }
}

