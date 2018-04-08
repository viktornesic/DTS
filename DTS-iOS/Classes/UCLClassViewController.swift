//
//  UCLClassViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 14/07/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

class UCLClassViewController: BaseViewController {

    @IBOutlet weak var ivHeaderLogo: UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tblClass: UITableView!
    @IBOutlet weak var btnSideMenu: UIButton!
    var listUCL: NSArray!
    var listType: String!
    var mainTitle: String!
    var hideBackButton: Bool!
    var hideSideButton: Bool!
    var controller: UCLClassViewController?
    var controller1: UCLLocationViewController?
    var detailController: UCLDetailsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if listType == "goal" {
            mainTitle = "Goal"
            listUCL = [["title": "relocating", "img": "btn-top.jpg"], ["title": "renting out", "img": "btn-middle.jpg"], ["title": "ditching", "img": "btn-bottom.jpg"]
            ]
        }
        else if listType == "time" {
            mainTitle = "Time Frame"
            listUCL = [["title": "ASAP", "img": "btn-top.jpg"], ["title": "1-3 Months", "img": "btn-middle.jpg"], ["title": "3+ Months", "img": "btn-bottom.jpg"]
            ]
        }
        else if listType == "class" {
            mainTitle = "What type of space do you want to list?"
            listUCL = [["title": "Entire Home", "desc": "Your entire home", "img": "btn-top.jpg"], ["title": "Private Room", "desc": "A single room in your home", "img": "btn-middle.jpg"], ["title": "Shared Room", "desc": "A couch, bed, etc", "img": "btn-bottom.jpg"]
            ]
        }
   
        tblClass.dataSource = self
        tblClass.delegate = self
        
        self.btnSideMenu.isHidden = hideSideButton
        self.btnBack.isHidden = hideBackButton
        
        self.ivHeaderLogo.isHidden = true
        
        if self.hideBackButton == true {
            self.ivHeaderLogo.isHidden = false
        }
        
        
        let revealController = revealViewController()
        
        
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton_Tapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension UCLClassViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listUCL.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! UCLCell
            cell.lblTitle.text = self.mainTitle
            cell.selectionStyle = .none
            return cell
        }
        
        if self.listType == "class" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "valueCell", for: indexPath) as! UCLCell
            let dictClass = self.listUCL[indexPath.row - 1] as! NSDictionary
            cell.lblTitle.text = dictClass["title"] as? String
            cell.lblDescription.text = dictClass["desc"] as? String
            if let strImage = dictClass["img"] as? String {
                cell.ivButtonBg.image = UIImage(named: strImage)
            }
            return cell
        }

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "valueCell1", for: indexPath) as! UCLCell
        let dictClass = self.listUCL[indexPath.row - 1] as! NSDictionary
        cell.lblTitle.text = dictClass["title"] as? String
        if let strImage = dictClass["img"] as? String {
            cell.ivButtonBg.image = UIImage(named: strImage)
        }
        return cell
        
    }
}

