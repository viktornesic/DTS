//
//  ValidatePinViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 28/09/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress

class ValidatePinViewController: UIViewController {

    @IBOutlet weak var txtPin: AKMaskField!
    var code: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.txtPin.setMask("{dddd}", withMaskTemplate: "####")
        self.txtPin.maskDelegate = self
        self.txtPin.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func validateButtonTapped(_ sender: Any) {
    }

}

extension ValidatePinViewController: AKMaskFieldDelegate {
    func maskFieldDidBeginEditing(_ maskField: AKMaskField) {
    }
    
    func maskField(_ maskField: AKMaskField, didChangedWithEvent event: AKMaskFieldEvent) {
        switch maskField.maskStatus {
        case .clear:
            break
        case .incomplete:
            break
        case .complete:
            let params = ["token": DTSConstants.Constants.guestToken, "code": self.code!, "validation_pin": self.txtPin.text!]
            self.getDitchInfoResults(params)
            
        }
    }
    
    func maskField(_ maskField: AKMaskField, didChangeCharactersInRange range: NSRange, replacementString string: String, withEvent event: AKMaskFieldEvent) {
    }
}

extension ValidatePinViewController {
    func getDitchInfoResults(_ dictParam: [String: String]) -> Void {
        KVNProgress.show()
        
        let strURL = "\(APIConstants.BasePath)/api/getditchinforesults?token=\(dictParam["token"]!)&code=\(dictParam["code"]!)&validation_pin=\(dictParam["validation_pin"]!)&paginated=0"
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
                        DispatchQueue.main.async(execute: {
                            self.txtPin.textColor = UIColor.green
                            self.txtPin.resignFirstResponder()
                            let dictResponse = dict!["data"] as! [String: AnyObject]
                            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ctaResponseVC") as! CTAResponseViewController
                            controller.dictResponse = dictResponse
                            self.navigationController?.pushViewController(controller, animated: true)
                        })
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            self.txtPin.textColor = UIColor.red
                            self.txtPin.shake()
                        })
                        
                    }
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
            }.resume()
        
        
    }

}

