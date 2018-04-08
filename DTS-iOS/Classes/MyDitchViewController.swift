//
//  MyDitchViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 29/11/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress
import SDWebImage

class MyDitchViewController: UIViewController {
    @IBOutlet weak var tblPendingProperties: UITableView!
    @IBOutlet weak var lblPendingMessage: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var tblProperties: FZAccordionTableView!
    var properties = NSMutableArray()
    var pendingProperties = NSMutableArray()
    var dictDocTemplate: [String: AnyObject]?
    var dictLead: [String: AnyObject]?
    var selectedSection: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AppDelegate.returnAppDelegate().isNewProperty = nil
        
        let revealController = revealViewController()
        //            revealController?.panGestureRecognizer()
        revealController?.panGestureRecognizer().isEnabled = false
        revealController?.tapGestureRecognizer()
        
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        self.tblProperties.isHidden = true
        self.lblMessage.isHidden = true
        self.tblProperties.allowMultipleSectionsOpen = false
        self.tblProperties.register(UINib(nibName: "MyListingsView", bundle: nil), forHeaderFooterViewReuseIdentifier: MyListingsView.kAccordionHeaderViewReuseIdentifier)

        DispatchQueue.main.async(execute: {
            KVNProgress.show(withStatus: "Loading My Listings")
        })
        self.getMyProperties()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MyDitchViewController {
    func getMyProperties() -> Void {
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getproperty?page=1&token=\(token)&show_owned_only=1&show_active_only=0&show_reviewed_only=1")
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
                        })
                        
