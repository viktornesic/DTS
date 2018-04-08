//
//  MenuViewController.swift
//  101Compaign-iOS
//
//  Created by Viktor on 04/05/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import MessageUI
import KVNProgress

class MenuViewController: UIViewController {
    
    @IBOutlet weak var lblBuildNumber: UILabel!
    @IBOutlet weak var tblMenu: UITableView!
    var items: NSArray!
    var items1: NSArray!
    var items2: NSArray!
    var presentedSection = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //side-purchase-credit
        
        
        
        view.backgroundColor = UIColor.black
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        
        let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        self.lblBuildNumber.text = "BUILD: \(buildNumber)"

        
//        items = [["icon": "account-gear.png", "title": "My Details"], ["icon": "account-gear.png", "title": "My Leases"], ["icon": "account-gear.png", "title": "My Rent"], ["icon": "account-gear.png", "title": "Search Agent"], ["icon": "account-gear.png", "title": "Ditch My Space"], ["icon": "account-gear.png", "title": "My Listings"], ["icon": "account-gear.png", "title": "Wallet"], ["icon": "account-gear.png", "title": "Place a Bid"]];
        
        items = [["icon": "myaccount.png", "title": "My Account"], ["icon": "myleases.png", "title": "My Leases & Bookings"], ["icon": "myrent.png", "title": "My Rent & Bills"], ["icon": "mysearch.png", "title": "My Search"], ["icon": "ditchmyspace.png", "title": "Ditch My Space"], ["icon": "myspace.png", "title": "My Space"], ["icon": "mywallet.png", "title": "Wallet"]];
        
//        items = [["icon": "account-gear.png", "title": "My Account"], ["icon": "account-gear.png", "title": "My Leases & Bookings"], ["icon": "account-gear.png", "title": "My Rent & Bills"], ["icon": "account-gear.png", "title": "My Search"], ["icon": "account-gear.png", "title": "Ditch My Space"], ["icon": "account-gear.png", "title": "My Space"]];
        
        items1 = [["icon": "techsupport.png", "title": "Technical Support"], ["icon": "feedback.png", "title": "Feedback"]];
        
        items2 = [["icon": "tos.png", "title": "Terms of Service"], ["icon": "pp.png", "title": "Privacy Policy"]];
        
