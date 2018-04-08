//
//  UCLDetailsViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 14/07/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

class UCLDetailsViewController: BaseViewController {

    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var tblDetail: UITableView!
    var mainTitle: String!
    var strGuests: String!
    var strBeds: String!
    var strBaths: String!
    @IBOutlet weak var btnDelete: UIButton!
    var photoController: UCLPhotosViewController?
    var detailType: String!
    var monthRemaining: String!
    var rateMonthlyRent: String!
    var securityDeposit: String!
    var strSQFeet: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblDetail.dataSource = self
        self.tblDetail.delegate = self
        strGuests = "1"
        strBeds = "1"
        strBaths = "1"
        
        monthRemaining = "1"
        rateMonthlyRent = "0"
        securityDeposit = "0"
        
        if AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Relocating" || AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Ditching" {
            strGuests = "250"
        }
        
        strSQFeet = "250"
        
        let revealController = revealViewController()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func btnDelete_Tapped(_ sender: AnyObject) {
        
    }
    @IBAction func btnNext_Tapped(_ sender: AnyObject) {
        if detailType == "lease" {
            AppDelegate.returnAppDelegate().userProperty.setObject(monthRemaining, forKey: "monthRemaining" as NSCopying)
            AppDelegate.returnAppDelegate().userProperty.setObject(rateMonthlyRent, forKey: "price" as NSCopying)
            AppDelegate.returnAppDelegate().userProperty.setObject(securityDeposit, forKey: "securityDeposits" as NSCopying)
            
            if AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Ditching" {
                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "uclclassVC") as? UCLClassViewController
                controller!.listType = "class"
                controller?.hideBackButton = false
                controller?.hideSideButton = false
                self.navigationController?.pushViewController(controller!, animated: true)
            }
            else if AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Relocating" {
                //destinationVC
//                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "destinationVC") as? DestinationViewController
//                self.navigationController?.pushViewController(controller!, animated: true)
                
