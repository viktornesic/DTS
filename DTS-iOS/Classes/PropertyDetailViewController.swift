//
//  PropertyDetailViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 04/04/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress
import GoogleMaps
import SDWebImage

class PropertyDetailViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var imgBookNow: UIImageView!
    @IBOutlet weak var btnBookNow: UIButton!
    @IBOutlet weak var viewBookingBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBooking: UIView!
    @IBOutlet weak var viewCallBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var btnRequestInfo: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnHide: UIButton!
    @IBOutlet weak var viewCall: UIView!
    @IBOutlet weak var imgCallAndHide: UIImageView!
    //@IBOutlet weak var btnAccount: UIButton!
    var dictProperty: NSDictionary!
    var images: [AnyObject] = []
    @IBOutlet weak var tblDetailBottomConstraint: NSLayoutConstraint!
    var reqType: Int?
    
    var propertyID: String!
    var propertyImages: NSMutableArray!
    @IBOutlet weak var tblDetail: UITableView!
    var isFromMainView: Bool?
    var amenities = ""
    var highlights = ""
    fileprivate let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    var driveDuration: String?
    var distance: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.returnAppDelegate().isBack = true
        
        reqType = 0
        
        let revealController = revealViewController()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        
        if let revealController = revealViewController() {
            revealController.panGestureRecognizer().isEnabled = false
        }
        
        self.tblDetail.estimatedRowHeight = 100.0
        self.tblDetail.rowHeight = UITableViewAutomaticDimension
        
        
        if UserDefaults.standard.object(forKey: "token") == nil {
            //self.imgCallAndHide.image = #imageLiteral(resourceName: "call_anon")
            self.btnRequestInfo.isHidden = false
            self.btnHide.isHidden = false
        }
    }
    
    @IBAction func bookNowButtonTapped(_ sender: Any) {
        if UserDefaults.standard.object(forKey: "token") != nil {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "bookingVC") as! BookingViewController
            controller.dictProperty = self.dictProperty as! [String : AnyObject]!
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else {
            self.reqType = nil
            AppDelegate.returnAppDelegate().selectedProperty = self.dictProperty
            self.performSegue(withIdentifier: "detailToSignUp", sender: self)
        }
    }
    
    
    @IBAction func callAgent(_ sender: AnyObject) {
        if let dictAuthour = self.dictProperty["author_user_info"] as? NSDictionary {
            if let phoneNumber = dictAuthour["cid"] as? String {
                if let url = URL(string: "tel://\(phoneNumber)") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    }
                    else {
                        Utils.showOKAlertRO("", message: "This device is not confgured to make call.", controller: self)
                    }
                }
            }
        }
    }
    
    @IBAction func callButtonTapped(_ sender: AnyObject) {
        if let dictAuthour = self.dictProperty["author_user_info"] as? NSDictionary {
            if let phoneNumber = dictAuthour["cid"] as? String {
                if let url = URL(string: "tel://\(phoneNumber)") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    }
                    else {
                        Utils.showOKAlertRO("", message: "This device is not confgured to make call.", controller: self)
                    }
                }
            }
        }
    }
    
    
    @IBAction func lhLinkButtonTapped(_ sender: AnyObject) {
//        let btn = sender as! UIButton
//        let indexPath = NSIndexPath(forRow: btn.tag, inSection: 0)
//        let cell = tblDetail.cellForRowAtIndexPath(indexPath) as! DescriptionTableViewCell
        if let lhLink = self.dictProperty["redirect_url"] as? String {
            if let url = URL(string: lhLink) {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    @IBAction func requestInfoButtonTapped(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "", message: "Are you sure you want to inquire this property?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (alertAction) in
            
        }))
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (alertAction) in
            if UserDefaults.standard.object(forKey: "token") == nil {
                AppDelegate.returnAppDelegate().selectedProperty = self.dictProperty
                self.performSegue(withIdentifier: "detailToSignUp", sender: self)
                self.reqType = 0
            }
            else {
                let token = UserDefaults.standard.object(forKey: "token") as! String
                self.inquireProperty(token, propertyId: String(self.dictProperty["id"] as! Int))
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func hideButtonTapped(_ sender: AnyObject) {
        if UserDefaults.standard.object(forKey: "token") == nil {
            AppDelegate.returnAppDelegate().selectedProperty = self.dictProperty
            self.performSegue(withIdentifier: "detailToSignUp", sender: self)
            reqType = 5
        }
        else {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            self.hideProperty(token, propertyId: String(dictProperty["id"] as! Int))
        }
    }
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        if AppDelegate.returnAppDelegate().isNewProperty != nil {
            AppDelegate.returnAppDelegate().isNewProperty = false
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBAction func btnAccount_Tapped(_ sender: AnyObject) {
        self.deleteProperty()
    }
    
    func deleteProperty() -> Void {
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
                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        KVNProgress.show()
//        self.getProperty()
        
        self.tabBarController?.tabBar.isHidden = true
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            if UIScreen.main.nativeBounds.height == 2436 {
                tblDetailBottomConstraint.constant = 0
                viewCallBottomConstraint.constant = 45
                viewBookingBottomConstraint.constant = 45
            }
            else {
                tblDetailBottomConstraint.constant = -5
                viewCallBottomConstraint.constant = 50
                viewBookingBottomConstraint.constant = 50
            }
        }
        
        self.viewBooking.isHidden = true
        self.viewCall.isHidden = false
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let leaseTerm = dictProperty["lease_term"] as? String ?? ""
            if let userInfo = dictProperty["author_user_info"] as? [String: AnyObject] {
                if let userCID = UserDefaults.standard.object(forKey: "cid") as? String {
                    if leaseTerm == "short" && userInfo["cid"] as? String ?? "" != userCID {
                        self.viewBooking.isHidden = false
                        self.viewCall.isHidden = true
                        self.btnBookNow.isEnabled = true
                    }
                    else if leaseTerm == "short" && userInfo["cid"] as? String ?? "" == userCID {
                        self.viewBooking.isHidden = false
                        self.viewCall.isHidden = true
                        self.btnBookNow.isEnabled = false
                    }
                }
            }
        }
        else {
            let leaseTerm = dictProperty["lease_term"] as? String ?? ""
            if leaseTerm == "short" {
                self.viewBooking.isHidden = false
                self.viewCall.isHidden = true
                self.btnBookNow.isEnabled = true
            }
        }
        
        
        if self.isFromMainView == nil {
            KVNProgress.show(withStatus: "Getting Properties")
            self.getProperty()
        }
        else {
            fillHighlights(self.dictProperty)
            fillAmenities(self.dictProperty)
            self.images = (self.dictProperty["imgs"] as! NSArray) as [AnyObject]
            self.getAddressFromCurrentLocation()
        }
        
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        self.tabBarController?.tabBar.isHidden = false
//        //self.view.layoutIfNeeded()
//        
//    }
    

    
    func getProperty() -> Void {
        var strURL = "\(APIConstants.BasePath)/api/getproperty?token=\(DTSConstants.Constants.guestToken)&property_id=\(propertyID!)&show_owned_only=0&show_active_only=0&show_reviewed_only=0"
        
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getproperty?token=\(token)&property_id=\(propertyID!)&show_owned_only=0&show_active_only=0&show_reviewed_only=0&page=1")
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
                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                    return
                }
                let tmpData = tempData!["data"] as! NSDictionary
                let arrData = tmpData["data"] as! NSArray
                let dictMetaData = tempData!["metdata"] as? NSDictionary
                
                self.dictProperty = arrData[0] as! NSDictionary
                
                let dictAuther = self.dictProperty["author_user_info"] as? NSDictionary
                if dictAuther != nil {
                    let autherCID = dictAuther!["cid"] as? Int
                    if autherCID != nil {
                        if dictMetaData != nil {
                            let dictUserInfo = dictMetaData!["user_info"] as? NSDictionary
                            if dictUserInfo != nil {
                                let userCID = dictUserInfo!["cid"] as? Int
                                if userCID != nil {
                                    if autherCID == userCID {
                                       //self.btnAccount.isHidden = false
                                    }
                                }
                            }
                        }
                    }
                }
                
                self.images = (self.dictProperty["imgs"] as! NSArray) as [AnyObject]
                    DispatchQueue.main.async(execute: {
                        self.tblDetail.reloadData()
                        self.getAddressFromCurrentLocation()
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// Mark: - UITableView
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            if AppDelegate.returnAppDelegate().isNewProperty != nil {
//                return 495
//            }
//            return 680
//        }
//        else if indexPath.row == 1 {
//            return 175
//        }
//        else if indexPath.row == 2 {
//            return 215
//        }
//        return 300
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.images.count > 0 {
            if let provider = self.dictProperty["provider"] as? String {
                if provider == "listhub" {
                    return self.images.count + 6
                }
            }

            return self.images.count + 5
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let provider = self.dictProperty["provider"] as? String {
            if provider == "listhub" {
                if indexPath.row == 0 {
                    if AppDelegate.returnAppDelegate().isNewProperty != nil {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell1", for: indexPath) as! DetailTableViewCell
                        
                        
                        let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                        let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                        debugPrint("Lat: \(lat), Long: \(long)")
                        cell.lat = lat
                        cell.long = long
                        
                        cell.showMap()
                        let dictImages = dictProperty["img_url"] as! [String: AnyObject]
                        let imgURL = dictImages["md"] as! String
                        if AppDelegate.returnAppDelegate().isNewProperty != nil {
                            if AppDelegate.returnAppDelegate().isNewProperty! == true {
                                //                        cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                                
                            }
                            else {
                                //                        cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                            }
                        }
                        else {
                            
                        }
                        
                        let price = String(dictProperty["price"] as! Int)
                        
                        cell.lblprice.text = ("$\(price )/\(self.dictProperty["term"] ?? "")")
                        
                        cell.lblAddress.text = "\((dictProperty["address1"] as! String).capitalized)"
                        cell.lblAddressLine2.text = "\((dictProperty["city"] as! String).capitalized), \((dictProperty["state_or_province"] as! String).uppercased()), \((dictProperty["zip"] as! String).capitalized)"
                        
                        
                        let bath = String(dictProperty["bath"] as! Int)
                        let bed = String(dictProperty["bed"] as! Int)
                        
                        cell.lblBeds.text = ("\(bed)")
                        cell.lblBaths.text = ("\(bath) baths")
                        
                        cell.lblSize.text = "\(self.dictProperty["lot_size"] as! Int)"
                        cell.selectionStyle = .none
                        return cell
                    }
                    let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailTableViewCell
                    //_ = dictProperty["img_url"] as! NSDictionary)["md"] as! String
                    
                    let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                    let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                    debugPrint("Lat: \(lat), Long: \(long)")
                    cell.lat = lat
                    cell.long = long
                    
                    cell.showMap()
                    
                    if AppDelegate.returnAppDelegate().isNewProperty != nil {
                        if AppDelegate.returnAppDelegate().isNewProperty! == true {
                            //                    cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                        }
                        else {
                            //                    cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                            
                        }
                    }
                    else {
                        cell.bgImages = self.images
                        
                    }
                    
                    let price = String(dictProperty["price"] as! Int)
                    
                    
                    cell.lblMoveInCost.text = "$\(price)"
                    cell.lblSecurityDeposit.text = "$0"
                    
                    
                    
                    
                    if let secDeposit = self.dictProperty["security_deposit"] as? Int {
                        cell.lblSecurityDeposit.text = "$\(secDeposit)"
                    }
                    
                    if let moveInCostCondition = self.dictProperty["move_in_cost"] as? String {
                        if moveInCostCondition.lowercased() == "1st month only" {
                            if let price = self.dictProperty["price"] as? Int {
                                cell.lblMoveInCost.text = "$\(price)"
                            }
                        }
                        else if moveInCostCondition.lowercased() == "1st month + sec deposit" {
                            if let price = self.dictProperty["price"] as? Int, let secDeipost = self.dictProperty["security_deposit"] as? Int {
                                let totalMoveInCost = price + secDeipost
                                cell.lblMoveInCost.text = "$\(totalMoveInCost)"
                            }
                        }
                        else if moveInCostCondition.lowercased() == "1st month + sec deposit + last month" {
                            if let price = self.dictProperty["price"] as? Int, let secDeipost = self.dictProperty["security_deposit"] as? Int {
                                let totalMoveInCost = (price * 2) + secDeipost
                                cell.lblMoveInCost.text = "$\(totalMoveInCost)"
                            }
                        }
                    }
                    
                    
                    cell.viewCounter.layer.cornerRadius = 6
                    cell.viewCounter.clipsToBounds = true
                    
                    if self.driveDuration != nil {
                        cell.lblDuration.text = self.driveDuration
                    }
                    
                    
                    let x = cell.cvBG.contentOffset.x
                    let w = cell.cvBG.bounds.size.width
                    let currentPage = Int(ceil(x/w))
                    print("Current Page: \(currentPage)")
                    cell.lblCounter.text = ("\(currentPage + 1)/\(cell.bgImages.count)")
                    
                    
                    
                    if price.characters.count > 4 {
                        let priceNumber = NSNumber.init(value: dictProperty["price"] as! Int as Int)
                        let price = Utils.suffixNumber(priceNumber)//String(dictProperty["price"] as! Int)
                        cell.lblprice.text = ("$\(price)/\(self.dictProperty["term"]!)")
                    }
                    else {
                        cell.lblprice.text = ("$\(price)/\(self.dictProperty["term"]!)")
                    }
                    
                    if let listing_category = self.dictProperty["listing_category"] as? String {
                        if listing_category == "purchase" {
                            
                            if price.characters.count > 4 {
                                let priceNumber = NSNumber.init(value: dictProperty["price"] as! Int as Int)
                                let price = Utils.suffixNumber(priceNumber)//String(dictProperty["price"] as! Int)
                                cell.lblprice.text = ("$\(price)")
                            }
                            else {
                                cell.lblprice.text = ("$\(price)")
                            }
                            
                            cell.lblMoveInCost.isHidden = true
                            cell.lblSecurityDeposit.isHidden = true
                            cell.lblCaptionMoveInCost.isHidden = true
                            cell.lblCaptionSecDeposit.isHidden = true
                        }
                    }

                    
                    cell.lblAddress.text = "\((dictProperty["address1"] as! String).capitalized)"
                    cell.lblAddressLine2.text = "\((dictProperty["city"] as! String).capitalized), \((dictProperty["state_or_province"] as! String).uppercased()), \((dictProperty["zip"] as! String).capitalized)"
                    
                    let intBath = dictProperty["bath"] as! Int
                    let intBeds = dictProperty["bed"] as! Int
                    let bath = String(dictProperty["bath"] as! Int)
                    
                    
                    let bed = String(dictProperty["bed"] as! Int)
                    
                    //              _ = cell.imgView.image!
                    if intBeds > 1 {
                        cell.lblBeds.text = ("\(bed)")
                        cell.lblBedCaption.text = "Bed Rooms";
                    }
                    else {
                        cell.lblBeds.text = ("\(bed)")
                        cell.lblBedCaption.text = "Bed Room";
                    }
                    
                    if intBath > 1 {
                        cell.lblBaths.text = ("\(bath)")
                        cell.lblBathCaption.text = "Bath Rooms"
                    }
                    else {
                        cell.lblBaths.text = ("\(bath)")
                        cell.lblBathCaption.text = "Bath Room"
                    }
                    
                    cell.lblSize.text = "\(self.dictProperty["lot_size"] as! Int)"
                    
                    if let incentives = self.dictProperty["incentives"] as? [String: AnyObject] {
                        if let giftCards = incentives["gift_card"] as? [AnyObject] {
                            if giftCards.count > 0 {
                                cell.viewGCIcons.isHidden = false
                                for i in 0..<giftCards.count {  
                                    if i == 0 {
                                        if let dictGC1 = giftCards[i] as? [String: AnyObject] {
                                            let gc1ImageURL = dictGC1["image_url"] as! String
                                            cell.imgGC1.sd_setImage(with: URL(string: gc1ImageURL))
                                        }
                                    }
                                    else if i == 1 {
                                        if let dictGC2 = giftCards[i] as? [String: AnyObject] {
                                            let gc2ImageURL = dictGC2["image_url"] as! String
                                            cell.imgGC2.sd_setImage(with: URL(string: gc2ImageURL))
                                        }
                                    }
                                    else if i == 2 {
                                        if let dictGC3 = giftCards[i] as? [String: AnyObject] {
                                            let gc3ImageURL = dictGC3["image_url"] as! String
                                            cell.imgGC3.sd_setImage(with: URL(string: gc3ImageURL))
                                        }
                                    }
                                }
                            }
                        }
                    }

                    
                    cell.selectionStyle = .none
                    return cell
                }
                else if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "StreetTableViewCell", for: indexPath) as! StreetTableViewCell
                    let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                    let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                    debugPrint("Lat: \(lat), Long: \(long)")
                    cell.lat = lat
                    cell.long = long
                    cell.showStreeView()
                    cell.fullScreenButton.addTarget(self, action: #selector(PropertyDetailViewController.goStreetView(_:)), for: UIControlEvents.touchUpInside)
                    
                    return cell
                }
                else if indexPath.row == 2 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescriptionTableViewCell
                    cell.lblTitle.text = self.dictProperty["title"] as? String
                    cell.lblDescription.text = self.dictProperty["description"] as? String
                    cell.selectionStyle = .none
                    return cell
                }
                else if indexPath.row == 3 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "amenCell", for: indexPath) as! DescriptionTableViewCell
                    //            cell.lblDescription.text = self.dictProperty["description"] as? String
                    if highlights.characters.count > 0 {
                        cell.lblPropertyHighlights.text = highlights
                    }
                    else {
                        cell.lblPropertyHighlights.text = "\n\n\t None Listed"
                    }
                    if amenities.characters.count > 0 {
                        cell.lblDescription.text = amenities
                    }
                    else {
                        cell.lblDescription.text = "\n\n\t None Listed"
                    }
                    cell.selectionStyle = .none
                    return cell
                }
                else if indexPath.row == self.images.count + 4 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath) as! ReportTableViewCell
                    return cell
                }
                else if indexPath.row == self.images.count + 5 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "listhubCell", for: indexPath) as! DescriptionTableViewCell
                    cell.agentName.text = self.dictProperty["agent_name"] as? String
                    cell.lblBrokageOffice.text = self.dictProperty["brokerage_name"] as? String
                    if let dictAuthour = self.dictProperty["author_user_info"] as? NSDictionary {
                        cell.lblContact.text = (dictAuthour["cid"] as? String)?.toPhoneNumber()
                    }
                    
                    cell.btnContact.addTarget(self, action: #selector(PropertyDetailViewController.callAgent(_:)), for: .touchUpInside)
                    
                    if let redirectLink = self.dictProperty["redirect_url"] as? String {
                        let attributedString = NSMutableAttributedString(string: "Original Post")
                        attributedString.setAsLink("Original Post", linkURL: redirectLink)
                        cell.lblLink.attributedText = attributedString
                        //cell.lblLink.text = self.dictProperty["redirect_url"] as? String
                    }
                    cell.btnLHLink.tag = indexPath.row
                    cell.btnLHLink.addTarget(self, action: #selector(PropertyDetailViewController.lhLinkButtonTapped(_:)), for: .touchUpInside)
                    //cell.btnLHLink.hidden = true
                    cell.btnLHLink.tag = indexPath.row
                    cell.selectionStyle = .none
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "propertyCell", for: indexPath) as! PropertyDetailTableViewCell
                    let dictImage = self.images[indexPath.row - 4] as! NSDictionary
                    let dictImages = dictImage["img_url"] as! [String: AnyObject]
                    let imgURL = dictImages["md"] as! String
                    
                    
                    if AppDelegate.returnAppDelegate().isNewProperty != nil {
                        cell.ivBG.image = self.propertyImages[indexPath.row - 1] as? UIImage
                    }
                    else {
                        let placeHoderImage = UIImage(named: "placeholderImg.png")
                        cell.ivBG.sd_setImage(with: URL(string: imgURL), placeholderImage: placeHoderImage)
//                        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
//                            cell.ivBG.image = image
//                        })
                    }
                    
                    cell.ivBG.contentMode = .scaleAspectFill
                    cell.ivBG.clipsToBounds = true
                    cell.selectionStyle = .none
                    return cell
                }
            }
            else {
                if indexPath.row == 0 {
                    if AppDelegate.returnAppDelegate().isNewProperty != nil {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell1", for: indexPath) as! DetailTableViewCell
                        
                        
                        let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                        let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                        debugPrint("Lat: \(lat), Long: \(long)")
                        cell.lat = lat
                        cell.long = long
                        
                        cell.showMap()
                        
                        let dictImages = dictProperty["img_url"] as! [String: AnyObject]
                        let imgURL = dictImages["md"] as! String
                        if AppDelegate.returnAppDelegate().isNewProperty != nil {
                            if AppDelegate.returnAppDelegate().isNewProperty! == true {
                                //                        cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                                
                            }
                            else {
                                //                        cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                            }
                        }
                        else {
                            
                        }
                        
                        let price = String(dictProperty["price"] as! Int)
                        
                        cell.lblprice.text = ("$\(price ?? "")/\(self.dictProperty["term"] ?? "")")
                        
                        cell.lblAddress.text = "\((dictProperty["address1"] as! String).capitalized)"
                        cell.lblAddressLine2.text = "\((dictProperty["city"] as! String).capitalized), \((dictProperty["state_or_province"] as! String).uppercased()), \((dictProperty["zip"] as! String).capitalized)"
                        
                        
                        let bath = String(dictProperty["bath"] as! Int)
                        let bed = String(dictProperty["bed"] as! Int)
                        
                        cell.lblBeds.text = ("\(bed)")
                        cell.lblBaths.text = ("\(bath) baths")
                        
                        cell.lblSize.text = "\(self.dictProperty["lot_size"] as! Int)"
                        cell.selectionStyle = .none
                        return cell
                    }
                    let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailTableViewCell
                    //_ = dictProperty["img_url"] as! NSDictionary)["md"] as! String
                    
                    let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                    let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                    debugPrint("Lat: \(lat), Long: \(long)")
                    cell.lat = lat
                    cell.long = long
                    
                    cell.showMap()
                    
                    if AppDelegate.returnAppDelegate().isNewProperty != nil {
                        if AppDelegate.returnAppDelegate().isNewProperty! == true {
                            //                    cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                        }
                        else {
                            //                    cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                            
                        }
                    }
                    else {
                        cell.bgImages = self.images
                        
                    }
                    
                    let price = String(dictProperty["price"] as! Int)
                    
                    cell.lblMoveInCost.text = "$\(price)"
                    cell.lblSecurityDeposit.text = "$0"
                    
                    if let secDeposit = self.dictProperty["security_deposit"] as? Int {
                        cell.lblSecurityDeposit.text = "$\(secDeposit)"
                    }
                    
                    if let moveInCostCondition = self.dictProperty["move_in_cost"] as? String {
                        if moveInCostCondition.lowercased() == "1st month only" {
                            if let price = self.dictProperty["price"] as? Int {
                                cell.lblMoveInCost.text = "$\(price)"
                            }
                        }
                        else if moveInCostCondition.lowercased() == "1st month + sec deposit" {
                            if let price = self.dictProperty["price"] as? Int, let secDeipost = self.dictProperty["security_deposit"] as? Int {
                                let totalMoveInCost = price + secDeipost
                                cell.lblMoveInCost.text = "$\(totalMoveInCost)"
                            }
                        }
                        else if moveInCostCondition.lowercased() == "1st month + sec deposit + last month" {
                            if let price = self.dictProperty["price"] as? Int, let secDeipost = self.dictProperty["security_deposit"] as? Int {
                                let totalMoveInCost = (price * 2) + secDeipost
                                cell.lblMoveInCost.text = "$\(totalMoveInCost)"
                            }
                        }
                    }
                    cell.viewCounter.layer.cornerRadius = 6
                    cell.viewCounter.clipsToBounds = true
                    
                    if self.driveDuration != nil {
                        cell.lblDuration.text = self.driveDuration
                    }
                    
                    
                    
                    let x = cell.cvBG.contentOffset.x
                    let w = cell.cvBG.bounds.size.width
                    let currentPage = Int(ceil(x/w))
                    print("Current Page: \(currentPage)")
                    cell.lblCounter.text = ("\(currentPage + 1)/\(cell.bgImages.count)")
                    
                    
                    
                    if price.characters.count > 4 {
                        let priceNumber = NSNumber.init(value: dictProperty["price"] as! Int as Int)
                        let price = Utils.suffixNumber(priceNumber)//String(dictProperty["price"] as! Int)
                        cell.lblprice.text = ("$\(price)/\(self.dictProperty["term"]!)")
                    }
                    else {
                        cell.lblprice.text = ("$\(price)/\(self.dictProperty["term"]!)")
                    }
                    
                    if let listing_category = self.dictProperty["listing_category"] as? String {
                        if listing_category == "purchase" {
                            
                            if price.characters.count > 4 {
                                let priceNumber = NSNumber.init(value: dictProperty["price"] as! Int as Int)
                                let price = Utils.suffixNumber(priceNumber)//String(dictProperty["price"] as! Int)
                                cell.lblprice.text = ("$\(price)")
                            }
                            else {
                                cell.lblprice.text = ("$\(price)")
                            }
                            
                            cell.lblMoveInCost.isHidden = true
                            cell.lblSecurityDeposit.isHidden = true
                            cell.lblCaptionMoveInCost.isHidden = true
                            cell.lblCaptionSecDeposit.isHidden = true
                        }
                    }
                    
                    cell.lblAddress.text = "\((dictProperty["address1"] as! String).capitalized)"
                    cell.lblAddressLine2.text = "\((dictProperty["city"] as! String).capitalized), \((dictProperty["state_or_province"] as! String).uppercased()), \((dictProperty["zip"] as! String).capitalized)"
                    
                    let intBath = dictProperty["bath"] as! Int
                    let intBeds = dictProperty["bed"] as! Int
                    let bath = String(dictProperty["bath"] as! Int)
                    let bed = String(dictProperty["bed"] as! Int)
                    
                    //              _ = cell.imgView.image!
                    if intBeds > 1 {
                        cell.lblBeds.text = ("\(bed)")
                        cell.lblBedCaption.text = "Bed Rooms";
                    }
                    else {
                        cell.lblBeds.text = ("\(bed)")
                        cell.lblBedCaption.text = "Bed Room";
                    }
                    
                    if intBath > 1 {
                        cell.lblBaths.text = ("\(bath)")
                        cell.lblBathCaption.text = "Bath Rooms"
                    }
                    else {
                        cell.lblBaths.text = ("\(bath)")
                        cell.lblBathCaption.text = "Bath Room"
                    }
                    
                    cell.lblSize.text = "\(self.dictProperty["lot_size"] as! Int)"
                    
                    
                    if let incentives = self.dictProperty["incentives"] as? [String: AnyObject] {
                        if let giftCards = incentives["gift_card"] as? [AnyObject] {
                            if giftCards.count > 0 {
                                cell.viewGCIcons.isHidden = false
                                for i in 0..<giftCards.count {
                                    if i == 0 {
                                        if let dictGC1 = giftCards[i] as? [String: AnyObject] {
                                            let gc1ImageURL = dictGC1["image_url"] as! String
                                            cell.imgGC1.sd_setImage(with: URL(string: gc1ImageURL))
                                        }
                                    }
                                    else if i == 1 {
                                        if let dictGC2 = giftCards[i] as? [String: AnyObject] {
                                            let gc2ImageURL = dictGC2["image_url"] as! String
                                            cell.imgGC2.sd_setImage(with: URL(string: gc2ImageURL))
                                        }
                                    }
                                    else if i == 2 {
                                        if let dictGC3 = giftCards[i] as? [String: AnyObject] {
                                            let gc3ImageURL = dictGC3["image_url"] as! String
                                            cell.imgGC3.sd_setImage(with: URL(string: gc3ImageURL))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    cell.selectionStyle = .none
                    return cell
                }
                else if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "StreetTableViewCell", for: indexPath) as! StreetTableViewCell
                    let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                    let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                    debugPrint("Lat: \(lat), Long: \(long)")
                    cell.lat = lat
                    cell.long = long
                    cell.showStreeView()
                    cell.fullScreenButton.addTarget(self, action: #selector(PropertyDetailViewController.goStreetView(_:)), for: UIControlEvents.touchUpInside)
                    
                    return cell
                }
                else if indexPath.row == 2 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescriptionTableViewCell
                    cell.lblTitle.text = self.dictProperty["title"] as? String
                    cell.lblDescription.text = self.dictProperty["description"] as? String
                    cell.selectionStyle = .none
                    return cell
                }
                else if indexPath.row == 3 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "amenCell", for: indexPath) as! DescriptionTableViewCell
                    //            cell.lblDescription.text = self.dictProperty["description"] as? String
                    if highlights.characters.count > 0 {
                        cell.lblPropertyHighlights.text = highlights
                    }
                    else {
                        cell.lblPropertyHighlights.text = "\n\n\t None Listed"
                    }
                    if amenities.characters.count > 0 {
                        cell.lblDescription.text = amenities
                    }
                    else {
                        cell.lblDescription.text = "\n\n\t None Listed"
                    }
                    cell.selectionStyle = .none
                    return cell
                }
                else if indexPath.row == self.images.count + 4 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath) as! ReportTableViewCell
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "propertyCell", for: indexPath) as! PropertyDetailTableViewCell
                    let dictImage = self.images[indexPath.row - 4] as! NSDictionary
                    let dictImages = dictImage["img_url"] as! [String: AnyObject]
                    let imgURL = dictImages["md"] as! String
                    
                    
                    if AppDelegate.returnAppDelegate().isNewProperty != nil {
                        cell.ivBG.image = self.propertyImages[indexPath.row - 1] as? UIImage
                    }
                    else {
                        let placeHoderImage = UIImage(named: "placeholderImg.png")
                        cell.ivBG.sd_setImage(with: URL(string: imgURL), placeholderImage: placeHoderImage)
//                        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
//                            cell.ivBG.image = image
//                        })
                    }
                    
                    cell.ivBG.contentMode = .scaleAspectFill
                    cell.ivBG.clipsToBounds = true
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }
        else {
            if indexPath.row == 0 {
                if AppDelegate.returnAppDelegate().isNewProperty != nil {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell1", for: indexPath) as! DetailTableViewCell
                    
                    
                    let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                    let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                    debugPrint("Lat: \(lat), Long: \(long)")
                    cell.lat = lat
                    cell.long = long
                    
                    cell.showMap()
                    
                    let dictImages = dictProperty["img_url"] as! [String: AnyObject]
                    let imgURL = dictImages["md"] as! String
                    if AppDelegate.returnAppDelegate().isNewProperty != nil {
                        if AppDelegate.returnAppDelegate().isNewProperty! == true {
                            //                        cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                            
                        }
                        else {
                            //                        cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                        }
                    }
                    else {
                        
                    }
                    
                    let price = String(dictProperty["price"] as! Int)
                    
                    cell.lblprice.text = ("$\(price ?? "")/\(self.dictProperty["term"] ?? "")")
                    
                    cell.lblAddress.text = "\((dictProperty["address1"] as! String).capitalized)"
                    cell.lblAddressLine2.text = "\((dictProperty["city"] as! String).capitalized), \((dictProperty["state_or_province"] as! String).uppercased()), \((dictProperty["zip"] as! String).capitalized)"
                    
                    
                    let bath = String(dictProperty["bath"] as! Int)
                    let bed = String(dictProperty["bed"] as! Int)
                    
                    cell.lblBeds.text = ("\(bed)")
                    cell.lblBaths.text = ("\(bath) baths")
                    
                    cell.lblSize.text = "\(self.dictProperty["lot_size"] as! Int)"
                    cell.selectionStyle = .none
                    return cell
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailTableViewCell
                //_ = dictProperty["img_url"] as! NSDictionary)["md"] as! String
                
                let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                debugPrint("Lat: \(lat), Long: \(long)")
                cell.lat = lat
                cell.long = long
                
                cell.showMap()
                
                if AppDelegate.returnAppDelegate().isNewProperty != nil {
                    if AppDelegate.returnAppDelegate().isNewProperty! == true {
                        //                    cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                    }
                    else {
                        //                    cell.imgView.image = self.propertyImages[indexPath.row] as? UIImage
                        
                    }
                }
                else {
                    cell.bgImages = self.images
                    
                }
                
                let price = String(dictProperty["price"] as! Int)
                
                cell.lblMoveInCost.text = "$\(price)"
                cell.lblSecurityDeposit.text = "$0"
                
                if let secDeposit = self.dictProperty["security_deposit"] as? Int {
                    cell.lblSecurityDeposit.text = "$\(secDeposit)"
                }
                
                if let moveInCostCondition = self.dictProperty["move_in_cost"] as? String {
                    if moveInCostCondition.lowercased() == "1st month only" {
                        if let price = self.dictProperty["price"] as? Int {
                            cell.lblMoveInCost.text = "$\(price)"
                        }
                    }
                    else if moveInCostCondition.lowercased() == "1st month + sec deposit" {
                        if let price = self.dictProperty["price"] as? Int, let secDeipost = self.dictProperty["security_deposit"] as? Int {
                            let totalMoveInCost = price + secDeipost
                            cell.lblMoveInCost.text = "$\(totalMoveInCost)"
                        }
                    }
                    else if moveInCostCondition.lowercased() == "1st month + sec deposit + last month" {
                        if let price = self.dictProperty["price"] as? Int, let secDeipost = self.dictProperty["security_deposit"] as? Int {
                            let totalMoveInCost = (price * 2) + secDeipost
                            cell.lblMoveInCost.text = "$\(totalMoveInCost)"
                        }
                    }
                }
                
                
                
                cell.viewCounter.layer.cornerRadius = 6
                cell.viewCounter.clipsToBounds = true
                
                if self.driveDuration != nil {
                    cell.lblDuration.text = self.driveDuration
                }
                
                
                let x = cell.cvBG.contentOffset.x
                let w = cell.cvBG.bounds.size.width
                let currentPage = Int(ceil(x/w))
                print("Current Page: \(currentPage)")
                cell.lblCounter.text = ("\(currentPage + 1)/\(cell.bgImages.count)")
                
                
                
                if price.characters.count > 4 {
                    let priceNumber = NSNumber.init(value: dictProperty["price"] as! Int as Int)
                    let price = Utils.suffixNumber(priceNumber)//String(dictProperty["price"] as! Int)
                    cell.lblprice.text = ("$\(price)/\(self.dictProperty["term"]!)")
                }
                else {
                    cell.lblprice.text = ("$\(price)/\(self.dictProperty["term"]!)")
                }
                
                if let listing_category = self.dictProperty["listing_category"] as? String {
                    if listing_category == "purchase" {
                        
                        if price.characters.count > 4 {
                            let priceNumber = NSNumber.init(value: dictProperty["price"] as! Int as Int)
                            let price = Utils.suffixNumber(priceNumber)//String(dictProperty["price"] as! Int)
                            cell.lblprice.text = ("$\(price)")
                        }
                        else {
                            cell.lblprice.text = ("$\(price)")
                        }
                        
                        cell.lblMoveInCost.isHidden = true
                        cell.lblSecurityDeposit.isHidden = true
                        cell.lblCaptionMoveInCost.isHidden = true
                        cell.lblCaptionSecDeposit.isHidden = true
                    }
                }
                
                cell.lblAddress.text = "\((dictProperty["address1"] as! String).capitalized)"
                cell.lblAddressLine2.text = "\((dictProperty["city"] as! String).capitalized), \((dictProperty["state_or_province"] as! String).uppercased()), \((dictProperty["zip"] as! String).capitalized)"
                
                let intBath = dictProperty["bath"] as! Int
                let intBeds = dictProperty["bed"] as! Int
                let bath = String(dictProperty["bath"] as! Int)
                let bed = String(dictProperty["bed"] as! Int)
                
                //              _ = cell.imgView.image!
                if intBeds > 1 {
                    cell.lblBeds.text = ("\(bed)")
                    cell.lblBedCaption.text = "Bed Rooms";
                }
                else {
                    cell.lblBeds.text = ("\(bed)")
                    cell.lblBedCaption.text = "Bed Room";
                }
                
                if intBath > 1 {
                    cell.lblBaths.text = ("\(bath)")
                    cell.lblBathCaption.text = "Bath Rooms"
                }
                else {
                    cell.lblBaths.text = ("\(bath)")
                    cell.lblBathCaption.text = "Bath Room"
                }
                
                cell.lblSize.text = "\(self.dictProperty["lot_size"] as! Int)"
                
                if let incentives = self.dictProperty["incentives"] as? [String: AnyObject] {
                    if let giftCards = incentives["gift_card"] as? [AnyObject] {
                        if giftCards.count > 0 {
                            cell.viewGCIcons.isHidden = false
                            for i in 0..<giftCards.count {
                                if i == 0 {
                                    if let dictGC1 = giftCards[i] as? [String: AnyObject] {
                                        let gc1ImageURL = dictGC1["image_url"] as! String
                                        cell.imgGC1.sd_setImage(with: URL(string: gc1ImageURL))
                                    }
                                }
                                else if i == 1 {
                                    if let dictGC2 = giftCards[i] as? [String: AnyObject] {
                                        let gc2ImageURL = dictGC2["image_url"] as! String
                                        cell.imgGC2.sd_setImage(with: URL(string: gc2ImageURL))
                                    }
                                }
                                else if i == 2 {
                                    if let dictGC3 = giftCards[i] as? [String: AnyObject] {
                                        let gc3ImageURL = dictGC3["image_url"] as! String
                                        cell.imgGC3.sd_setImage(with: URL(string: gc3ImageURL))
                                    }
                                }
                            }
                        }
                    }
                }
                
                cell.selectionStyle = .none
                return cell
            }
            else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "StreetTableViewCell", for: indexPath) as! StreetTableViewCell
                let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
                let long = (self.dictProperty["longitude"] as! NSString).doubleValue
                debugPrint("Lat: \(lat), Long: \(long)")
                cell.lat = lat
                cell.long = long
                cell.showStreeView()
                cell.fullScreenButton.addTarget(self, action: #selector(PropertyDetailViewController.goStreetView(_:)), for: UIControlEvents.touchUpInside)
                
                return cell
            }
            else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescriptionTableViewCell
                cell.lblTitle.text = self.dictProperty["title"] as? String
                cell.lblDescription.text = self.dictProperty["description"] as? String
                cell.selectionStyle = .none
                return cell
            }
            else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "amenCell", for: indexPath) as! DescriptionTableViewCell
                //            cell.lblDescription.text = self.dictProperty["description"] as? String
                if highlights.characters.count > 0 {
                    cell.lblPropertyHighlights.text = highlights
                }
                else {
                    cell.lblPropertyHighlights.text = "\n\n\t None Listed"
                }
                if amenities.characters.count > 0 {
                    cell.lblDescription.text = amenities
                }
                else {
                    cell.lblDescription.text = "\n\n\t None Listed"
                }
                cell.selectionStyle = .none
                return cell
            }
            else if indexPath.row == self.images.count + 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath) as! ReportTableViewCell
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "propertyCell", for: indexPath) as! PropertyDetailTableViewCell
                let dictImage = self.images[indexPath.row - 4] as! NSDictionary
                let dictImages = dictImage["img_url"] as! [String: AnyObject]
                let imgURL = dictImages["md"] as! String
                
                
                if AppDelegate.returnAppDelegate().isNewProperty != nil {
                    cell.ivBG.image = self.propertyImages[indexPath.row - 1] as? UIImage
                }
                else {
                    
                    let placeHoderImage = UIImage(named: "placeholderImg.png")
                    cell.ivBG.sd_setImage(with: URL(string: imgURL), placeholderImage: placeHoderImage)
//                    SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
//                        cell.ivBG.image = image
//                    })
                }
                
                cell.ivBG.contentMode = .scaleAspectFill
                cell.ivBG.clipsToBounds = true
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == self.images.count + 4 {
            let alert = UIAlertController(title: "", message: "Are You Sure?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
               self.reportProperty(String(self.dictProperty["id"] as! Int))
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (alertAction) in
                
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    // Mark: - Private Methods
    
    func goStreetView(_ sender: UIButton) -> Void  {
        self.performSegue(withIdentifier: "streetView", sender: sender)
    }
    
    // Mark: - Private Methods
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToSignUp" {
            let controller = segue.destination as! SignUpViewController
            controller.propertyId = String(dictProperty["id"] as! Int)
            controller.reqType = reqType
        }
        else if segue.identifier == "streetView"{
            let controller = segue.destination as! StreetViewController
            let lat = (self.dictProperty["latitude"] as! NSString).doubleValue
            let long = (self.dictProperty["longitude"] as! NSString).doubleValue
            controller.lat = lat
            controller.long = long
        }
    }
    
    @IBAction func btnInstantApply_Tapped(_ sender: AnyObject) {
        if UserDefaults.standard.object(forKey: "token") == nil {
            self.performSegue(withIdentifier: "detailToSignUp", sender: self)
            reqType = 1
        }
    }
    
    @IBAction func btnRequestInfo_Tapped(_ sender: AnyObject) {
        let alert = UIAlertController(title: "", message: "Are you sure you want to inquire this property?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (alertAction) in
            
        }))
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (alertAction) in
            if UserDefaults.standard.object(forKey: "token") == nil {
                AppDelegate.returnAppDelegate().selectedProperty = self.dictProperty
                self.performSegue(withIdentifier: "detailToSignUp", sender: self)
                self.reqType = nil
            }
            else {
                let token = UserDefaults.standard.object(forKey: "token") as! String
                self.inquireProperty(token, propertyId: String(self.dictProperty["id"] as! Int))
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
//    func getDrivingTime() -> Void {
//        KVNProgress.show()
//        let strURL = ("\(APIConstants.BasePath)/api/inquireproperty?token=\(token)&property_id=\(propertyId)")
//        let url = NSURL(string: strURL)
//        let request = NSURLRequest(URL: url!)
//        
//        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
//            if error == nil {
//                do {
//                    dispatch_async(dispatch_get_main_queue(), {
//                        KVNProgress.show()
//                    })
//                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
//                    let dict = json as? NSDictionary
//                    if dict!["success"] as! Bool == true {
//                        //                    let detailCell = self.tblDetail.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DetailTableViewCell
//                        //
//                        //
//                        //                    detailCell.btnRequestInfo.setTitle("Info requested", forState: .Normal)
//                        //                    detailCell.btnRequestInfo.enabled = false
//                        NSUserDefaults.standardUserDefaults().setObject("yes", forKey: propertyId)
//                        NSUserDefaults.standardUserDefaults().synchronize()
//                    }
//                    else {
//                        let _utils = Utils()
//                        _utils.showOKAlert("", message: dict!["message"] as! String, controller: self, isActionRequired: false)
//                    }
//                }
//                catch {
//                    
//                }
//                
//            }
//            else {
//                dispatch_async(dispatch_get_main_queue(), {
//                    KVNProgress.show()
//                })
//                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
//            }
//        }
//        dataTask.resume()
//    }
    
    func inquireProperty(_ token: String, propertyId: String) -> Void {
        KVNProgress.show(withStatus: "Inquiring Property")
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
                    let dict = json as? NSDictionary
                if dict!["success"] as! Bool == true {
//                    let detailCell = self.tblDetail.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DetailTableViewCell
//                    
//                    
//                    detailCell.btnRequestInfo.setTitle("Info requested", forState: .Normal)
//                    detailCell.btnRequestInfo.enabled = false
                    UserDefaults.standard.set("yes", forKey: propertyId)
                    UserDefaults.standard.synchronize()
                }
                else {
                    let _utils = Utils()
                    _utils.showOKAlert("", message: dict!["message"] as! String, controller: self, isActionRequired: false)
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

}

extension PropertyDetailViewController {
    
    func reportProperty(_ propertyId: String) -> Void {
        KVNProgress.show(withStatus: "Reporting Property")
        
        var strURL = "\(APIConstants.BasePath)/api/createsupportticket?token=\(DTSConstants.Constants.guestToken)&type=reported_listing&message=Reported%20listing%\(propertyId)"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = "\(APIConstants.BasePath)/api/createsupportticket?token=\(token)&type=reported_listing&message=Reported%20listing%\(propertyId)"
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
                    let dict = json as? NSDictionary
                    if dict!["success"] as! Bool == true {
                        //                    let detailCell = self.tblDetail.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DetailTableViewCell
                        //
                        //
                        //                    detailCell.btnRequestInfo.setTitle("Info requested", forState: .Normal)
                        //                    detailCell.btnRequestInfo.enabled = false
//                        NSUserDefaults.standardUserDefaults().setObject("yes", forKey: propertyId)
//                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                    else {
                        let _utils = Utils()
                        _utils.showOKAlert("", message: dict!["message"] as! String, controller: self, isActionRequired: false)
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
    
    func hideProperty(_ token: String, propertyId: String) -> Void {
        KVNProgress.show(withStatus: "Hiding Property")
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
                    let dict = json as? NSDictionary
                    if dict!["success"] as! Bool == true {
                        //                    let detailCell = self.tblDetail.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DetailTableViewCell
                        //
                        //
                        //                    detailCell.btnRequestInfo.setTitle("Info requested", forState: .Normal)
                        //                    detailCell.btnRequestInfo.enabled = false
//                        NSUserDefaults.standardUserDefaults().setObject("yes", forKey: propertyId)
//                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                    else {
                        let _utils = Utils()
                        _utils.showOKAlert("", message: dict!["message"] as! String, controller: self, isActionRequired: false)
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
    
    func fillHighlights(_ property: NSDictionary) -> Void {
        if let bizCenter = property["build_amen_biz_center"] as? Int {
            if bizCenter == 1 {
                highlights += "\n\n\t Business Center"
            }
        }
        if let concierge = property["build_amen_concierge"] as? Int {
            if concierge == 1 {
                highlights += "\n\n\t Concierge"
            }
        }
        if let doorman = property["build_amen_doorman"] as? Int {
            if doorman == 1 {
                highlights += "\n\n\t Doorman"
            }
        }
        if let dryCleaning = property["build_amen_dry_cleaning"] as? Int {
            if dryCleaning == 1 {
                highlights += "\n\n\t Dry Cleaning"
            }
        }
        if let elevator = property["build_amen_elevator"] as? Int {
            if elevator == 1 {
                highlights += "\n\n\t Elevator"
            }
        }
        if let fitnessCenter = property["build_amen_fitness_center"] as? Int {
            if fitnessCenter == 1 {
                highlights += "\n\n\t Fitness Center"
            }
        }
        if let garage = property["build_amen_park_garage"] as? Int {
            if garage == 1 {
                highlights += "\n\n\t Garage"
            }
        }
        if let secureEntry = property["build_amen_secure_entry"] as? Int {
            if secureEntry == 1 {
                highlights += "\n\n\t Secure Entry"
            }
        }
        if let storage = property["build_amen_storage"] as? Int {
            if storage == 1 {
                highlights += "\n\n\t Storage"
            }
        }
        if let swimmingPool = property["build_amen_swim_pool"] as? Int {
            if swimmingPool == 1 {
                highlights += "\n\n\t Swim Pool"
            }
        }
    }
    
    func fillAmenities(_ property: NSDictionary) -> Void {
        //•
        if let ac = property["unit_amen_ac"] as? Int {
            if ac == 1 {
                amenities += "\n\n\t Air Conditioning"
            }
        }
        if let balcony = property["unit_amen_balcony"] as? Int {
            if balcony == 1 {
                amenities += "\n\n\t Balcony"
            }
        }
        if let carpet = property["unit_amen_carpet"] as? Int {
            if carpet == 1 {
                amenities += "\n\n\t Carpet"
            }
        }
        if let ceilingFan = property["unit_amen_ceiling_fan"] as? Int {
            if ceilingFan == 1 {
                amenities += "\n\n\t Ceiling Fan"
            }
        }
        if let deck = property["unit_amen_deck"] as? Int {
            if deck == 1 {
                amenities += "\n\n\t Deck"
            }
        }
        if let dishWasher = property["unit_amen_dishwasher"] as? Int {
            if dishWasher == 1 {
                amenities += "\n\n\t Dishwasher"
            }
        }
        if let fireplace = property["unit_amen_fireplace"] as? Int {
            if fireplace == 1 {
                amenities += "\n\n\t Fireplace"
            }
        }
        if let floorCarpet = property["unit_amen_floor_carpet"] as? Int {
            if floorCarpet == 1 {
                amenities += "\n\n\t Carpeted Floors"
            }
        }
        if let floorHardWood = property["unit_amen_floor_hard_wood"] as? Int {
            if floorHardWood == 1 {
                amenities += "\n\n\t Hardwood Floors"
            }
        }
        if let furnished = property["unit_amen_furnished"] as? Int {
            if furnished == 1 {
                amenities += "\n\n\t Furnished"
            }
        }
        if let laundry = property["unit_amen_laundry"] as? Int {
            if laundry == 1 {
                amenities += "\n\n\t Laundry"
            }
        }
        if let parkingReserved = property["unit_amen_parking_reserved"] as? Int {
            if parkingReserved == 1 {
                amenities += "\n\n\t Parking Reserved"
            }
        }
    }
    
    func getAddressFromCurrentLocation() -> Void {
        
        //KVNProgress.show()
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                if let currentLocation = AppDelegate.returnAppDelegate().currentLocation {
                    Location.reverseGeocodeLocation(currentLocation, completion: { (placemark, error) in
                        if error != nil {
                            print("Reverse geocoder failed with error" + error!.localizedDescription)
                            DispatchQueue.main.async(execute: {
                                KVNProgress.dismiss()
                            })
                            return
                        }
                        
                        if placemark?.name != nil && placemark?.locality != nil && placemark?.country != nil {
                            let currentAddress = ("\(placemark!.name!), \(placemark!.locality!), \(placemark!.country!)")
//                            self.getDriveDuration(currentAddress, destinationAddress: self.dictProperty["address"] as! String)
                            if self.dictProperty != nil {
                                if let propertyAddress = self.dictProperty["address"] as? String {
                                    self.getDriveDuration(currentAddress, destinationAddress: propertyAddress)
                                }
                            }
                        }
                    })
                }
            }
        } else {
            print("Location services are not enabled")
        }
        
        
    }
    
    func getFormattedAddress(_ address: String) -> String {
        let addressToReturn = address.replacingOccurrences(of: ", ", with: ",").replacingOccurrences(of: " ", with: "+")
        return addressToReturn
    }
    
    func getDriveDuration(_ currentAddress: String, destinationAddress: String) -> Void {
        let formattedCurrentAddress = getFormattedAddress(currentAddress)
        let formattedDesitationAddress = getFormattedAddress(destinationAddress)
        let strURL = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\(formattedCurrentAddress)&destinations=\(formattedDesitationAddress)&key=\(googleMapsKey)"
        
//        let formattedURL = strURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.whitespaceCharacterSet())
        
        if let url = URL(string: strURL) {
            let request = URLRequest(url: url)
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil {
                    do {
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                        })
                        let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                        
                        if let rows = json["rows"] as? NSArray {
                            if rows.count > 0 {
                                if let dictElements = rows[0] as? NSDictionary {
                                    if let elements = dictElements["elements"] as? NSArray {
                                        if let geoElement = elements[0] as? NSDictionary {
                                            if let status = geoElement["status"] as? String {
                                                if status == "OK" {
                                                    if let duration = geoElement["duration"] as? NSDictionary {
                                                        self.driveDuration = duration["text"] as? String
                                                        
                                                        DispatchQueue.main.async(execute: {
                                                            
                                                            if self.driveDuration != nil {
                                                                if let cell = self.tblDetail.cellForRow(at: IndexPath(row: 0, section: 0)) as? DetailTableViewCell {
                                                                    cell.lblDuration.text = self.driveDuration
                                                                }
                                                                
                                                                //                                                            cell.lblDuration.text = "1 day 16 hours"
                                                                
                                                            }
                                                            //self.tblDetail.reloadData()
                                                        })
                                                        
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        print("worked")
                        
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


extension NSMutableAttributedString {
    
    public func setAsLink(_ textToFind:String, linkURL:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSLinkAttributeName, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}

extension String {
    public func toPhoneNumber() -> String {
        return replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: nil)
    }
}