extension UCLClassViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
//            let titleCellHeight = (AppDelegate.returnAppDelegate().window?.frame.size.height)! - 360
//            return titleCellHeight
            return 383
        }
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var mTitle = ""
        if self.listType == "goal" {
            AppDelegate.returnAppDelegate().userProperty = NSMutableDictionary()
            if indexPath.row == 1 {
                AppDelegate.returnAppDelegate().userProperty.setObject("Relocating", forKey: "goal" as NSCopying)
                //mTitle = "Nice! What type of place is your entire home in?"
                
                self.controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "uclclassVC") as? UCLClassViewController
                controller!.listType = "time"
                controller!.mainTitle = mTitle
                controller?.hideBackButton = false
                controller?.hideSideButton = false
                self.navigationController?.pushViewController(controller!, animated: true)
            }
            else if indexPath.row == 2 {
                AppDelegate.returnAppDelegate().userProperty.setObject("Renting Out", forKey: "goal" as NSCopying)
                //mTitle = "Nice! What type of place is your private room in?"
                self.controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "uclclassVC") as? UCLClassViewController
                controller!.listType = "class"
                controller!.mainTitle = mTitle
                controller?.hideBackButton = false
                controller?.hideSideButton = false
                self.navigationController?.pushViewController(controller!, animated: true)
            }
            else if indexPath.row == 3 {
                AppDelegate.returnAppDelegate().userProperty.setObject("Ditching", forKey: "goal" as NSCopying)
                //mTitle = "Nice! What type of place is your shared space in?"
                
                self.controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "uclclassVC") as? UCLClassViewController
                controller!.listType = "time"
                controller!.mainTitle = mTitle
                controller?.hideBackButton = false
                controller?.hideSideButton = false
                self.navigationController?.pushViewController(controller!, animated: true)
            }
            
        }
        if self.listType == "time" {
            if indexPath.row == 1 {
                AppDelegate.returnAppDelegate().userProperty.setObject("ASAP", forKey: "timeFrame" as NSCopying)
                //mTitle = "Nice! What type of place is your entire home in?"
            }
            else if indexPath.row == 2 {
                AppDelegate.returnAppDelegate().userProperty.setObject("1-3 Months", forKey: "timeFrame" as NSCopying)
                //mTitle = "Nice! What type of place is your private room in?"
            }
            else if indexPath.row == 3 {
                AppDelegate.returnAppDelegate().userProperty.setObject("3+ Months", forKey: "timeFrame" as NSCopying)
                //mTitle = "Nice! What type of place is your shared space in?"
            }
            AppDelegate.returnAppDelegate().uclTitle = "Lease"
            if self.detailController == nil {
                self.detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ucldetailVC") as? UCLDetailsViewController
                detailController?.detailType = "lease"
            }
            self.navigationController?.pushViewController(self.detailController!, animated: true)
        }
        else if self.listType == "class" {
            if indexPath.row == 1 {
                AppDelegate.returnAppDelegate().userProperty.setObject("Entire Home", forKey: "uclClass" as NSCopying)
                mTitle = "Nice! What type of place is your entire home in?"
            }
            else if indexPath.row == 2 {
                AppDelegate.returnAppDelegate().userProperty.setObject("Private Room", forKey: "uclClass" as NSCopying)
                mTitle = "Nice! What type of place is your private room in?"
            }
            else if indexPath.row == 3 {
                AppDelegate.returnAppDelegate().userProperty.setObject("Shared Room", forKey: "uclClass" as NSCopying)
                mTitle = "Nice! What type of place is your shared space in?"
            }
            AppDelegate.returnAppDelegate().userProperty.setObject("APT", forKey: "uclType" as NSCopying)
            if self.controller1 == nil {
                self.controller1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ucllocationVC") as? UCLLocationViewController
                controller?.hideBackButton = false
                controller?.hideSideButton = true
                self.controller1!.mainTitle = self.mainTitle
            }
            self.navigationController?.pushViewController(self.controller1!, animated: true)
        }
        else if self.listType == "type" {
            if indexPath.row == 1 {
                AppDelegate.returnAppDelegate().uclTitle = "Just a little more about your apartment..."
                self.mainTitle = "What city is your apartment located in?"
            }
            else if indexPath.row == 2 {
                AppDelegate.returnAppDelegate().uclTitle = "Just a little more about your house..."
                self.mainTitle = "What city is your house located in?"
            }
            else if indexPath.row == 3 {
                AppDelegate.returnAppDelegate().uclTitle = "Just a little more about your bed and breakfast..."
                self.mainTitle = "What city is your bed and breakfast located in?"
            }
            AppDelegate.returnAppDelegate().userProperty.setObject("APT", forKey: "uclType" as NSCopying)
            if self.controller1 == nil {
                self.controller1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ucllocationVC") as? UCLLocationViewController
                controller?.hideBackButton = false
                controller?.hideSideButton = true
                self.controller1!.mainTitle = self.mainTitle
            }
            self.navigationController?.pushViewController(self.controller1!, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