                let controller = UIStoryboard(name: "Ditch", bundle: nil).instantiateViewController(withIdentifier: "targetDestinationVC") as? TargetDestinationViewController
                self.navigationController?.pushViewController(controller!, animated: true)
            }
            
            
        }
        else {
            AppDelegate.returnAppDelegate().userProperty.setObject(strGuests, forKey: "guests" as NSCopying)
            AppDelegate.returnAppDelegate().userProperty.setObject(strSQFeet, forKey: "lotSize" as NSCopying)
            if AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Relocating" || AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Ditching" {
                AppDelegate.returnAppDelegate().userProperty.setObject(strGuests, forKey: "0" as NSCopying)
                AppDelegate.returnAppDelegate().userProperty.setObject(strGuests, forKey: "lotSize" as NSCopying)
            }
            
            AppDelegate.returnAppDelegate().userProperty.setObject(strBeds, forKey: "beds" as NSCopying)
            AppDelegate.returnAppDelegate().userProperty.setObject(strBaths, forKey: "baths" as NSCopying)
            
            if self.photoController == nil {
                self.photoController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "uclphotosVC") as? UCLPhotosViewController
            }
            
            self.navigationController?.pushViewController(self.photoController!, animated: true)
        }
        
        
    }
    @IBAction func btnLess_Tapped(_ sender: AnyObject) {
        let btn = sender as! UIButton
        let cell = self.tblDetail.cellForRow(at: IndexPath(row: btn.tag, section: 0)) as! UCLDetailTableViewCell
        if detailType == "lease" {
            if btn.tag == 1 {
                var guests = Int(monthRemaining)
                if guests! > 1 {
                    guests! = guests! - 1
                    cell.lblValude.text = String(guests!)
                    monthRemaining = cell.lblValude.text!
                }
            }
            else if btn.tag == 2 {
                var beds = Int(rateMonthlyRent)
                if beds! > 0 {
                    beds! = beds! - 250
                    cell.lblValude.text = String(beds!)
                    rateMonthlyRent = cell.lblValude.text!
                }
            }
            else {
                var baths = Int(securityDeposit)
                if baths! > 0 {
                    baths! = baths! - 250
                    cell.lblValude.text = String(baths!)
                    securityDeposit = cell.lblValude.text!
                }
            }
        }
        else {
            if btn.tag == 1 {
                var guests = Int(strGuests)
                if AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Relocating" || AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Ditching" {
                    if guests! > 250 {
                        guests! = guests! - 250
                        cell.lblValude.text = String(guests!)
                        strGuests = cell.lblValude.text!
                    }
                }
                else {
                    if guests! > 1 {
                        guests! = guests! - 1
                        cell.lblValude.text = String(guests!)
                        strGuests = cell.lblValude.text!
                    }
                }
                
            }
            else if btn.tag == 2 {
                var beds = Int(strBeds)
                if beds! > 1 {
                    beds! = beds! - 1
                    cell.lblValude.text = String(beds!)
                    strBeds = cell.lblValude.text!
                }
            }
            else if btn.tag == 3 {
                var baths = Int(strBaths)
                if baths! > 1 {
                    baths! = baths! - 1
                    cell.lblValude.text = String(baths!)
                    strBeds = cell.lblValude.text!
                }
            }
            else {
                var sqFeet = Int(strSQFeet)
                if sqFeet! > 250 {
                    sqFeet! = sqFeet! - 250
                    cell.lblValude.text = String(sqFeet!)
                    strSQFeet = cell.lblValude.text!
                }
            }
        }
    }

    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPlus_Tapped(_ sender: AnyObject) {
        let btn = sender as! UIButton
        let cell = self.tblDetail.cellForRow(at: IndexPath(row: btn.tag, section: 0)) as! UCLDetailTableViewCell
        
        if detailType == "lease" {
            if btn.tag == 1 {
                var guests = Int(monthRemaining)
                
                guests! = guests! + 1
                cell.lblValude.text = String(guests!)
                monthRemaining = cell.lblValude.text!
                
            }
            else if btn.tag == 2 {
                var beds = Int(rateMonthlyRent)
                
                beds! = beds! + 250
                cell.lblValude.text = String(beds!)
                rateMonthlyRent = cell.lblValude.text!
                
            }
            else {
                var baths = Int(securityDeposit)
                
                baths! = baths! + 250
                cell.lblValude.text = String(baths!)
                securityDeposit = cell.lblValude.text!
                
            }
        }
        else {
            if btn.tag == 1 {
                var guests = Int(strGuests)
                if AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Relocating" || AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Ditching" {
                    guests! = guests! + 250
                }
                else {
                    guests! = guests! + 1
                }
                cell.lblValude.text = String(guests!)
                strGuests = cell.lblValude.text!
                
            }
            else if btn.tag == 2 {
                var beds = Int(strBeds)
                
                beds! = beds! + 1
                cell.lblValude.text = String(beds!)
                strBeds = cell.lblValude.text!
                
            }
            else if btn.tag == 3 {
                var baths = Int(strBaths)
                
                baths! = baths! + 1
                cell.lblValude.text = String(baths!)
                strBaths = cell.lblValude.text!
                
            }
            else {
                var sqFeet = Int(strSQFeet)
                sqFeet! = sqFeet! + 250
                cell.lblValude.text = String(sqFeet!)
                strSQFeet = cell.lblValude.text!
            }

        }
        
    }


}

