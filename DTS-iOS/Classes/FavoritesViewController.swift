//
//  FavoritesViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 19/05/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit


import KVNProgress
import SDWebImage

class FavoritesViewController: BaseViewController {

    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var tblFavorites: UITableView!
    var isCurrentlyEditing: Bool = false
    var properties = NSMutableArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnAccount.isHidden = true
        if UserDefaults.standard.object(forKey: "token") != nil {
            self.btnAccount.isHidden = false
            let revealController = revealViewController()
//            revealController?.panGestureRecognizer()
            //revealController?.tapGestureRecognizer()
            
            self.btnAccount.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        }
        
        self.view.backgroundColor = UIColor(hexString: "191919")
        self.tblFavorites.backgroundColor = UIColor(hexString: "191919")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.lblMessage.isHidden = true
        self.tblFavorites.isHidden = true
        DispatchQueue.main.async(execute: {
            KVNProgress.show(withStatus: "Loading Favorites")
        })
        self.getFavoriteProperties()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func unLikeProperty(_ token: String, propertyId: String, forRow row: Int) -> Void {
        let strURL = ("\(APIConstants.BasePath)/api/likeproperty?token=\(token)&property_id=\(propertyId)")
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
                    self.getFavoriteProperties()
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
    
    func getFavoriteProperties() -> Void {
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getuserfav?token=\(token)&paginated=0&page=0")
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
                let dictFavs = (tempData!["data"] as! NSDictionary)["favs"] as! NSDictionary
                let dictHides = (tempData!["data"] as! NSDictionary)["hides"] as! NSDictionary
                self.properties = NSMutableArray()
                let tmpProperties = dictFavs["data"] as! NSArray
                let hiddenProperties = dictHides["data"] as! NSArray
                self.properties.addObjects(from: tmpProperties as [AnyObject])
                self.properties.addObjects(from: hiddenProperties as [AnyObject])
                    DispatchQueue.main.async(execute: {
                        if self.properties.count > 0 {
                            self.tblFavorites.isHidden = false
                            self.lblMessage.isHidden = true
                        }
                        else {
                            self.tblFavorites.isHidden = true
                            self.lblMessage.isHidden = false
                        }
                       self.tblFavorites.reloadData()
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
    
    @IBAction func btnProperty_Tapped(_ sender: AnyObject) {
        AppDelegate.returnAppDelegate().isNewProperty = nil
        let btn = sender as! UIButton
        let dictProperty = self.properties[btn.tag] as! NSDictionary
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pDetailVC") as! PropertyDetailViewController
        controller.propertyID = String(dictProperty["id"] as! Int)
        controller.dictProperty = dictProperty
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnAction_Tapped(_ sender: AnyObject) {
        if isCurrentlyEditing {
            return
        }
        let btn = sender as! UIButton
        let dictProperty = self.properties[btn.tag] as! NSDictionary
        var address = dictProperty["address"] as! String
        address =  address.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: ("https://maps.apple.com/?address=\(address)"))
        UIApplication.shared.openURL(url!)
    }
    
    @IBAction func btnAccount_Tapped(_ sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "accountVC") as! AccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath)
    {
        isCurrentlyEditing = true
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?)
    {
        isCurrentlyEditing = false
    }  
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "propertyCell", for: indexPath) as! MessagesTableViewCell
        let dictProperty = self.properties[indexPath.row] as! NSDictionary
        
        cell.lblSubject.text = dictProperty["date_liked_formatted"] as? String
        cell.btnProperty.tag = indexPath.row
        cell.btnProperty.addTarget(self, action: #selector(MessagesViewController.btnProperty_Tapped(_:)), for: .touchUpInside)
        
        cell.btnAction.tag = indexPath.row
        cell.btnAction.addTarget(self, action: #selector(MessagesViewController.btnAction_Tapped(_:)), for: .touchUpInside)
        
        
        cell.lblSubject.textColor = UIColor(hexString: "02ce37")
        
        
        //            cell.lblAddress.textAlignment = .Center
        let address1 = dictProperty["address1"] as! String
        let city = dictProperty["city"] as! String
        let state = dictProperty["state_or_province"] as! String
        let zip = dictProperty["zip"] as! String
        
        cell.lblAddress.text = address1
        cell.lblCountry.text = "\(city), \(state) \(zip)"
        
        let imgURL = (dictProperty["img_url"] as! NSDictionary)["sm"] as! String
        cell.ivProperty.sd_setImage(with: URL(string: imgURL))
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        let hidden = dictProperty["hidden"] as! Bool
        if hidden {
            cell.backgroundColor = UIColor.red
        }
        
        return cell
    }
    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        let (parent, isParentCell, actualPosition) = self.findParent(indexPath.row)
//        if isParentCell {
//            return false
//        }
//        return true
//    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteRowAction = UITableViewRowAction(style: .default, title: "UNFAV") { (action, indexpath) in
            let dictProperty = self.properties[indexPath.row] as! NSDictionary
            self.properties.removeObject(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            if UserDefaults.standard.object(forKey: "token") != nil {
                let token = UserDefaults.standard.object(forKey: "token") as! String
                self.unLikeProperty(token, propertyId: String(dictProperty["id"] as! Int), forRow: indexPath.row)
            }
        }
        
        let dictProperty = self.properties[indexPath.row] as! NSDictionary
        let hidden = dictProperty["hidden"] as! Bool
        if hidden {
            let hideRowAction = UITableViewRowAction(style: .default, title: "UNHIDE") { (action, indexpath) in
                if UserDefaults.standard.object(forKey: "token") != nil {
                    let token = UserDefaults.standard.object(forKey: "token") as! String
                    self.hideProperty(token, propertyId: String(dictProperty["id"] as! Int))
                }
            }
            
            hideRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
            
            return [hideRowAction]
        }
        else {
            let hideRowAction = UITableViewRowAction(style: .default, title: "HIDE") { (action, indexpath) in
                if UserDefaults.standard.object(forKey: "token") != nil {
                    let token = UserDefaults.standard.object(forKey: "token") as! String
                    self.hideProperty(token, propertyId: String(dictProperty["id"] as! Int))
                }
            }
            
            hideRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
            
            return [deleteRowAction, hideRowAction]
        }
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "UNFAV"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.tblFavorites.beginUpdates()
        if editingStyle == .delete {
            
            let dictProperty = self.properties[indexPath.row] as! NSDictionary
            self.properties.removeObject(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            if UserDefaults.standard.object(forKey: "token") != nil {
                let token = UserDefaults.standard.object(forKey: "token") as! String
                self.unLikeProperty(token, propertyId: String(dictProperty["id"] as! Int), forRow: indexPath.row)
            }
            
        }
        self.tblFavorites.endUpdates()
    }
    
}

extension FavoritesViewController {
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
                        self.getFavoriteProperties()
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
}