        view.bringSubview(toFront: self.tblMenu)
        view.bringSubview(toFront: self.lblBuildNumber)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension MenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 50
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        let viewHeader = UIView(frame: frame)
        viewHeader.backgroundColor = UIColor.clear
        return viewHeader
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.items.count
        }
        else if section == 1 {
            return self.items1.count
        }
        else {
            return self.items2.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuTableViewCell
        if indexPath.section == 0 {
            let dict = self.items[indexPath.row] as! NSDictionary
            cell.lblTitle.text = dict["title"] as? String
            cell.ivMenu.image = UIImage.init(named: (dict["icon"] as? String)!)
        }
        else if indexPath.section == 1 {
            let dict = self.items1[indexPath.row] as! NSDictionary
            cell.lblTitle.text = dict["title"] as? String
            cell.ivMenu.image = UIImage.init(named: (dict["icon"] as? String)!)
        }
        else {
            let dict = self.items2[indexPath.row] as! NSDictionary
            cell.lblTitle.text = dict["title"] as? String
            cell.ivMenu.image = UIImage.init(named: (dict["icon"] as? String)!)
        }
        //        cell.selectionStyle = .None
        let viewBG = UIView(frame: cell.contentView.bounds)
        viewBG.backgroundColor = UIColor(hexString: "00c9ff")
        cell.selectedBackgroundView = viewBG
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

extension MenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let revealController = self.revealViewController()
        
        if UserDefaults.standard.object(forKey: "token") == nil {
            let navController = revealController?.frontViewController as! UINavigationController
            let frontController = navController.viewControllers.first as! PropertiesViewController
            frontController.sideMenuButtonTappedForLogin()
            revealController?.setFrontViewPosition(.right, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        if indexPath.section == 0 && indexPath.row == 2 {
        
        }
        else {
            if indexPath.row == AppDelegate.returnAppDelegate().presentedRow && indexPath.section == presentedSection {
                revealController?.setFrontViewPosition(.right, animated: true)
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
        }
        
        let storyboard: UIStoryboard!
        
        storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var newFrontController: UIViewController!
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let accountVC = storyboard.instantiateViewController(withIdentifier: "accountVC") as! AccountViewController
                accountVC.viewType = 0
                newFrontController = accountVC
                
            }
            else if indexPath.row == 1 {
                let paymentMethodVC = storyboard.instantiateViewController(withIdentifier: "paymentMethodsVC") as! PaymentMethodsViewController
                paymentMethodVC.selectedSegIndex = 1
                newFrontController = paymentMethodVC
                
            }
            else if indexPath.row == 2 {
                
                if AppDelegate.returnAppDelegate().dwollaCustomerStatus != nil {
//                    let paymentMethodVC = storyboard.instantiateViewControllerWithIdentifier("paymentMethodsVC") as! PaymentMethodsViewController
//                    newFrontController = paymentMethodVC
                    if AppDelegate.returnAppDelegate().paymentMethods.count > 0 {
                        let selectBillVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "selectBillVC") as! SelectBillAndAccountViewController
                        newFrontController = selectBillVC
                    }
                    else {
                        let paymentMethodVC = storyboard.instantiateViewController(withIdentifier: "paymentMethodsVC") as! PaymentMethodsViewController
                        newFrontController = paymentMethodVC
                    }
                }
                else {
                    let paymentMethodVC = storyboard.instantiateViewController(withIdentifier: "FNViewController") as! FNViewController
                    newFrontController = paymentMethodVC
                }
            }
            else if indexPath.row == 3 {
                let searchAgentVC = storyboard.instantiateViewController(withIdentifier: "editSearchAgentVC") as! EditSearchAgentViewController
                newFrontController = searchAgentVC
            }
            else if indexPath.row == 4 {
                AppDelegate.returnAppDelegate().userProperty = NSMutableDictionary()
                AppDelegate.returnAppDelegate().newlyCreatedPropertyId = 0
                AppDelegate.returnAppDelegate().isNewProperty = true
                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "uclclassVC") as! UCLClassViewController
                controller.listType = "goal"
                controller.hideBackButton = true
                controller.hideSideButton = false
                newFrontController = controller
            }
//            else {
//                newFrontController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myDitchVC") as! MyDitchViewController
//            }
            else if indexPath.row == 5 {
               newFrontController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myDitchVC") as! MyDitchViewController
            }
            else if indexPath.row == 6 {
                newFrontController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "walletVC") as! WalletViewController
            }
//            else {
//                newFrontController = UIStoryboard(name: "Auction", bundle: nil).instantiateViewController(withIdentifier: "bidVC") as! BidViewController
//            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                
                newFrontController = storyboard.instantiateViewController(withIdentifier: "supportVC")
            }
            else if indexPath.row == 1 {
                newFrontController = storyboard.instantiateViewController(withIdentifier: "feedbackVC")
            }
            
        }
        else {
            if indexPath.row == 0 {
                newFrontController = storyboard.instantiateViewController(withIdentifier: "tosVC")
            }
            else if indexPath.row == 1 {
                newFrontController = storyboard.instantiateViewController(withIdentifier: "privacyVC")
            }
        }
        
        
        let navigationController = UINavigationController(rootViewController: newFrontController)
        navigationController.isNavigationBarHidden = true
        revealController?.setFrontViewPosition(.right, animated: true)
        revealController?.setFront(navigationController, animated: true)
        //        revealController?.pushFrontViewController(navigationController, animated: true)
        AppDelegate.returnAppDelegate().presentedRow = indexPath.row
        presentedSection = indexPath.section
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
