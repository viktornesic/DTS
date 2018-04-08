//
//  BillsViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 18/01/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress

@objc protocol BillsViewControllerDelegate {
    
    @objc optional func didSelectBill(_ dictBill: NSDictionary)
    @objc optional func didBillCacnelled()
}

class BillsViewController: UIViewController {
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var tblBills: UITableView!
    @IBOutlet weak var lblHeaderTitle: UILabel!
    
    var bills: [AnyObject] = []
    
    var isFromLeases: Bool?
    var delegate: BillsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.tblBills.dataSource = self
        self.tblBills.delegate = self
        self.tblBills.isHidden = true
        self.lblMessage.isHidden = true
        
        self.lblMessage.text = "No Bills"
        
        if isFromLeases != nil {
            
            if self.bills.count > 0 {
                self.tblBills.isHidden = false
                self.lblMessage.isHidden = true
            }
            else {
                self.tblBills.isHidden = true
                self.lblMessage.isHidden = false
            }
        }
        else {
            
            self.getPendingBills()
        }
    
        
    }

    @IBAction func doneButtonTapped(_ sender: AnyObject) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        //self.navigationController?.popViewControllerAnimated(true)
    }
}

extension BillsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dictBill = bills[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "billCell1", for: indexPath) as! BillTableViewCell
        cell.lblTItle.text = dictBill["description"] as? String
        
        let amount = dictBill["amount"] as! String
        let amountArray = amount.components(separatedBy: ".")
        let truncatedAmount = "$\(amountArray.first!).00"
        
        cell.lblDescription.text = truncatedAmount//"$\(dictBill["amount"] as! String)"
        
        cell.lblStatus.text = (dictBill["status"] as! String).capitalized
        
        let createDateString = (dictBill["created_at"] as! String).components(separatedBy: " ").first
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        
        let createdDate = df.date(from: createDateString!)
        
        let df1 = DateFormatter()
        df1.dateFormat = "MMM dd yyyy"
        cell.lblDate.text = df1.string(from: createdDate!)
        
        //cell.lblDate.text = (dictBill["created_at"] as! String).componentsSeparatedByString(" ").first
        cell.selectionStyle = .none
        return cell
    }
}

extension BillsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectBillVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("selectBillVC") as! SelectBillAndAccountViewController
//        self.navigationController?.pushViewController(selectBillVC, animated: true)
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: true) {
                if self.delegate != nil {
                    let dictBill = self.bills[indexPath.row] as! NSDictionary
                    self.delegate?.didSelectBill!(dictBill)
                }
            }
        })
        
    }
}

extension BillsViewController {
    func getPendingBills() -> Void {
        
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getbill?token=\(token)&status=pending&paginated=0")
        }
        
        DispatchQueue.main.async(execute: {
            KVNProgress.show(withStatus: "Getting Pending Bills")
        })
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    let result = json
                    
                    let isSuccess = result["success"] as! Bool
                    
                    if isSuccess == false {
                        let _utils = Utils()
                        DispatchQueue.main.async(execute: {
                            _utils.showOKAlert("Error:", message: result["message"] as! String, controller: self, isActionRequired: false)
                            return
                        })
                        
                    }
                    
                    if let dictData = json["data"] as? NSDictionary {
                        self.bills = dictData["data"] as! [AnyObject]
                        DispatchQueue.main.async(execute: {
                            if self.bills.count > 0 {
                                self.tblBills.isHidden = false
                                self.lblMessage.isHidden = true
                            }
                            else {
                                self.tblBills.isHidden = true
                                self.lblMessage.isHidden = false
                            }
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
