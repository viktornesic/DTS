//
//  UCLPreviewViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 29/11/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress
import GoogleMaps
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


class UCLPreviewViewController: UIViewController {
    
    @IBOutlet weak var btnSideMenu: UIButton!

    var reqType = 0
    
    var propertyID: String!
    var propertyImages: NSArray!
    @IBOutlet weak var tblDetail: UITableView!
    var isFromMainView: Bool?
    var amenities = ""
    var highlights = ""
    fileprivate let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    var driveDuration: String?
    var distance: String?
    var imgCount: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgCount = 0
        let revealController = revealViewController()
        //        revealController?.panGestureRecognizer()
        revealController?.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        
        
        if let revealController = revealViewController() {
            revealController.panGestureRecognizer().isEnabled = false
        }
        
        self.tblDetail.estimatedRowHeight = 10.0
        self.tblDetail.rowHeight = UITableViewAutomaticDimension
        
        self.getAddressFromCurrentLocation()
        
    }
    @IBAction func acceptButtonTapped(_ sender: AnyObject) {
        //imgCount = 0
        self.saveProperty()
//        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "disclosureVC") as! DisclosureViewController
//        controller.delegate = self
//        controller.propertyImages = self.propertyImages
//        present(controller, animated: true, completion: nil)
        
    }
    @IBAction func editButtonTapped(_ sender: AnyObject) {
        let controllerToGoBack = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3]
        self.navigationController?.popToViewController(controllerToGoBack!, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    @IBAction func backButton_Tapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension UCLPreviewViewController {
    
    func updateProperty(propertyId: String) -> Void {
        
        //KVNProgress.show()
        
        var token = ""
        
        var strURL = "\(APIConstants.BasePath)/api/savepropertyfield"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(strURL)?token=\(token)")
        }
        
        
        let relocation_target_price = AppDelegate.returnAppDelegate().userProperty["relocationTargetPrice"] as? String ?? ""
        let relocation_target_bed = AppDelegate.returnAppDelegate().userProperty["relocationTargetBed"] as? String ?? ""
        let relocation_target_bath = AppDelegate.returnAppDelegate().userProperty["relocationTargetBath"] as? String ?? ""
        
        
        let body: NSDictionary = ["property_id": propertyId,
                                  "data": [["field": "status", "value": "active"],
                                           ["field": "relocation_target_price", "value": relocation_target_price],
                                           ["field": "relocation_target_bed", "value": relocation_target_bed],
                                           ["field": "relocation_target_bath", "value": relocation_target_bath]
            ]
        ]
        
        
        
        
        //KVNProgress.show()
        
        do {
            let jsonParamsData = try JSONSerialization.data(withJSONObject: body, options: [])
            
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
                        
                        DispatchQueue.main.async(execute: {
                            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "disclosureVC") as! DisclosureViewController
                            self.navigationController?.pushViewController(controller, animated: true)
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
                return()
                }.resume()
        }
        catch {
            
        }
        
    }
    
    func saveProperty() -> Void {
        
        KVNProgress.show(withStatus: "Saving Property")
        
        var token = ""
        var strURL = "\(APIConstants.BasePath)/api/addproperty"
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(strURL)?token=\(token)")
        }
        
        //var uclClass = ""
        var uclType = ""
        //let uclGuests = ""
        var beds = ""
        var baths = ""
        var pTitle = ""
        var pPrice = ""
        var pDescription = ""
        
        //uclClass = AppDelegate.returnAppDelegate().userProperty["uclClass"] as! String
        uclType = AppDelegate.returnAppDelegate().userProperty["uclType"] as! String
        
        beds = AppDelegate.returnAppDelegate().userProperty["beds"] as! String
        baths = AppDelegate.returnAppDelegate().userProperty["baths"] as! String
        pTitle = AppDelegate.returnAppDelegate().userProperty["title"] as! String
        pPrice = AppDelegate.returnAppDelegate().userProperty["price"] as! String
        pDescription = AppDelegate.returnAppDelegate().userProperty["description"] as! String
        
        let address1 = AppDelegate.returnAppDelegate().userProperty["address1"] as! String
        let zip = AppDelegate.returnAppDelegate().userProperty["zip"] as! String
        let city = AppDelegate.returnAppDelegate().userProperty["city"] as! String
        let state = AppDelegate.returnAppDelegate().userProperty["state"] as! String
        let country = AppDelegate.returnAppDelegate().userProperty["country"] as! String
        let security = AppDelegate.returnAppDelegate().userProperty["securityDeposits"] as! String
        let rules = AppDelegate.returnAppDelegate().userProperty["rules"] as! String
        //lotSize
        let lotSize = AppDelegate.returnAppDelegate().userProperty["lotSize"] as? String ?? "500"
        let relocation_target_city = AppDelegate.returnAppDelegate().userProperty["relo_target_city"] as? String ?? ""
        let relocation_target_state = AppDelegate.returnAppDelegate().userProperty["relo_target_state"] as? String ?? ""
        let representedBy = AppDelegate.returnAppDelegate().userProperty["represented_by"] as? String ?? "no_agent"
        
        
        let body: NSDictionary = ["type": uclType,
                                  "title": pTitle,
                                  "listing_category": "rent",
                                  "description": pDescription,
                                  "status": "active",
                                  "year_built": "2016",
                                  "lot_size": lotSize,
                                  "lease_price": pPrice,
                                  "security_deposit": security,
                                  "details_rules": rules,
                                  "cat": 0,
                                  "dog": 0,
                                  "bed": beds,
                                  "bath": baths,
                                  "price": pPrice,
                                  "term": "month",
                                  "lease_term": "short",
                                  "address1": address1,
                                  "relocation_target_location_city": relocation_target_city,
                                  "relocation_target_location_state": relocation_target_state,
                                  "address2": "",
                                  "zip": zip,
                                  "city": city,
                                  "state_or_province": state,
                                  "country": country,
                                  "unit_amen_ac": 0,
                                  "unit_amen_parking_reserved": 0,
                                  "unit_amen_balcony": 0,
                                  "unit_amen_deck": 0,
                                  "unit_amen_ceiling_fan": 0,
                                  "unit_amen_dishwasher": 0,
                                  "unit_amen_fireplace": 0,
                                  "unit_amen_furnished": 0,
                                  "unit_amen_laundry": 0,
                                  "unit_amen_floor_carpet": 0,
                                  "unit_amen_floor_hard_wood": 0,
                                  "unit_amen_carpet": 0,
                                  "build_amen_fitness_center": 0,
                                  "build_amen_biz_center": 0,
                                  "build_amen_concierge": 0,
                                  "build_amen_doorman": 0,
                                  "build_amen_dry_cleaning": 0,
                                  "build_amen_elevator": 0,
                                  "build_amen_park_garage": 0,
                                  "build_amen_swim_pool": 0,
                                  "build_amen_secure_entry": 0,
                                  "build_amen_storage": 0,
                                  "keywords": "keyword1, keyword2",
                                  "represented_by": representedBy
        ]
        
        
        
        
       
        
        do {
            let jsonParamsData = try JSONSerialization.data(withJSONObject: body, options: [])
            
            let url = URL(string: strURL)
            var request = URLRequest(url: url!)
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            request.httpBody = jsonParamsData
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil {
                    do {
                        
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
                        
                        let propertyId = tempData!["data"] as! Int
                        let strPropertyId = String(propertyId)
                        AppDelegate.returnAppDelegate().newlyCreatedPropertyId = propertyId
                        
                        let dictParams = ["token": token, "property_id": strPropertyId]
                        
                        for img in self.propertyImages {
                            
                            let pImage = img as! UIImage
                            
                            self.uploadMultipartImage(pImage, dictParams: dictParams as NSDictionary)
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
                return()
                }.resume()
        }
        catch {
            
        }
        
    }
    
    func imageWithSize(_ image: UIImage, size:CGSize) -> UIImage
    {
        var scaledImageRect = CGRect.zero;
        
        let aspectWidth:CGFloat = size.width / image.size.width;
        let aspectHeight:CGFloat = size.height / image.size.height;
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight);
        
        scaledImageRect.size.width = image.size.width * aspectRatio;
        scaledImageRect.size.height = image.size.height * aspectRatio;
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0;
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0;
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        
        image.draw(in: scaledImageRect);
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return scaledImage!;
    }
    
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func uploadMultipartImage(_ image: UIImage, dictParams: NSDictionary) -> Void {
        let myUrl = URL(string: "\(APIConstants.BasePath)/api/addpropertyimg");
        //let myUrl = NSURL(string: "http://www.boredwear.com/utils/postImage.php");
        let resizedImage = self.resizeImage(image, newWidth: 1000)
        var request = URLRequest(url:myUrl!);
        request.httpMethod = "POST";
        
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let imageData = UIImageJPEGRepresentation(resizedImage, 0.75)
        
        if(imageData==nil)  { return; }
        
        request.httpBody = createBodyWithParameters(dictParams as? [String : String], filePathKey: "image", imageDataKey: imageData!, boundary: boundary)
        
        
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
//            DispatchQueue.main.async(execute: {
//                KVNProgress.show()
//            })
            
            if error != nil {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                    Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                })
                
                return
            }
            
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                let tempData = json as? NSDictionary
                
                if tempData!["error"] as? String != nil {
                
                    let error = tempData!["error"] as! String
                    let _utils = Utils()
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                        _utils.showOKAlert("Error:", message: error, controller: self, isActionRequired: false)
                    })
                    
                    return
                }
                
                let isSuccess = tempData!["success"] as! Bool
                
                if isSuccess == false {
                    
                    let _utils = Utils()
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                        _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                    })
                    
                    
                    return
                }
                
                self.imgCount = self.imgCount + 1
                
                if self.imgCount == self.propertyImages.count {
                    DispatchQueue.main.async(execute: {
                        //KVNProgress.dismiss()
                        
                        
                        self.updateProperty(propertyId: String(AppDelegate.returnAppDelegate().newlyCreatedPropertyId))
                        //                        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myDitchVC") as! MyDitchViewController
                        //                        self.navigationController?.pushViewController(controller, animated: true)
                    })
                }
                
                
                
            }catch
            {
                print(error)
            }
            
        })
        
        task.resume()
    }
    
    
    func createBodyWithParameters(_ parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        let body = NSMutableData()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "propertyFile.jpg"
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body as Data
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    
    func getAddressFromCurrentLocation() -> Void {
        
        //KVNProgress.show()
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                if let selectedCoordinates = AppDelegate.returnAppDelegate().selectedCoordinates {
                    let currentLocation = CLLocation(latitude: selectedCoordinates.latitude, longitude: selectedCoordinates.longitude)
                    Location.reverseGeocodeLocation(currentLocation, completion: { (placemark, error) in
                        if error != nil {
                            print("Reverse geocoder failed with error" + error!.localizedDescription)
                            DispatchQueue.main.async(execute: {
                                KVNProgress.dismiss()
                            })
                            return
                        }
                        
                        let currentAddress = ("\(placemark?.name ?? ""), \(placemark?.locality ?? ""), \(placemark?.country ?? "")")
                        if let destAddress = AppDelegate.returnAppDelegate().userProperty.object(forKey: "address1") {
                            self.getDriveDuration(currentAddress, destinationAddress: destAddress as! String)
                        }
                    })
                    
                }
            case .authorizedAlways, .authorizedWhenInUse:
                if let currentLocation = AppDelegate.returnAppDelegate().currentLocation {
                    Location.reverseGeocodeLocation(currentLocation, completion: { (placemark, error) in
                        if error != nil {
                            print("Reverse geocoder failed with error" + error!.localizedDescription)
                            DispatchQueue.main.async(execute: {
                                KVNProgress.dismiss()
                            })
                            return
                        }
                        
                        let currentAddress = ("\(placemark?.name ?? ""), \(placemark?.locality ?? ""), \(placemark?.country ?? "")")
                        if let destAddress = AppDelegate.returnAppDelegate().userProperty.object(forKey: "address1") {
                            self.getDriveDuration(currentAddress, destinationAddress: destAddress as! String)
                        }
                    })
                }
                else {
                    if let selectedCoordinates = AppDelegate.returnAppDelegate().selectedCoordinates {
                        let currentLocation = CLLocation(latitude: selectedCoordinates.latitude, longitude: selectedCoordinates.longitude)
                        Location.reverseGeocodeLocation(currentLocation, completion: { (placemark, error) in
                            if error != nil {
                                print("Reverse geocoder failed with error" + error!.localizedDescription)
                                DispatchQueue.main.async(execute: {
                                    KVNProgress.dismiss()
                                })
                                return
                            }
                            
                            let currentAddress = ("\(placemark?.name ?? ""), \(placemark?.locality ?? ""), \(placemark?.country ?? "")")
                            if let destAddress = AppDelegate.returnAppDelegate().userProperty.object(forKey: "address1") {
                                self.getDriveDuration(currentAddress, destinationAddress: destAddress as! String)
                            }
                        })
                        
                    }
                }
            }
        } else {
            //print("Location services are not enabled")
            if let selectedCoordinates = AppDelegate.returnAppDelegate().selectedCoordinates {
                let currentLocation = CLLocation(latitude: selectedCoordinates.latitude, longitude: selectedCoordinates.longitude)
                Location.reverseGeocodeLocation(currentLocation, completion: { (placemark, error) in
                    if error != nil {
                        print("Reverse geocoder failed with error" + error!.localizedDescription)
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                        })
                        return
                    }
                    
                    let currentAddress = ("\(placemark?.name ?? ""), \(placemark?.locality ?? ""), \(placemark?.country ?? "")")
                    if let destAddress = AppDelegate.returnAppDelegate().userProperty.object(forKey: "address1") {
                        self.getDriveDuration(currentAddress, destinationAddress: destAddress as! String)
                    }
                })

            }
        }
        
    }
    
    func getFormattedAddress(_ address: String) -> String {
        let addressToReturn = address.replacingOccurrences(of: ", ", with: ",").replacingOccurrences(of: " ", with: "+")
        return addressToReturn
    }
    
    func getDriveDuration(_ currentAddress: String, destinationAddress: String) -> Void {
        
        let formattedCurrentAddress = getFormattedAddress(currentAddress)
        let formattedDesitationAddress = getFormattedAddress(destinationAddress)
        let strURL = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\(formattedCurrentAddress)&destinations=\(formattedDesitationAddress)&key=\(googleMapsKey)"
        
        //        let formattedURL = strURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.whitespaceCharacterSet())
        
        if let url = URL(string: strURL) {
            let request = URLRequest(url: url)
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil {
                    do {
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                        })
                        let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                        
                        if let rows = json["rows"] as? NSArray {
                            if rows.count > 0 {
                                if let dictElements = rows[0] as? NSDictionary {
                                    if let elements = dictElements["elements"] as? NSArray {
                                        if let geoElement = elements[0] as? NSDictionary {
                                            if let status = geoElement["status"] as? String {
                                                if status == "OK" {
                                                    if let duration = geoElement["duration"] as? NSDictionary {
                                                        self.driveDuration = duration["text"] as? String
                                                        
                                                        DispatchQueue.main.async(execute: {
                                                            let cell = self.tblDetail.cellForRow(at: IndexPath(row: 0, section: 0)) as! DetailTableViewCell
                                                            if self.driveDuration != nil {
                                                                cell.lblDuration.text = self.driveDuration
                                                                //                                                            cell.lblDuration.text = "1 day 16 hours"
                                                                
                                                            }
                                                            //self.tblDetail.reloadData()
                                                        })
                                                        
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        print("worked")
                        
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
}

extension UCLPreviewViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.propertyImages.count > 0 {
            return self.propertyImages.count + 3
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailTableViewCell
            cell.isUCLPreview = true
            cell.bgImages = self.propertyImages as [AnyObject]
            cell.viewCounter.layer.cornerRadius = 6
            cell.viewCounter.clipsToBounds = true
            
            let lat = AppDelegate.returnAppDelegate().userProperty.object(forKey: "propertyLatitude") as! Double
            let long = AppDelegate.returnAppDelegate().userProperty.object(forKey: "propertyLongitude") as! Double
            debugPrint("Lat: \(lat), Long: \(long)")
            cell.lat = lat
            cell.long = long
            
            cell.showMap()
            
            let x = cell.cvBG.contentOffset.x
            let w = cell.cvBG.bounds.size.width
            let currentPage = Int(ceil(x/w))
            print("Current Page: \(currentPage)")
            cell.lblCounter.text = ("\(currentPage + 1)/\(cell.bgImages.count)")
            
            if let price = AppDelegate.returnAppDelegate().userProperty.object(forKey: "price") {
                cell.lblprice.text = ("$\(price)/month")
            }
            
            var secDeposit = "0"
            
            
            if let securityDepost = AppDelegate.returnAppDelegate().userProperty.object(forKey: "securityDeposits") as? String {
                secDeposit = securityDepost
                
            }
            
            
            
            cell.lblSecurityDeposit.text = "$\(secDeposit)"
            //cell.lblMoveInCost.isHidden = true
            
            if let address = AppDelegate.returnAppDelegate().userProperty.object(forKey: "address1") {
                cell.lblAddress.text = address as? String
            }
            var addressSecondLine = ""
            if let city = AppDelegate.returnAppDelegate().userProperty.object(forKey: "city") as? String {
                addressSecondLine.append(city)
            }
            
            if let state = AppDelegate.returnAppDelegate().userProperty.object(forKey: "state") as? String {
                addressSecondLine.append(", \(state)")
            }
            
            if let zip = AppDelegate.returnAppDelegate().userProperty.object(forKey: "zip") as? String {
                addressSecondLine.append(" \(zip)")
            }
            
            cell.lblAddressLine2.text = addressSecondLine
            
            let intBath = Int(AppDelegate.returnAppDelegate().userProperty.object(forKey: "baths") as! String)
            let intBeds = Int(AppDelegate.returnAppDelegate().userProperty.object(forKey: "beds") as! String)
            let bath = AppDelegate.returnAppDelegate().userProperty.object(forKey: "baths") as! String
            let bed = AppDelegate.returnAppDelegate().userProperty.object(forKey: "beds") as! String
            
    
            if intBeds > 1 {
                cell.lblBeds.text = ("\(bed)")
                cell.lblBedCaption.text = "Bed Rooms";
            }
            else {
                cell.lblBeds.text = ("\(bed)")
                cell.lblBedCaption.text = "Bed Room";
            }
            
            if intBath > 1 {
                cell.lblBaths.text = ("\(bath)")
                cell.lblBathCaption.text = "Bath Rooms"
            }
            else {
                cell.lblBaths.text = ("\(bath)")
                cell.lblBathCaption.text = "Bath Room"
            }
            
            cell.lblSize.text = "N/A"
            if let lotSize = AppDelegate.returnAppDelegate().userProperty.object(forKey: "lotSize") as? String {
                cell.lblSize.text = lotSize
            }
            cell.selectionStyle = .none
            return cell
    
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StreetTableViewCell", for: indexPath) as! StreetTableViewCell
            let lat = AppDelegate.returnAppDelegate().userProperty.object(forKey: "propertyLatitude") as! Double
            let long = AppDelegate.returnAppDelegate().userProperty.object(forKey: "propertyLongitude") as! Double
            debugPrint("Lat: \(lat), Long: \(long)")
            cell.lat = lat
            cell.long = long
            cell.showStreeView()
            cell.fullScreenButton.addTarget(self, action: #selector(PropertyDetailViewController.goStreetView(_:)), for: UIControlEvents.touchUpInside)
            
            return cell
        }
        else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescriptionTableViewCell
            cell.lblTitle.text = AppDelegate.returnAppDelegate().userProperty.object(forKey: "title") as? String
            cell.lblDescription.text = AppDelegate.returnAppDelegate().userProperty.object(forKey: "description") as? String
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "propertyCell", for: indexPath) as! PropertyDetailTableViewCell
        
            cell.ivBG.image = self.propertyImages[indexPath.row - 3] as? UIImage
            
            cell.ivBG.contentMode = .scaleAspectFill
            cell.ivBG.clipsToBounds = true
            cell.selectionStyle = .none
            return cell
        }
    }
}

extension UCLPreviewViewController: DisclosureViewControllerDelegate {
    func didCancelTapped() {
        
    }
    
    func didAgreeTappedAfterSavingProperty() {
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
        
    }
    
    func didAgreeTapped() {
        imgCount = 0
        self.saveProperty()
    }
}
