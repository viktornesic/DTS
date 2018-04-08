//
//  ListingAgreementPreviewViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 04/10/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress

class ListingAgreementPreviewViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var btnSideMenu: UIButton!
    
    var pdfLink: String!
    var dictDoc: [String: AnyObject]!
    var listingAgreementDocIds: [AnyObject]!
    var docCount: Int!
    var propertyId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let revealController = revealViewController()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        KVNProgress.show()
        
        self.webView.isOpaque = false
        self.webView.backgroundColor = UIColor(hexString: "191919")
        
        let URL = NSURL(string: pdfLink)
        let request = NSURLRequest(url: URL! as URL)
        self.webView.delegate = self
        self.webView.loadRequest(request as URLRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    @IBAction func agreeButtonTapped(_ sender: Any) {
        docCount = 0
        self.signListingAgreement(docId: self.listingAgreementDocIds[self.docCount] as! String, propertyId: propertyId)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ListingAgreementPreviewViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        KVNProgress.show()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        KVNProgress.dismiss()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        KVNProgress.dismiss()
    }
}

extension ListingAgreementPreviewViewController {
    func signListingAgreement(docId: String, propertyId: String) {
        var strURL = ""
        
        
        
        DispatchQueue.main.async(execute: {
            KVNProgress.show()
        })
        
        let token = UserDefaults.standard.object(forKey: "token") as! String
        strURL = "\(APIConstants.BasePath)/api/signdocumentation"
        
        let url = URL(string: strURL)
        
        let targeted_cid = UserDefaults.standard.object(forKey: "userCID") as! String
        
        let strParams = "token=\(token)&documentation_id=\(docId)&target_property_id=\(propertyId)&target_user_cid=\(targeted_cid)"
        
        
        let paramData = strParams.data(using: String.Encoding.ascii, allowLossyConversion: true)!
        
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.httpBody = paramData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let tempData = json as? NSDictionary
                    
                    let isSuccess = tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        let _utils = Utils()
                        
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        return
                    }
                    
                    self.docCount = self.docCount + 1
                    if self.docCount < self.listingAgreementDocIds.count {
                        self.signListingAgreement(docId: self.listingAgreementDocIds[self.docCount] as! String, propertyId: propertyId)
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            //                            self.isSigned = true
                            //                            self.btnClickToSign.setTitle("Signed", for: .normal)
                            if AppDelegate.returnAppDelegate().dwollaCustomerStatus != nil {
                                
                                if AppDelegate.returnAppDelegate().paymentMethods.count > 0 {
                                    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myDitchVC") as! MyDitchViewController
                                    self.navigationController?.pushViewController(controller, animated: true)
                                }
                                else {
                                    let paymentMethodVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "paymentMethodsVC") as! PaymentMethodsViewController
                                    self.navigationController?.pushViewController(paymentMethodVC, animated: true)
                                }
                            }
                            else {
                                let paymentMethodVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FNViewController") as! FNViewController
                                paymentMethodVC.isFromDitch = true
                                self.navigationController?.pushViewController(paymentMethodVC, animated: true)
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



