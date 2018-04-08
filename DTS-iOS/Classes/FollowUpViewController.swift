//
//  FollowUpViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 21/05/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

import KVNProgress
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class FollowUpViewController: BaseViewController {

    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var btnProperty: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tblFollowup: UITableView!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var ivProperty: UIImageView!
    var dictSelectedMessage: NSDictionary!
    var dictProperty: NSDictionary!
    
    var isInquired: Bool!
    var custView: CustomView!
    var allMessages = NSMutableArray()
    var refreshControl: UIRefreshControl!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.returnAppDelegate().isBack = true
        
        // Do any additional setup after loading the view.
        self.populateFields()
        self.btnAccount.isHidden = true
        if UserDefaults.standard.object(forKey: "token") != nil {
            self.btnAccount.isHidden = false
            let revealController = revealViewController()
            
            self.btnAccount.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        }
        allMessages.add(dictSelectedMessage)
    
        self.populateMessages()
        
        self.custView = CustomView(frame: UIScreen.main.bounds)
        self.custView.backgroundColor = UIColor.clear
        self.custView.becomeFirstResponder()
        self.custView.keyboardBarDelegate = self
        
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(FollowUpViewController.didTouchView))
        
        if dictSelectedMessage["type"] as! String != "inquire" {
            self.view.addSubview(self.custView)
            self.view.addGestureRecognizer(tapGestureRecogniser)
        }
        
        
        self.tblFollowup.estimatedRowHeight = 80
        self.tblFollowup.rowHeight = UITableViewAutomaticDimension
        
        self.view.bringSubview(toFront: self.headerView)
        self.view.bringSubview(toFront: self.btnProperty)
        self.view.bringSubview(toFront: self.tblFollowup)
        let scrollIndexPath = IndexPath(row: self.allMessages.count - 1, section: 0)
        self.tblFollowup.scrollToRow(at: scrollIndexPath, at: .bottom, animated: false)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(FollowUpViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        tblFollowup.addSubview(refreshControl)
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(FollowUpViewController.sendBack))
        swipeGesture.direction = .right
        self.view.addGestureRecognizer(swipeGesture)
        
        self.tabBarController?.tabBar.isHidden = true
        self.view.layoutIfNeeded()
        
    }
    
    func sendBack() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAccount_Tapped(_ sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "accountVC") as! AccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func populateMessages() -> Void {
        if (dictSelectedMessage["children"] as AnyObject).count > 0 {
            let childrenMessages = self.dictSelectedMessage["children"] as! NSArray
            for dict in childrenMessages {
                let dictChildMsg = dict as! NSDictionary
                allMessages.add(dictChildMsg)
                
                let grandChildrenMessags = dictChildMsg["children"] as! NSArray
                
                if grandChildrenMessags.count > 0 {
                    for dictG in grandChildrenMessags {
                        let dictGrandChildMsg = dictG as! NSDictionary
                        allMessages.add(dictGrandChildMsg)
                    }
                }
            }
        }
    }
    
    func refresh(_ sender:AnyObject) {
        self.getMessage()
    }
    
    func didTouchView() -> Void {
        self.custView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func getMessage() -> Void {
        var strURL = ""
        
        let msgId = dictSelectedMessage["id"] as! Int
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getmsg?token=\(token)&msg_id=\(msgId)&type=thread&paginated=0&page=1")
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
                
                let properties = (tempData!["data"] as! NSDictionary)["thread"] as! NSArray
                let msgs = (properties[0] as! NSDictionary)["msgs"] as! NSArray
                self.dictSelectedMessage = msgs[0] as! NSDictionary
                self.allMessages = NSMutableArray()
                self.allMessages.add(self.dictSelectedMessage)
                    
                    DispatchQueue.main.async(execute: {
                        self.populateMessages()
                        self.tblFollowup.reloadData()
                        let scrollIndexPath = IndexPath(row: self.allMessages.count - 1, section: 0)
                        self.tblFollowup.scrollToRow(at: scrollIndexPath, at: .bottom, animated: false)
                        self.refreshControl.endRefreshing()
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
    
    func SendMessage(_ text: String) -> Void {
        var token = ""
        let strURL = "\(APIConstants.BasePath)/api/sendmsg"
        let recipientID = dictSelectedMessage["sender_id"] as! Double
                let messageContent = text
        let messageID = dictSelectedMessage["id"] as! Double
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
        }
        
        let paramDict = ["token": token, "recipient_id": recipientID, "message": messageContent, "parent_msg_id": messageID] as [String : Any]
        KVNProgress.show(withStatus: "Sending Message")
        
        do {
            let jsonParamsData = try JSONSerialization.data(withJSONObject: paramDict, options: [])
            
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
                    let dictTemp = ["recipient_id": 1, "content": text, "updated_at_formatted": "1 seconds ago"] as [String : Any]
                    self.allMessages.add(dictTemp)
                        
                        DispatchQueue.main.async(execute: {
                            self.tblFollowup.reloadData()
                            let scrollIndexPath = IndexPath(row: self.allMessages.count - 1, section: 0)
                            self.tblFollowup.scrollToRow(at: scrollIndexPath, at: .bottom, animated: false)
                        })
                    
                    //                self.navigationController?.popViewControllerAnimated(true)
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
                return ()
            }.resume()
        }
        catch {
            
        }
        
        

    }
    
    @IBAction func btnProperty_Tapped(_ sender: AnyObject) {
        AppDelegate.returnAppDelegate().isNewProperty = nil
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pDetailVC") as! PropertyDetailViewController
        controller.propertyID = String(dictProperty["id"] as! Int)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func populateFields() -> Void {
//        self.lblSubject.text = dictSelectedMessage["subject"] as? String
        
        self.lblSubject.textColor = UIColor(hexString: "ff0500")
        if dictSelectedMessage["type"] as! String == "doc_sign" {
            self.lblSubject.text = "SIGN LEASE"
        }
        else if dictSelectedMessage["type"] as! String == "follow_up" {
            self.lblSubject.text = "FOLLOW UP"
            
        }
        else if dictSelectedMessage["type"] as! String == "demo" {
            self.lblSubject.text = "ON-SITE DEMO"
            
        }
        else if dictSelectedMessage["type"] as! String == "inquire" {
            self.lblSubject.text = "INQUIRED"
            self.lblSubject.textColor = UIColor(hexString: "02ce37")
            
        }
        else {
            self.lblSubject.text = (dictSelectedMessage["type"]! as AnyObject).uppercased
            
        }
        
        let address1 = dictProperty["address1"] as! String
        let city = dictProperty["city"] as! String
        let state = dictProperty["state_or_province"] as! String
        let zip = dictProperty["zip"] as! String
        
        self.lblAddress.text = address1
        self.lblCountry.text = "\(city), \(state) \(zip)"
        
        let imgURL = (dictProperty["img_url"] as! NSDictionary)["sm"] as! String
        self.ivProperty.sd_setImage(with: URL(string: imgURL))
    }
}


extension FollowUpViewController: KeyboardBarDelegate {
    func keyboardBar(_ keyboardBar: KeyboardBar!, sendText text: String!) {
        self.custView.becomeFirstResponder()
        self.SendMessage(text)
        keyboardBar.textView.text = ""
    }
}

extension FollowUpViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followCell", for: indexPath) as! FollowupTableViewCell
        let dictMessage = self.allMessages[indexPath.row] as! NSDictionary
        if let dictRecipient = dictMessage["recipient"] as? NSDictionary {
            if let cidRecipient = dictRecipient["cid"] as? String {
                if let userCid = UserDefaults.standard.object(forKey: "cid") as? String {
                    if cidRecipient == userCid {
                        cell.lblTitle.text = "BROKER SAID"
                        cell.lblTitle.textColor = UIColor(hexString: "02ce37")
                    }
                    else {
                        cell.lblTitle.text = "YOU SAID"
                        cell.lblTitle.textColor = UIColor(hexString: "ff0500")
                    }
                }
            }
        }

        cell.lblDuration.text = dictMessage["updated_at_formatted"] as? String
        cell.lblContent.text = dictMessage["content"] as? String
        cell.selectionStyle = .none
        return cell
    }
}
