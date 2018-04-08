//
//  TOSViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 20/10/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

import KVNProgress

class TOSViewController: BaseViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var btnSideMenu: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let revealController = revealViewController()
        revealController?.panGestureRecognizer()
        revealController?.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        self.view.backgroundColor = UIColor(hexString: "191919")
        self.webView.isOpaque = false
        self.webView.backgroundColor = UIColor(hexString: "191919")
        
        KVNProgress.show(withStatus: "Loading TOS")
        self.getTOS()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getTOS() -> Void {
        var strURL = "\(APIConstants.BasePath)/api/tos?token=\(DTSConstants.Constants.guestToken)"
        
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/tos?token=\(token)")
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
                    let dictData = json as? NSDictionary
                
                let isSuccess = dictData!["success"] as!Bool
                
                if isSuccess == false {
                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: dictData!["message"] as! String, controller: self, isActionRequired: false)
                    return
                }
                
                if let html = dictData!["data"] as? String {
                    let htmlWithArial = "<body bgcolor='#191919'><font face='Arial' color='white'>\(html)</font></body>"
                    self.webView.loadHTMLString(htmlWithArial, baseURL: nil)
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
