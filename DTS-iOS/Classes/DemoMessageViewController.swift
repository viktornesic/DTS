//
//  DemoMessageViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 21/05/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

import KVNProgress

class DemoMessageViewController: BaseViewController {
    @IBOutlet weak var ivAcceptReject: UIImageView!
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDecline: UIButton!
    @IBOutlet weak var tvReply: UITextView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var ivProperty: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    var dictSelectedMessage: NSDictionary!
    var dictProperty: NSDictionary!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.returnAppDelegate().isBack = true
        
        self.populateFields()
        self.btnAccount.isHidden = true
        if UserDefaults.standard.object(forKey: "token") != nil {
            self.btnAccount.isHidden = false
            let revealController = revealViewController()
            
            self.btnAccount.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        }
        
        self.btnDecline.isHidden = false
        self.btnAccept.isHidden = false
        self.ivAcceptReject.isHidden = false
        self.btnAccept.isEnabled = true
        if dictSelectedMessage["accepted"] as! Int != 0 {
            //self.btnAccept.setTitle("Already accepted", forState: .Normal)
            self.btnDecline.isHidden = true
            self.btnAccept.isEnabled = false
            self.ivAcceptReject.isHidden = true
            
        }
        else if dictSelectedMessage["declined"] as! Int != 0 {
            //self.btnDecline.setTitle("Declined", forState: .Normal)
            self.btnAccept.isHidden = true
            self.btnDecline.isHidden = true
            self.ivAcceptReject.isHidden = true
        }
        
        let latitude = Double(dictProperty["latitude"] as! String)
        let longitude = Double(dictProperty["longitude"] as! String)
        
        let centerCoordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
        self.mapView.centerCoordinate = centerCoordinate
        let region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 500, 500)
        self.mapView.setRegion(region, animated: true)
        let finalImage = UIImage(named: "account-gear.png")
        
        
        let annotaion = PropertyAnnotation(coordinate: centerCoordinate, title: "", subtitle: "", img: finalImage!, withPropertyDictionary: dictSelectedMessage, andTag: 0, andPrice: nil, andType: "")
        self.mapView.addAnnotation(annotaion)
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(DemoMessageViewController.sendBack))
        swipeGesture.direction = .right
        self.view.addGestureRecognizer(swipeGesture)
    }
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func logoButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func sendBack() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAccount_Tapped(_ sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "accountVC") as! AccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func acceptMessage() -> Void {
        let msgID = String(dictSelectedMessage["id"] as! Int)
        
        
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/updatemsg?token=\(token)&msg_id=\(msgID)&action=accept")
        }
        
        KVNProgress.show(withStatus: "Accepting")
        
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


    @IBAction func btnAccept_Tapped(_ sender: AnyObject) {
        self.acceptMessage()
    }
    @IBAction func btnDecline_Tapped(_ sender: AnyObject) {
        self.declineMessage()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        self.lblMessage.text = dictSelectedMessage["content"] as? String
        let imgURL = (dictProperty["img_url"] as! NSDictionary)["sm"] as! String
        
        
        self.ivProperty.sd_setImage(with: URL(string: imgURL))
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "property"
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            
        }
        else {
            anView!.annotation = annotation
        }
        
        return anView
        
    }
    @IBAction func btnMap_Tapped(_ sender: AnyObject) {
        var address = dictProperty["address"] as! String
        address =  address.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: ("https://maps.apple.com/?address=\(address)"))
        UIApplication.shared.openURL(url!)
    }

    @IBAction func btnProperty_Tapped(_ sender: AnyObject) {
        AppDelegate.returnAppDelegate().isNewProperty = nil
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pDetailVC") as! PropertyDetailViewController
        controller.propertyID = String(dictProperty["id"] as! Int)
        self.navigationController?.pushViewController(controller, animated: true)
    }

}

extension DemoMessageViewController: MKMapViewDelegate {
    
}

