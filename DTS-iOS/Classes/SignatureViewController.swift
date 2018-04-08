//
//  SignatureViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 31/05/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

import KVNProgress
import SDWebImage

class SignatureViewController: BaseViewController {

    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnDecline: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var ivProperty: UIImageView!
    @IBOutlet weak var drawSignatureView: YPDrawSignatureView!
    @IBOutlet weak var viewSignatureContainer: UIView!
    var dictSelectedMessage: NSDictionary!
    var signedResponseDict: NSDictionary!
    var documentPath: URL!
    
    var dictProperty: NSDictionary!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewSignatureContainer.layer.cornerRadius = 6
        self.viewSignatureContainer.layer.borderColor = UIColor.gray.cgColor
        self.viewSignatureContainer.layer.borderWidth = 1
        self.viewSignatureContainer.clipsToBounds = true
        self.populateFields()
        self.drawSignatureView.strokeColor = UIColor.red
        self.btnAccount.isHidden = true
        if UserDefaults.standard.object(forKey: "token") != nil {
            self.btnAccount.isHidden = false
            let revealController = revealViewController()
            
            self.btnAccount.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        }
    }
    
    @IBAction func btnAccount_Tapped(_ sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "accountVC") as! AccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func writeImageToPath(_ fileName: String, data: Data) -> Void {
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
            let path = URL(fileURLWithPath: dir).appendingPathComponent(fileName)
            print(path)
            
            do {
                try data.write(to: path, options: .atomic)
            }
            catch {
            }
            
            
        }
    }
    
    func sendSignature(_ signImage: UIImage) -> Void {
        
        let imageData:Data = UIImagePNGRepresentation(signImage)!
        //self.writeImageToPath("temp.png", data: imageData)
        let strBase64:String = imageData.base64EncodedString(options: .endLineWithLineFeed)
        //let strBase64 = imageData.base64EncodedStringWithOptions(.EncodingEndLineWithLineFeed)
        
        var token = ""
        let strURL = "\(APIConstants.BasePath)/api/signdoc"
        //let recipientID = dictSelectedMessage["sender_id"] as! Double
        let docTemplateID = dictSelectedMessage["doc_template_id"] as! Double
        
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
        }
        

        var addr = getWiFiAddress()
        if addr == nil {
            addr = "119.152.216.151"
        }
        
        let paramDict = ["token": token, "doc_template_id": docTemplateID, "signature": strBase64, "ip": addr!] as [String : Any]
        KVNProgress.show(withStatus: "Signing Document")
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
                        
                        self.signedResponseDict = tempData!["data"] as! NSDictionary
                        DispatchQueue.main.async(execute: {
                            self.performSegue(withIdentifier: "signToDoc", sender: self)
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
            
                return ()
                }.resume()
            
        }
        catch {
        
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signToDoc" {
            let controller = segue.destination as! DocMessageViewController
            controller.dictSelectedMessage = self.dictSelectedMessage
            controller.dictSignedResponse = self.signedResponseDict
            controller.dictProperty = self.dictProperty
            controller.isFromSignature = true
        }
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

    @IBAction func btnDecline_Tapped(_ sender: AnyObject) {
        self.declineMessage()
    }

    @IBAction func btnContinue_Tapped(_ sender: AnyObject) {
        if let signatureImage = self.drawSignatureView.getSignature() {
            
            self.sendSignature(signatureImage)
            
            
        }
    }

    @IBAction func btnClear_Tapped(_ sender: AnyObject) {
        self.drawSignatureView.clearSignature()
    }
    
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                
                // Check for IPv4 or IPv6 interface:
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    // Check interface name:
                    if let name = String(validatingUTF8: (interface?.ifa_name)!), name == "en0" {
                        
                        // Convert interface address to a human readable string:
                        var addr = interface?.ifa_addr.pointee
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(&addr!, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }
    
    @IBAction func btnProperty_Tapped(_ sender: AnyObject) {
        AppDelegate.returnAppDelegate().isNewProperty = nil
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pDetailVC") as! PropertyDetailViewController
        controller.propertyID = String(dictProperty["id"] as! Int)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
