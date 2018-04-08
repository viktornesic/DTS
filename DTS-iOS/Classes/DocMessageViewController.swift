//
//  DocMessageViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 21/05/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

import KVNProgress


class DocMessageViewController: BaseViewController {
    
    
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var wvBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnDecline: UIButton!
    @IBOutlet weak var btnSign: UIButton!
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var ivProperty: UIImageView!
    var dictSelectedMessage: NSDictionary!
    var isFromSignature: Bool!
    var documentPath: URL!
    
    var dictSignedResponse: NSDictionary!
    var dictProperty: NSDictionary!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppDelegate.returnAppDelegate().isBack = true
        
        self.populateFields()
        
        self.btnSign.isHidden = false
        self.btnDecline.isHidden = false
        self.wvBottomConstraint.constant = 87
        
        self.btnAccount.isHidden = true
        if UserDefaults.standard.object(forKey: "token") != nil {
            self.btnAccount.isHidden = false
            let revealController = revealViewController()
            
            self.btnAccount.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        }
        
        var senderCID = ""
        if let sender = dictSelectedMessage["sender"] as? [String: AnyObject] {
            senderCID = sender["cid"] as? String ?? ""
        }
        if dictSelectedMessage["declined"] as! Int != 0 || senderCID == UserDefaults.standard.object(forKey: "cid") as? String ?? "" {
            self.wvBottomConstraint.constant = 0
            self.btnSign.isHidden = true
            self.btnDecline.isHidden = true
            self.downloadDocument()
        }
        else if dictSelectedMessage["doc"] as? NSDictionary != nil {
            if (dictSelectedMessage["doc"] as! NSDictionary)["signed"] as! Int != 0 {
                self.wvBottomConstraint.constant = 0
                self.btnSign.isHidden = true
                self.btnDecline.isHidden = true
                self.downloadConfirmedSignedDocument()
            }
            else {
                if self.isFromSignature == true {
                    self.btnSign.setTitle("Confirm", for: UIControlState())
                    self.downloadSignedDoc()
                }
                else {
                    self.downloadDocument()
                }
            }
        }
        else {
            if self.isFromSignature == true {
                self.btnSign.setTitle("Confirm", for: UIControlState())
                self.downloadSignedDoc()
            }
            else {
                self.downloadDocument()
            }
        }
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(DocMessageViewController.sendBack))
        swipeGesture.direction = .right
        self.view.addGestureRecognizer(swipeGesture)
    }
    
    func sendBack() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAccount_Tapped(_ sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "accountVC") as! AccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func downloadConfirmedSignedDocument() -> Void {
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getdoccontent?token=\(token)&filename=\((self.dictSelectedMessage["doc"] as! NSDictionary)["filename"] as! String)&type=signed&title=\((self.dictSelectedMessage["doc_template"] as! NSDictionary)["title"] as! String)")
            strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }
        
        KVNProgress.show(withStatus: "Loading Document")
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                })
                let pdfData = data
                self.writeToPath("\((self.dictSelectedMessage["doc_template"] as! NSDictionary)["title"] as! String).pdf", data: pdfData!)
            }
            else {
                
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                })
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                
            }
        }.resume()
        
    }
    
    func populateFields() -> Void {
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
    
    func downloadSignedDoc() -> Void {
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getdoccontent?token=\(token)&filename=\(self.dictSignedResponse["filename"] as! String)&type=temp&title=x\(self.dictSignedResponse["title"] as! String)")
            strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }
        
        KVNProgress.show(withStatus: "Loading Document")
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                })
                let pdfData = data
                self.writeToPath("\((self.dictSelectedMessage["doc_template"] as! NSDictionary)["title"] as! String).pdf", data: pdfData!)
            }
            else {
                
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                })
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                
            }
        }.resume()
    }
    
    func downloadDocument() -> Void {
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getdoccontent?token=\(token)&filename=\((self.dictSelectedMessage["doc_template"] as! NSDictionary)["filename"] as! String)&type=template&title=\((self.dictSelectedMessage["doc_template"] as! NSDictionary)["title"] as! String)")
            strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }
        
        KVNProgress.show(withStatus: "Loading Document")
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                })
                let pdfData = data
                self.writeToPath("\((self.dictSelectedMessage["doc_template"] as! NSDictionary)["title"] as! String).pdf", data: pdfData!)
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
    
    func writeToPath(_ fileName: String, data: Data) -> Void {
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
            let path = URL(fileURLWithPath: dir).appendingPathComponent(fileName)
            print(path)
            
            do {
                try data.write(to: path, options: .atomic)
            }
            catch {
            }
            
            let request = URLRequest(url: path)
            self.webView.loadRequest(request)

        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "docToSign" {
            let signatureController = segue.destination as! SignatureViewController
            signatureController.dictSelectedMessage = self.dictSelectedMessage
            signatureController.dictProperty = self.dictProperty
        }
    }
    
    func confirmDocSignature() -> Void {
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            let docId = String(dictSignedResponse["id"] as! Int)
            let msgId = String(dictSelectedMessage["id"] as! Int)
            strURL = ("\(APIConstants.BasePath)/api/confirmdocsignature?token=\(token)&doc_id=\(docId)&msg_id=\(msgId)")
            strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }
        
        KVNProgress.show(withStatus: "Signing Document")
        
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
                    DispatchQueue.main.async(execute: {
                        self.navigationController!.popToRootViewController(animated: true)
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

    
    @IBAction func btnSIgnDoc_Tapped(_ sender: AnyObject) {
        if self.isFromSignature == false {
            self.performSegue(withIdentifier: "docToSign", sender: self)
        }
        else {
            self.confirmDocSignature()
        }
    }
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDecline_Tapped(_ sender: AnyObject) {
        self.declineMessage()
    }
    
    func declineMessage() -> Void {
        let msgID = String(dictSelectedMessage["id"] as! Int)
        
        
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/updatemsg?token=\(token)&msg_id=\(msgID)&action=decline")
        }
        
        KVNProgress.show(withStatus: "Declining")
        
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
                    DispatchQueue.main.async(execute: {
                        self.navigationController?.popViewController(animated: true)
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
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pDetailVC") as! PropertyDetailViewController
        controller.propertyID = String(dictProperty["id"] as! Int)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension DocMessageViewController: UIWebViewDelegate {
    
}
