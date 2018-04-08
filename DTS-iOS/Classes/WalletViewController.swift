//
//  WalletViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 28/06/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress

class WalletViewController: UIViewController {

    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var tblWallet: FZAccordionTableView!
    
    
    var giftCards = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let revealController = revealViewController()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        
        tblWallet.allowMultipleSectionsOpen = false
        tblWallet.register(UINib(nibName: "AccordionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: AccordionHeaderView.kAccordionHeaderViewReuseIdentifier)
        
        tblWallet.dataSource = self
        tblWallet.delegate = self
        
        self.lblMessage.text = "No Gift Cards"
        self.lblMessage.isHidden = true
        self.tblWallet.isHidden = true
        getGiftCards()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

}

extension WalletViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return giftCards.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return AccordionHeaderView.kDefaultAccordionHeaderViewHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletCell", for: indexPath) as! WalletTableViewCell
        let giftCard = giftCards[indexPath.section] as! [String: AnyObject]
        //  cell.lblOfferTitle.text = "\(giftCard["merchant_name"] as! String) \(giftCard["denomination"] as! Int)"
        let img = Barcode.fromString(string: giftCard["redemption_code"] as! String)
        cell.ivBarCode.image = img
        let balance = (giftCard["balance"] as! String as NSString).floatValue
        cell.lblBalance.text = "$\(String(format: "%.2f", balance))"
        cell.lblRedemptionCode.text = giftCard["redemption_code"] as? String
        cell.selectionStyle = .none
        cell.lblRedeemed.text = "READY TO USE"
        cell.lblRedeemed.textColor = UIColor.green//UIColor(hexString: "155e72")
        if let redeeemed = giftCard["redeemed"] as? Bool {
            if redeeemed == true {
                cell.lblRedeemed.text = "ALREADY CONSUMED"
                cell.lblRedeemed.textColor = UIColor.red
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let giftCard = giftCards[indexPath.row] as! [String: AnyObject]
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "walletDetailVC") as! WalletDetailViewController
        controller.giftCard = giftCard
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let accordionHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AccordionHeaderView.kAccordionHeaderViewReuseIdentifier)
        let giftCard = giftCards[section] as! [String: AnyObject]
//        if let bgView = accordionHeaderView?.viewWithTag(20) {
//            bgView.backgroundColor = UIColor.green
//            if let redeeemed = giftCard["redeemed"] as? Bool {
//                if redeeemed == true {
//                    bgView.backgroundColor = UIColor.red
//                }
//            }
//        }
        
        if let imgView = accordionHeaderView?.viewWithTag(10) as? UIImageView {
            if let imageURLString = giftCard["image_url"] as? String {
                if let imageURL = URL(string: imageURLString) {
                    imgView.sd_setImageWithURLWithFade(url: imageURL, placeholderImage: nil)
                }
            }
            
        }
        if let lblTitle = accordionHeaderView?.viewWithTag(11) as? UILabel {
            lblTitle.text = "\(giftCard["merchant_name"] as! String) \(giftCard["denomination"] as! Int)"
        }
        return accordionHeaderView
    }
}

// MARK: - <FZAccordionTableViewDelegate> -

extension WalletViewController : FZAccordionTableViewDelegate {
    
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


extension WalletViewController {
    func getGiftCards() -> Void {
        
        KVNProgress.show(withStatus: "Getting Gift Cards")
        
        var strURL = "\(APIConstants.BasePath)/api/getuserincentives?token=\(DTSConstants.Constants.guestToken)"
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = "\(APIConstants.BasePath)/api/getuserincentives?token=\(token)"
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
                    if tempData != nil {
                        if tempData!["error"] as? String != nil {
                            let error = tempData!["error"] as! String
                            if error == "user_not_found" {
                                UserDefaults.standard.set(nil, forKey: "token")
                                AppDelegate.returnAppDelegate().logOut()
                                return
                            }
                        }
                    }
                    let isSuccess = tempData!["success"] as! Bool//tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        
                        return
                    }
                    
                    let mainData = tempData!["data"] as? NSDictionary
                    let tmpGiftCards = mainData?["gift_card"] as? [AnyObject]
                    
                    if tmpGiftCards != nil {
                        self.giftCards = tmpGiftCards!
                        DispatchQueue.main.async(execute: {
                            if self.giftCards.count == 0 {
                                self.tblWallet.isHidden = true
                                self.lblMessage.isHidden = false
                            }
                            else {
                                self.lblMessage.isHidden = true
                                self.tblWallet.isHidden = false
                                self.tblWallet.reloadData()
                            }
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
}
