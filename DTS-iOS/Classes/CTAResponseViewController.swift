//
//  CTAResponseViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 29/09/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit

class CTAResponseViewController: UIViewController {
    @IBOutlet weak var lblResponse: UILabel!
    @IBOutlet weak var tblReponse: UITableView!
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    
    var properties: [AnyObject] = []
    var dictResponse: [String: AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.properties = dictResponse["search_results"] as! [AnyObject]
        let htmlContent = dictResponse["html_content"] as! String
        do {
            let attributedString = try NSMutableAttributedString(data: htmlContent.data(using: String.Encoding.unicode)!, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType], documentAttributes: nil)
            self.lblResponse.attributedText = attributedString
        }
        catch (let ex) {
            print(ex.localizedDescription)
        }
        
        self.lblMessage.textColor = UIColor.black
        self.lblMessage.isHidden = false
        self.tblReponse.isHidden = true
        if self.properties.count > 0 {
            self.lblMessage.isHidden = true
            self.tblReponse.isHidden = false
            self.tblReponse.reloadData()
        }
    }

    @IBAction func exitButtonTapped(_ sender: Any) {
        if UserDefaults.standard.object(forKey: "token") != nil {
            let tabbarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabbarVC") as! UITabBarController
            AppDelegate.returnAppDelegate().window?.rootViewController = tabbarVC
        }
        else {
            let revealVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "revealVC") as! SWRevealViewController
            AppDelegate.returnAppDelegate().window?.rootViewController = revealVC
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

extension CTAResponseViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "propertyCell", for: indexPath) as! MessagesTableViewCell
        let dictProperty = self.properties[indexPath.row] as! NSDictionary
        
        cell.btnProperty.tag = indexPath.row
        cell.btnProperty.addTarget(self, action: #selector(MessagesViewController.btnProperty_Tapped(_:)), for: .touchUpInside)
        
        cell.btnAction.tag = indexPath.row
        cell.btnAction.addTarget(self, action: #selector(MessagesViewController.btnAction_Tapped(_:)), for: .touchUpInside)
        
        let imgURL = (dictProperty["img_url"] as! NSDictionary)["sm"] as! String
        
        let address1 = dictProperty["address1"] as! String
        let city = dictProperty["city"] as! String
        let state = dictProperty["state_or_province"] as! String
        let zip = dictProperty["zip"] as! String
        
        cell.lblAddress.text = address1
        cell.lblCountry.text = "\(city), \(state) \(zip)"
        
        cell.ivProperty.sd_setImage(with: URL(string: imgURL))
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
}