                        return
                    }
                    self.properties = NSMutableArray()
                    let tmpProperties = (tempData!["data"] as! NSDictionary)["data"] as! NSArray
                    for i in 0..<tmpProperties.count {
                        let dict = tmpProperties[i] as! [String: AnyObject]
                        self.properties.add(dict)
                        if let bookings = dict["booking"] as? [AnyObject] {
                            self.properties.addObjects(from: bookings)
                        }
                    }
                    
                    DispatchQueue.main.async(execute: {
                        if self.properties.count > 0 {
                            self.lblMessage.isHidden = true
                            self.tblProperties.isHidden = false
                        }
                        else {
                            self.lblMessage.isHidden = false
                            self.tblProperties.isHidden = true
                        }
                        self.tblProperties.reloadData()
                        
                        self.getMyPendingProperties()
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
    func getMyPendingProperties() -> Void {
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getproperty?page=1&token=\(token)&show_owned_only=1&show_active_only=1&show_reviewed_only=-1")
        }
        
        DispatchQueue.main.async(execute: {
            KVNProgress.show(withStatus: "Loading My Listings")
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
                    let tempData = json as? NSDictionary
                    
                    let isSuccess = tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        
                        return
                    }
                    self.pendingProperties = NSMutableArray()
                    let tmpProperties = (tempData!["data"] as! NSDictionary)["data"] as! NSArray
                    self.pendingProperties.addObjects(from: tmpProperties as [AnyObject])
                    DispatchQueue.main.async(execute: {
            
                        if self.pendingProperties.count > 0 {
                            self.lblPendingMessage.isHidden = true
                            self.tblPendingProperties.isHidden = false
                        }
                        else {
                            self.lblPendingMessage.isHidden = false
                            self.tblPendingProperties.isHidden = true
                        }
                        
                        self.tblPendingProperties.reloadData()
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

extension MyDitchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 1 {
            return 1
        }
        else {
            return self.properties.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            let dictProperty = self.properties[section] as! NSDictionary
            if dictProperty["for_booking"] != nil {
                return 1
            }
            return 0
        }
        return pendingProperties.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 1 {
            return 0
        }
        return MyListingsView.kDefaultAccordionHeaderViewHeight;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 1 {
            return nil
        }
        let dictProperty = self.properties[section] as! NSDictionary
        let accordionHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyListingsView.kAccordionHeaderViewReuseIdentifier)
        if let listingView = accordionHeaderView?.viewWithTag(10) {
            listingView.isHidden = false
        }
        if let bookingView = accordionHeaderView?.viewWithTag(11) {
            bookingView.isHidden = true
        }
        
        if dictProperty["for_booking"] != nil {
            if let listingView = accordionHeaderView?.viewWithTag(10) {
                listingView.isHidden = true
            }
            if let bookingView = accordionHeaderView?.viewWithTag(11) {
                bookingView.isHidden = false
                if let strParams = dictProperty["parameters"] as? String {
                    if let params = self.convertToDictionary(text: strParams) {
                        let df = DateFormatter()
                        df.dateFormat = "MM-dd-yyyy"
                        
                        let df1 = DateFormatter()
                        df1.dateFormat = "yyyy-MM-dd"
                        
                        var checkInDate = df.date(from: params["start_date"] as? String ?? "01-01-2017")
                        var checkOutDate = df.date(from: params["end_date"] as? String ?? "01-01-2017")
                        
                        if checkInDate == nil {
                            checkInDate = df1.date(from: params["start_date"] as! String)
                        }
                        if checkOutDate == nil {
                            checkOutDate = df1.date(from: params["end_date"] as! String)
                        }
                        
                        let months = checkOutDate!.months(from: checkInDate!)
                        //var parentProperty: [String: AnyObject]?
                        for i in 0..<self.properties.count {
                            if let dictTemp = self.properties[i] as? [String: AnyObject] {
                                if dictTemp["for_booking"] == nil {
                                    if dictProperty["property_id"] as! Int == dictTemp["id"] as! Int {
                                        //let priceNumber = NSNumber.init(value: dictTemp["price"] as! Int)
                                        //let price = Utils.suffixNumber(priceNumber)
                                        let totalPriceInteger = (dictTemp["price"] as! Int) * months
                                        let totalPriceNumber = NSNumber.init(value: totalPriceInteger)
                                        let totalPrice = Utils.suffixNumber(totalPriceNumber)
                                        
                                        if let lblTitle = bookingView.viewWithTag(32) as? UILabel {
                                            lblTitle.text = "\(months) Month(s)/$\(totalPrice)"
                                        }
                                    }
                                }
                            }
                        }

                        if let viewButtons = bookingView.viewWithTag(33) {
                        
                            let btnAccept = viewButtons.subviews[0] as! UIButton
                            btnAccept.tag = section
                            //print("accpept button tag: \(btnAccept.tag)")
                            btnAccept.addTarget(self, action: #selector(acceptButtonTapped(button:)), for: .touchUpInside)
                            
                            let btnReject = viewButtons.subviews[1] as! UIButton
                            btnReject.tag = section
                            //print("accpept button tag: \(btnReject.tag)")
                            btnReject.addTarget(self, action: #selector(rejectButtonTapped(button:)), for: .touchUpInside)
                            
                            if dictProperty["status"] as? String ?? "" == "rejected" {
                                btnAccept.isHidden = true
                                btnReject.isHidden = true
                            }
                            
                            if dictProperty["accepted_for_booking"] as? Bool ?? false == true {
                                btnAccept.isHidden = true
                                btnReject.isHidden = true
                            }
                        }
                    }
                    
                }
            }
        }
        else {
            if let dictImage = dictProperty["img_url"] as? NSDictionary {
                if let imgURL = dictImage["sm"] as? String {
                    if let listingView = accordionHeaderView?.viewWithTag(10) {
                        if let ivProperty = listingView.viewWithTag(20) as? UIImageView {
                            ivProperty.sd_setImage(with: URL(string: imgURL))
                        }
                        if let lblTitle = listingView.viewWithTag(21) as? UILabel {
                            lblTitle.text = dictProperty["title"] as? String
                        }
                        if let lblAddress = listingView.viewWithTag(22) as? UILabel {
                            lblAddress.text = dictProperty["address1"] as? String
                        }
                        
                        if let viewSuspend = listingView.viewWithTag(23) {
                            
                            let btnSuspend = viewSuspend.subviews[0] as! UIButton
                            btnSuspend.tag = section
                            btnSuspend.addTarget(self, action: #selector(suspendButtonTapped(btn:)), for: .touchUpInside)
                            
                            btnSuspend.setTitle("Suspend", for: .normal)
                            if dictProperty["status"] as? String ?? "" == "inactive" {
                                btnSuspend.setTitle("Activate", for: .normal)
                            }
                        }
                        
                    }
                }
            }
        }
        
//        if let btnProperty = accordionHeaderView?.viewWithTag(13) as? UIButton {
//            btnProperty.tag = section
//        }
//
//        if let btnAction = accordionHeaderView?.viewWithTag(12) as? UIButton {
//            btnAction.tag = section
//        }
//
//        if let dictImage = dictProperty["img_url"] as? NSDictionary {
//            if let imgURL = dictImage["sm"] as? String {
//                if let ivProperty = accordionHeaderView?.viewWithTag(10) as? UIImageView {
//                    ivProperty.sd_setImage(with: URL(string: imgURL))
//                }
//            }
//        }
//
//        let address1 = dictProperty["address1"] as! String
//
//        if let lblAddress = accordionHeaderView?.viewWithTag(11) as? UILabel {
//            lblAddress.text = address1
//        }
//
//        if let lblStatus = accordionHeaderView?.viewWithTag(14) as? UILabel {
//            lblStatus.text = dictProperty["status"] as? String
//            lblStatus.isHidden = true
//        }
        
        return accordionHeaderView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if tableView.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bookingCell", for: indexPath) as! BookingRequestCell
            if let dictBooking = self.properties[indexPath.section] as? [String: AnyObject] {
                for i in 0..<self.properties.count {
                    if let dictTemp = self.properties[i] as? [String: AnyObject] {
                        if dictTemp["for_booking"] == nil {
                            if dictBooking["property_id"] as! Int == dictTemp["id"] as! Int {
                                cell.lblTitle.text = dictTemp["title"] as? String
                                cell.lblAddress.text = dictTemp["address1"] as? String
                                
                                let priceNumber = NSNumber.init(value: dictTemp["price"] as! Int)
                                let price = Utils.suffixNumber(priceNumber)
                                cell.lblRate.text = "$\(price)/\((dictTemp["term"]!).capitalized!)"
                                
                            }
                        }
                    }
                }
                
                if let dictCustomer = dictBooking["customer_user"] as? [String: AnyObject] {
                    cell.lblContactNumber.text = dictCustomer["cid"] as? String
                    cell.lblLeasor.text = dictCustomer["user_name"] as? String
                }
                cell.btnAccept.tag = indexPath.section
                cell.btnAccept.addTarget(self, action: #selector(innerAcceptButtonTapped(button:)), for: .touchUpInside)
                cell.lblReject.tag = indexPath.section
                cell.lblReject.addTarget(self, action: #selector(innerRejectButtonTapped(button:)), for: .touchUpInside)
                
                if dictBooking["status"] as? String ?? "" == "rejected" {
                    cell.btnAccept.isHidden = true
                    cell.lblReject.isHidden = true
                }
                
                if dictBooking["accepted_for_booking"] as? Bool ?? false == true {
                    cell.btnAccept.isHidden = true
                    cell.lblReject.isHidden = true
                }
            }
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "propertyCell", for: indexPath) as! MessagesTableViewCell
            let dictProperty = self.pendingProperties[indexPath.row] as! NSDictionary
            cell.btnProperty.tag = indexPath.row
            cell.btnAction.tag = indexPath.row
            if let dictImage = dictProperty["img_url"] as? NSDictionary {
                if let imgURL = dictImage["sm"] as? String {
                    cell.ivProperty.sd_setImage(with: URL(string: imgURL))
                }
            }
            
            let address1 = dictProperty["address1"] as! String
            
            cell.lblAddress.text = address1
            cell.lblStatus.text = dictProperty["status"] as? String
            cell.lblStatus.isHidden = true
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        if editingStyle == .delete {
            if tableView.tag == 0 {
                let dictProperty = self.properties[indexPath.row] as! NSDictionary
                self.properties.removeObject(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                if UserDefaults.standard.object(forKey: "token") != nil {
                    let token = UserDefaults.standard.object(forKey: "token") as! String
                    self.deleteMyProperty(token, propertyId: String(dictProperty["id"] as! Int), forRow: indexPath.row)
                }
            }
            else {
                let dictProperty = self.pendingProperties[indexPath.row] as! NSDictionary
                self.pendingProperties.removeObject(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                if UserDefaults.standard.object(forKey: "token") != nil {
                    let token = UserDefaults.standard.object(forKey: "token") as! String
                    self.deleteMyProperty(token, propertyId: String(dictProperty["id"] as! Int), forRow: indexPath.row)
                }
            }
        }
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tblPendingProperties {
            let detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pDetailVC") as? PropertyDetailViewController
            let dictProperty = self.pendingProperties[indexPath.row] as! NSDictionary
            detailController!.propertyID = String(dictProperty["id"] as! Int)
            detailController?.dictProperty = dictProperty
            detailController?.isFromMainView = true
            
            self.navigationController?.pushViewController(detailController!, animated: true)
        }
//        if tableView.tag == 0 {
//            let detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pDetailVC") as? PropertyDetailViewController
//            let dictProperty = self.properties[indexPath.row] as! NSDictionary
//            detailController!.propertyID = String(dictProperty["id"] as! Int)
//            detailController?.dictProperty = dictProperty
//            detailController?.isFromMainView = true
//
//            self.navigationController?.pushViewController(detailController!, animated: true)
//        }
//        else {
//            let detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pDetailVC") as? PropertyDetailViewController
//            let dictProperty = self.pendingProperties[indexPath.row] as! NSDictionary
//            detailController!.propertyID = String(dictProperty["id"] as! Int)
//            detailController?.dictProperty = dictProperty
//            detailController?.isFromMainView = true
//
//            self.navigationController?.pushViewController(detailController!, animated: true)
//        }
    }
    
}

extension MyDitchViewController {
    func deleteMyProperty(_ token: String, propertyId: String, forRow row: Int) -> Void {
        let strURL = ("\(APIConstants.BasePath)/api/deleteproperty?token=\(token)&id=\(propertyId)")
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
                        //self.getProperties()
                        //                    self.properties.removeObjectAtIndex(row)
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
    
    func deleteProperty(_ propertyID: String) -> Void {
        var strURL = ""
        
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/deleteproperty?token=\(token)&id=\(propertyID)")
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
                        })
                        
                        return
                    }
                    
                    self.navigationController?.popToRootViewController(animated: true)
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

extension MyDitchViewController : FZAccordionTableViewDelegate {
    
    func tableView(_ tableView: FZAccordionTableView, willOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        
    }
    
    func tableView(_ tableView: FZAccordionTableView, didOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        
    }
    
    func tableView(_ tableView: FZAccordionTableView, willCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        
    }
    
    func tableView(_ tableView: FZAccordionTableView, didCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        
    }
    
    func tableView(_ tableView: FZAccordionTableView, canInteractWithHeaderAtSection section: Int) -> Bool {
        let dictProperty = self.properties[section] as! NSDictionary
        if dictProperty["for_booking"] != nil {
            return true
        }
        return false
    }
}

extension MyDitchViewController {
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func innerAcceptButtonTapped(button: UIButton) {
        if let dictBooking = self.properties[button.tag] as? [String: AnyObject] {
            KVNProgress.show(withStatus: "Approving Booking Request.")
            self.getLead(propertyId: String(dictBooking["property_id"] as! Int), booking: dictBooking)
        }
    }
    
    func innerRejectButtonTapped(button: UIButton) {
        if let dictBooking = self.properties[button.tag] as? [String: AnyObject] {
            self.rejectLease(booking: dictBooking)
        }
    }

    func acceptButtonTapped(button: UIButton) {
        if let dictBooking = self.properties[button.tag] as? [String: AnyObject] {
            KVNProgress.show(withStatus: "Approving Booking Request.")
            self.getLead(propertyId: String(dictBooking["property_id"] as! Int), booking: dictBooking)
        }
    }
    
    func getLead(propertyId: String, booking: [String: AnyObject]) {
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getlead?token=\(token)&property_id=\(propertyId)&process_step=negotiate")
        }
        
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
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
                        })
                        
                        return
                    }
                    
                    if let leadData = tempData!["data"] as? [String: AnyObject] {
                        if let leads = leadData["data"] as? [AnyObject] {
                            if leads.count > 0 {
                                for lead in leads {
                                    if lead["user_id"] as! Int == booking["customer_user_id"] as! Int {
                                        self.dictLead = lead as? [String: AnyObject]
                                    }
                                }
                            }
                        }
                    }
                    
                    if self.dictLead != nil {
                        self.sendLeaseDocument(docId: String(booking["id"] as! Int), leadId: String(self.dictLead!["id"] as! Int), booking: booking)
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
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
    
    func rejectButtonTapped(button: UIButton) {
        if let dictBooking = self.properties[button.tag] as? [String: AnyObject] {
            self.rejectLease(booking: dictBooking)
        }
    }
    
    func rejectLease(booking: [String: AnyObject]) -> Void {
        KVNProgress.show(withStatus: "Rejecting lease")
        
        var token = ""
        let strURL = "\(APIConstants.BasePath)/api/savedoctemplate"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
        }
        
        
        let strParams = "token=\(token)&doc_template_id=\(booking["id"]!)&status=rejected"
        
        
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
                    
                    self.getMyProperties()
                    
//                    DispatchQueue.main.async(execute: {
//                        let successVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "successVC") as! SuccessViewController
//                        successVC.successMessage = "Your booking request has been sent."
//                        self.navigationController?.pushViewController(successVC, animated: true)
//                    })
                    
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

    
    
    func sendLeaseDocument(docId: String, leadId: String, booking: [String: AnyObject]) -> Void {
        var strURL = ""
        
        if let strParams = booking["parameters"] as? String {
            if let params = self.convertToDictionary(text: strParams) {
                let df = DateFormatter()
                df.dateFormat = "MM-dd-yyyy"
                
                let df1 = DateFormatter()
                df1.dateFormat = "yyyy-MM-dd"
                
                var checkInDate = df.date(from: params["start_date"] as? String ?? "01-01-2018")
                var checkOutDate = df.date(from: params["end_date"] as? String ?? "02-01-2018")
                
                if checkInDate == nil {
                    checkInDate = df1.date(from: params["start_date"] as! String)
                }
                if checkOutDate == nil {
                    checkOutDate = df1.date(from: params["end_date"] as! String)
                }
                
                let billCategory = "lease"
                let billAmount = params["amount"] as? String ?? "0"
                let billingDescription = "Lease bill is created."
                let billingMonth = Calendar.current.dateComponents([.month], from: checkInDate!).month!
                let billingYear = Calendar.current.dateComponents([.year], from: checkInDate!).year!
                
                let billingDueDate = df1.string(from: Date())
                
                
                if UserDefaults.standard.object(forKey: "token") != nil {
                    let token = UserDefaults.standard.object(forKey: "token") as! String
                    strURL = "\(APIConstants.BasePath)/api/sendleasedoc?token=\(token)&doc_template_id=\(docId)&lead_id=\(leadId)&message=Proposal&bill_category=\(billCategory)&bill_amount=\(billAmount)&bill_description=\(billingDescription)&billing_month=\(billingMonth)&billing_year=\(billingYear)&bill_due_date=\(billingDueDate)"
                    
                    
                }
                
                let formattedURL = strURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let url = URL(string: formattedURL!)
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
                                })
                                
                                return
                            }
                            
                            DispatchQueue.main.async(execute: {
                                let successVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "successVC") as! SuccessViewController
                                successVC.successMessage = "Lease approved successfully."
                                self.navigationController?.pushViewController(successVC, animated: true)
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

    }

}

extension MyDitchViewController {
    func suspendButtonTapped(btn: UIButton) {
        if let property = self.properties[btn.tag] as? [String: AnyObject] {
            if property["status"] as? String ?? "active" == "active"  {
                let alert = UIAlertController(title: "", message: "Are you sure", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (alertAction) in
                        self.deactivateProperty(propertyId: String(property["id"] as! Int))
                }))
                alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (alertAction) in
                    
                }))
                self.present(alert, animated: true) {
                    
                }
            }
            else {
                self.activateProperty(propertyId: String(property["id"] as! Int))
            }
            
        }
        
        
    }
    func hideProperty(_ token: String, propertyId: String) -> Void {
        KVNProgress.show(withStatus: "Loading Properties")
        let strURL = ("\(APIConstants.BasePath)/api/hideproperty?token=\(token)&property_id=\(propertyId)")
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let dict = json as? NSDictionary
                    if dict!["success"] as! Bool == true {
                       self.getMyProperties()
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("", message: dict!["message"] as! String, controller: self, isActionRequired: false)
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

    func deactivateProperty(propertyId: String) -> Void {
        
        KVNProgress.show(withStatus: "Suspending Property")
        
        var token = ""
        
        var strURL = "\(APIConstants.BasePath)/api/savepropertyfield"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(strURL)?token=\(token)")
        }
        
        
        
        let body: NSDictionary = ["property_id": propertyId,
                                  "data": [["field": "status", "value": "inactive"]
            ]
        ]
        
        
        do {
            let jsonParamsData = try JSONSerialization.data(withJSONObject: body, options: [])
            
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
                        let tempData = json as? NSDictionary
                        
                        let isSuccess = tempData!["success"] as! Bool
                        
                        if isSuccess == false {
                            
                            DispatchQueue.main.async(execute: {
                                KVNProgress.dismiss()
                                let _utils = Utils()
                                _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            })
                            
                            return
                        }
                        
                        DispatchQueue.main.async(execute: {
                            self.getMyProperties()
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
                return()
                }.resume()
        }
        catch {
            
        }
        
    }

    
    func activateProperty(propertyId: String) -> Void {
        
        KVNProgress.show(withStatus: "Activating Property")
        
        var token = ""
        
        var strURL = "\(APIConstants.BasePath)/api/savepropertyfield"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(strURL)?token=\(token)")
        }
        
        
        
        let body: NSDictionary = ["property_id": propertyId,
                                  "data": [["field": "status", "value": "active"]
            ]
        ]
        
        
        do {
            let jsonParamsData = try JSONSerialization.data(withJSONObject: body, options: [])
            
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
                        let tempData = json as? NSDictionary
                        
                        let isSuccess = tempData!["success"] as! Bool
                        
                        if isSuccess == false {
                            
                            DispatchQueue.main.async(execute: {
                                KVNProgress.dismiss()
                                let _utils = Utils()
                                _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            })
                            
                            return
                        }
                        
                        DispatchQueue.main.async(execute: {
                            self.getMyProperties()
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
                return()
                }.resume()
        }
        catch {
            
        }
        
    }

}