extension UCLDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Relocating" || AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Ditching" {
            return 4
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if detailType == "lease" {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! UCLCell
                cell.lblTitle.text = AppDelegate.returnAppDelegate().uclTitle
                cell.selectionStyle = .none
                return cell
            }
            else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! UCLDetailTableViewCell
                cell.lblCaption.text = "Months Remaining"
                cell.lblButtonLess.tag = indexPath.row
                cell.lblButtonPlus.tag = indexPath.row
                cell.lblButtonLess.addTarget(self, action: #selector(UCLDetailsViewController.btnLess_Tapped(_:)), for: .touchUpInside)
                cell.lblButtonPlus.addTarget(self, action: #selector(UCLDetailsViewController.btnPlus_Tapped(_:)), for: .touchUpInside)
                cell.lblValude.text = monthRemaining
                cell.viewInner.layer.cornerRadius = 4
                cell.viewInner.layer.borderWidth = 1
                cell.viewInner.layer.borderColor = UIColor(hexString: "e4e4e4").cgColor
                
                cell.viewInner.layer.masksToBounds = false
                cell.viewInner.layer.shadowOffset = CGSize(width: 0, height: 0.5)
                cell.viewInner.layer.shadowRadius = 0.5
                cell.viewInner.layer.shadowOpacity = 0.3
                
                cell.selectionStyle = .none
                return cell
            }
            else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! UCLDetailTableViewCell
                cell.lblCaption.text = "Rate (monthly rent)"
                cell.lblButtonLess.tag = indexPath.row
                cell.lblButtonPlus.tag = indexPath.row
                cell.lblButtonLess.addTarget(self, action: #selector(UCLDetailsViewController.btnLess_Tapped(_:)), for: .touchUpInside)
                cell.lblButtonPlus.addTarget(self, action: #selector(UCLDetailsViewController.btnPlus_Tapped(_:)), for: .touchUpInside)
                cell.lblValude.text = rateMonthlyRent
                cell.viewInner.layer.cornerRadius = 4
                cell.viewInner.layer.borderWidth = 1
                cell.viewInner.layer.borderColor = UIColor(hexString: "e4e4e4").cgColor
                
                cell.viewInner.layer.masksToBounds = false
                cell.viewInner.layer.shadowOffset = CGSize(width: 0, height: 0.5)
                cell.viewInner.layer.shadowRadius = 0.5
                cell.viewInner.layer.shadowOpacity = 0.3
                
                cell.selectionStyle = .none
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! UCLDetailTableViewCell
                cell.lblCaption.text = "Security Deposit"
                cell.lblButtonLess.tag = indexPath.row
                cell.lblButtonPlus.tag = indexPath.row
                cell.lblButtonLess.addTarget(self, action: #selector(UCLDetailsViewController.btnLess_Tapped(_:)), for: .touchUpInside)
                cell.lblButtonPlus.addTarget(self, action: #selector(UCLDetailsViewController.btnPlus_Tapped(_:)), for: .touchUpInside)
                cell.lblValude.text = securityDeposit
                cell.viewInner.layer.cornerRadius = 4
                cell.viewInner.layer.borderWidth = 1
                cell.viewInner.layer.borderColor = UIColor(hexString: "e4e4e4").cgColor
                
                cell.viewInner.layer.masksToBounds = false
                cell.viewInner.layer.shadowOffset = CGSize(width: 0, height: 0.5)
                cell.viewInner.layer.shadowRadius = 0.5
                cell.viewInner.layer.shadowOpacity = 0.3
                
                cell.selectionStyle = .none
                return cell
            }
        }
        else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! UCLCell
                cell.lblTitle.text = AppDelegate.returnAppDelegate().uclTitle
                if AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Relocating" || AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Ditching" {
                    cell.lblTitle.text = "My Space"
                }
                
                cell.lblTitle.text = "Details"
                
                cell.selectionStyle = .none
                return cell
            }
            else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! UCLDetailTableViewCell
                cell.lblCaption.text = "Max Guests"
                if AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Relocating" || AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Ditching" {
                    cell.lblCaption.text = "SQ Footage"
                }
                
                cell.lblButtonLess.tag = indexPath.row
                cell.lblButtonPlus.tag = indexPath.row
                cell.lblButtonLess.addTarget(self, action: #selector(UCLDetailsViewController.btnLess_Tapped(_:)), for: .touchUpInside)
                cell.lblButtonPlus.addTarget(self, action: #selector(UCLDetailsViewController.btnPlus_Tapped(_:)), for: .touchUpInside)
                cell.lblValude.text = strGuests
                cell.viewInner.layer.cornerRadius = 4
                cell.viewInner.layer.borderWidth = 1
                cell.viewInner.layer.borderColor = UIColor(hexString: "e4e4e4").cgColor
                
                cell.viewInner.layer.masksToBounds = false
                cell.viewInner.layer.shadowOffset = CGSize(width: 0, height: 0.5)
                cell.viewInner.layer.shadowRadius = 0.5
                cell.viewInner.layer.shadowOpacity = 0.3
                
                cell.selectionStyle = .none
                return cell
            }
            else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! UCLDetailTableViewCell
                cell.lblCaption.text = "Beds"
                cell.lblButtonLess.tag = indexPath.row
                cell.lblButtonPlus.tag = indexPath.row
                cell.lblButtonLess.addTarget(self, action: #selector(UCLDetailsViewController.btnLess_Tapped(_:)), for: .touchUpInside)
                cell.lblButtonPlus.addTarget(self, action: #selector(UCLDetailsViewController.btnPlus_Tapped(_:)), for: .touchUpInside)
                cell.lblValude.text = strBeds
                cell.viewInner.layer.cornerRadius = 4
                cell.viewInner.layer.borderWidth = 1
                cell.viewInner.layer.borderColor = UIColor(hexString: "e4e4e4").cgColor
                
                cell.viewInner.layer.masksToBounds = false
                cell.viewInner.layer.shadowOffset = CGSize(width: 0, height: 0.5)
                cell.viewInner.layer.shadowRadius = 0.5
                cell.viewInner.layer.shadowOpacity = 0.3
                
                cell.selectionStyle = .none
                return cell
            }
            else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! UCLDetailTableViewCell
                cell.lblCaption.text = "Baths"
                cell.lblButtonLess.tag = indexPath.row
                cell.lblButtonPlus.tag = indexPath.row
                cell.lblButtonLess.addTarget(self, action: #selector(UCLDetailsViewController.btnLess_Tapped(_:)), for: .touchUpInside)
                cell.lblButtonPlus.addTarget(self, action: #selector(UCLDetailsViewController.btnPlus_Tapped(_:)), for: .touchUpInside)
                cell.lblValude.text = strBaths
                cell.viewInner.layer.cornerRadius = 4
                cell.viewInner.layer.borderWidth = 1
                cell.viewInner.layer.borderColor = UIColor(hexString: "e4e4e4").cgColor
                
                cell.viewInner.layer.masksToBounds = false
                cell.viewInner.layer.shadowOffset = CGSize(width: 0, height: 0.5)
                cell.viewInner.layer.shadowRadius = 0.5
                cell.viewInner.layer.shadowOpacity = 0.3
                
                cell.selectionStyle = .none
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! UCLDetailTableViewCell
                cell.lblCaption.text = "SQ Footage"
                
                cell.lblButtonLess.tag = indexPath.row
                cell.lblButtonPlus.tag = indexPath.row
                cell.lblButtonLess.addTarget(self, action: #selector(UCLDetailsViewController.btnLess_Tapped(_:)), for: .touchUpInside)
                cell.lblButtonPlus.addTarget(self, action: #selector(UCLDetailsViewController.btnPlus_Tapped(_:)), for: .touchUpInside)
                cell.lblValude.text = strSQFeet
                cell.viewInner.layer.cornerRadius = 4
                cell.viewInner.layer.borderWidth = 1
                cell.viewInner.layer.borderColor = UIColor(hexString: "e4e4e4").cgColor
                
                cell.viewInner.layer.masksToBounds = false
                cell.viewInner.layer.shadowOffset = CGSize(width: 0, height: 0.5)
                cell.viewInner.layer.shadowRadius = 0.5
                cell.viewInner.layer.shadowOpacity = 0.3
                
                cell.selectionStyle = .none
                return cell
            }
        }
        
    }
}

extension UCLDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Relocating" || AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Ditching" {
                var titleCellHeight = (AppDelegate.returnAppDelegate().window?.frame.size.height)! - 425
                if UIScreen.main.nativeBounds.height == 2436 {
                    titleCellHeight = (AppDelegate.returnAppDelegate().window?.frame.size.height)! - 480
                }
                return titleCellHeight
            }
            else {
                var titleCellHeight = (AppDelegate.returnAppDelegate().window?.frame.size.height)! - 517
                if UIScreen.main.nativeBounds.height == 2436 {
                    titleCellHeight = (AppDelegate.returnAppDelegate().window?.frame.size.height)! - 572
                }
                return titleCellHeight
            }
        }
        return 80
    }
}



