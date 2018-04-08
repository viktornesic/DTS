//
//  UCLPhotosViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 14/07/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

import KVNProgress

class UCLPhotosViewController: BaseViewController, UINavigationControllerDelegate {
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var lblPriceCaption: UILabel!
    @IBOutlet weak var constraintPriceTop: NSLayoutConstraint!
    @IBOutlet weak var constraintTitleTop: NSLayoutConstraint!
    @IBOutlet weak var constraintCVHeight: NSLayoutConstraint!
    @IBOutlet weak var viewCounter: UIView!
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var mainScroll: UIScrollView!
    @IBOutlet weak var clvPhotos: UICollectionView!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtTitle: UITextField!
    var pID: Int!
    var photoIds: NSMutableArray!
    
    var tmpImg: UIImage!
    var imgCount: Int!

    var pPropertyId: Int!
    
    var descriptionController: UCLDescriptionViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.screenType == .iPhone4 {
            self.constraintCVHeight.constant = 100
            self.constraintTitleTop.constant = 10
            self.constraintPriceTop.constant = 10
        }
        
        let revealController = revealViewController()
//        revealController?.panGestureRecognizer()
//        revealController?.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        self.pPropertyId = 0
        imgCount = 0
        pID = 0
        clvPhotos.backgroundColor = UIColor.clear
        clvPhotos.dataSource = self
        clvPhotos.delegate = self
        
        
        self.txtTitle.delegate = self
        photoIds = NSMutableArray()
        
        self.txtPrice.keyboardType = .numberPad
        self.txtPrice.delegate = self
        let frameView = CGRect(x: 0, y: 0, width: 45, height: 40)
        let viewLeft = UIView(frame: frameView)
        let lblFrame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let lblCurrencySign = UILabel(frame: lblFrame)
        lblCurrencySign.text = "$"
        lblCurrencySign.backgroundColor = UIColor(hexString: "f1f1f1")
        lblCurrencySign.textAlignment = .center
        viewLeft.addSubview(lblCurrencySign)
        self.txtPrice.leftView = viewLeft
        self.txtPrice.leftViewMode = .always
        
        self.txtPrice.layer.cornerRadius = 4
        self.txtPrice.layer.borderColor = UIColor(hexString: "d2d2d2").cgColor
        self.txtPrice.layer.borderWidth = 1
        self.addDoneButtonOnKeyboard(self.txtPrice)
        
        self.txtPrice.tag = 100
        
        let titleLeftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 40))
        self.txtTitle.leftView = titleLeftView
        self.txtTitle.leftViewMode = .always
        self.txtTitle.layer.cornerRadius = 4
        self.txtTitle.layer.borderColor = UIColor(hexString: "d2d2d2").cgColor
        self.txtTitle.layer.borderWidth = 1
        
        self.txtDescription.layer.cornerRadius = 6
        self.txtDescription.layer.borderColor = UIColor(hexString: "d2d2d2").cgColor
        self.txtDescription.layer.borderWidth = 1
//        self.addDoneButtonOnKeyboard(self.txtDescription)
        self.addNextButtonOnKeyboard(self.txtDescription)
        
        self.lblCounter.text = ("0/0")
        
        self.lblPriceCaption.isHidden = false
        self.txtPrice.isHidden = false
        
        if AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Relocating" || AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Ditching" {
            self.lblPriceCaption.isHidden = true
            self.txtPrice.isHidden = true
            self.txtTitle.returnKeyType = .default
        }
        
//        self.progressHud = MBProgressHUD(forView: self.view)
//        self.progressHud.mode = .DeterminateHorizontalBar
//        self.view.addSubview(self.progressHud)
    }
    
    func addNextButtonOnKeyboard(_ view: UIView?)
    {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(btnNextTapped(_:)))
        let items = [flexSpace, done]
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        if let accessorizedView = view as? UITextView {
            accessorizedView.inputAccessoryView = doneToolbar
            accessorizedView.inputAccessoryView = doneToolbar
        } else if let accessorizedView = view as? UITextField {
            accessorizedView.inputAccessoryView = doneToolbar
            accessorizedView.inputAccessoryView = doneToolbar
        }
        
    }
    
    func btnNextTapped(_ sender: AnyObject) {
        self.txtPrice.becomeFirstResponder()
    }
    
    func addDoneButtonOnKeyboard(_ view: UIView?)
    {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: view, action: #selector(UIResponder.resignFirstResponder))
        let items = [flexSpace, done]
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        if let accessorizedView = view as? UITextView {
            accessorizedView.inputAccessoryView = doneToolbar
            accessorizedView.inputAccessoryView = doneToolbar
        } else if let accessorizedView = view as? UITextField {
            accessorizedView.inputAccessoryView = doneToolbar
            accessorizedView.inputAccessoryView = doneToolbar
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnPreview_Tapped(_ sender: AnyObject) {
        
        if Utils.isTextFieldEmpty(self.txtTitle) == true {
            Utils.showOKAlertRO("", message: "Title is required.", controller: self)
            return
        }
        
        if AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Renting Out" {
            if Utils.isTextFieldEmpty(self.txtPrice) == true {
                Utils.showOKAlertRO("", message: "Price is required.", controller: self)
                return
            }
            
            AppDelegate.returnAppDelegate().userProperty.setObject(self.txtPrice.text!, forKey: "price" as NSCopying)
        }
        
        
        if self.photoIds.count == 0 {
            Utils.showOKAlertRO("", message: "At-least one image is required.", controller: self)
            return
        }
        
        AppDelegate.returnAppDelegate().userProperty.setObject(self.txtTitle.text!, forKey: "title" as NSCopying)
        
        imgCount = 0
        let allPhotos = NSArray.init(array: self.photoIds)
        AppDelegate.returnAppDelegate().userProperty.setObject(allPhotos, forKey: "propertyImages" as NSCopying)
        
        if self.descriptionController == nil {
            self.descriptionController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "uclDescriptionVC") as? UCLDescriptionViewController
        }
        self.navigationController?.pushViewController(self.descriptionController!, animated: true)
        

    }
    
    func updateProperty() -> Void {
        
        KVNProgress.show(withStatus: "Updating Property")
        
        var token = ""
        var strURL = "\(APIConstants.BasePath)/api/savepropertyfield"
        
        
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
        
        //uclClass = AppDelegate.returnAppDelegate().userProperty["uclClass"] as! String
        uclType = AppDelegate.returnAppDelegate().userProperty["uclType"] as! String
        
        beds = AppDelegate.returnAppDelegate().userProperty["uclDetailBeds"] as! String
        baths = AppDelegate.returnAppDelegate().userProperty["uclDetailBaths"] as! String
        pTitle = self.txtTitle.text!
        pPrice = self.txtPrice.text!
        
        let address1 = AppDelegate.returnAppDelegate().userProperty["address1"] as! String
        let zip = AppDelegate.returnAppDelegate().userProperty["zip"] as! String
        let city = AppDelegate.returnAppDelegate().userProperty["city"] as! String
        let state = AppDelegate.returnAppDelegate().userProperty["state"] as! String
        let country = AppDelegate.returnAppDelegate().userProperty["country"] as! String
        
        let body: NSDictionary = [
            "property_id": AppDelegate.returnAppDelegate().newlyCreatedPropertyId,
            "data": [
                [
                    "field": "type",
                    "value": uclType
                ],
                [
                    "field": "title",
                    "value": pTitle
                ],
                [
                    "field": "description",
                    "value": self.txtDescription.text!
                ],
                [
                    "field": "bed",
                    "value": beds
                ],
                [
                    "field": "bath",
                    "value": baths
                ],
                [
                    "field": "price",
                    "value": pPrice
                ],
                [
                    "field": "address1",
                    "value": address1
                ],
                [
                    "field": "zip",
                    "value": zip
                ],
                [
                    "field": "city",
                    "value": city
                ],
                [
                    "field": "state_or_province",
                    "value": state
                ],
                [
                    "field": "country",
                    "value": country
                ]
            ]
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
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                        })
                        let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                        let tempData = json as? NSDictionary
                        
                        let isSuccess = tempData!["success"] as! Bool
                        
                        if isSuccess == false {
                            DispatchQueue.main.async(execute: {
                                KVNProgress.dismiss()
                            })
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        }
                        
                        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pDetailVC") as! PropertyDetailViewController
                        controller.propertyID = String(AppDelegate.returnAppDelegate().newlyCreatedPropertyId)
                        controller.propertyImages = self.photoIds
                        self.navigationController?.pushViewController(controller, animated: true)
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
        
        //uclClass = AppDelegate.returnAppDelegate().userProperty["uclClass"] as! String
        uclType = AppDelegate.returnAppDelegate().userProperty["uclType"] as! String
        
        beds = AppDelegate.returnAppDelegate().userProperty["uclDetailBeds"] as! String
        baths = AppDelegate.returnAppDelegate().userProperty["uclDetailBaths"] as! String
        pTitle = self.txtTitle.text!
        pPrice = self.txtPrice.text!
        
        let address1 = AppDelegate.returnAppDelegate().userProperty["address1"] as! String
        let zip = AppDelegate.returnAppDelegate().userProperty["zip"] as! String
        let city = AppDelegate.returnAppDelegate().userProperty["city"] as! String
        let state = AppDelegate.returnAppDelegate().userProperty["state"] as! String
        let country = AppDelegate.returnAppDelegate().userProperty["country"] as! String
        let lotSize = AppDelegate.returnAppDelegate().userProperty["lotSize"] as? String ?? "500"
//        let body: NSDictionary = ["type": uclType,
//                                  "title": pTitle,
//                                  "description": self.txtDescription.text,
//                                  "status": "active",
//                                  "year_built": "2016",
//                                  "lot_size": "560",
//                                  "cat": 0,
//                                  "dog": 0,
//                                  "bed": beds,
//                                  "bath": baths,
//                                  "price": pPrice,
//                                  "term": "month",
//                                  "address1": "1114 lexington ave",
//                                  "address2": "",
//                                  "zip": "10075",
//                                  "city": "New York",
//                                  "state_or_province": "NY",
//                                  "country": "USA",
//                                  "unit_amen_ac": 0,
//                                  "unit_amen_parking_reserved": 0,
//                                  "unit_amen_balcony": 0,
//                                  "unit_amen_deck": 0,
//                                  "unit_amen_ceiling_fan": 0,
//                                  "unit_amen_dishwasher": 0,
//                                  "unit_amen_fireplace": 0,
//                                  "unit_amen_furnished": 0,
//                                  "unit_amen_laundry": 0,
//                                  "unit_amen_floor_carpet": 0,
//                                  "unit_amen_floor_hard_wood": 0,
//                                  "unit_amen_carpet": 0,
//                                  "build_amen_fitness_center": 0,
//                                  "build_amen_biz_center": 0,
//                                  "build_amen_concierge": 0,
//                                  "build_amen_doorman": 0,
//                                  "build_amen_dry_cleaning": 0,
//                                  "build_amen_elevator": 0,
//                                  "build_amen_park_garage": 0,
//                                  "build_amen_swim_pool": 0,
//                                  "build_amen_secure_entry": 0,
//                                  "build_amen_storage": 0,
//                                  "keywords": "keyword1, keyword2"]
        
        let body: NSDictionary = ["type": uclType,
                                  "title": pTitle,
                                  "description": self.txtDescription.text,
                                  "status": "active",
                                  "year_built": "2016",
                                  "lot_size": lotSize,
                                  "cat": 0,
                                  "dog": 0,
                                  "bed": beds,
                                  "bath": baths,
                                  "price": pPrice,
                                  "term": "month",
                                  "lease_term": "short",
                                  "address1": address1,
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
                                  "keywords": "keyword1, keyword2"]
        
        

        
        
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
                    
                    let propertyId = tempData!["data"] as! Int
                    let strPropertyId = String(propertyId)
                    AppDelegate.returnAppDelegate().newlyCreatedPropertyId = propertyId
                    
                    let dictParams = ["token": token, "property_id": strPropertyId]
                    
                    for img in self.photoIds {
                        
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
                    })
                    Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                    
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
            
            DispatchQueue.main.async(execute: {
                KVNProgress.show(withStatus: "Saving Property")
            })
            
            if error != nil {
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
        
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                let tempData = json as? NSDictionary
                
                if tempData!["error"] as? String != nil {
                    let error = tempData!["error"] as! String
                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: error, controller: self, isActionRequired: false)
                    return
                }
                
                let isSuccess = tempData!["success"] as! Bool
                
                if isSuccess == false {

                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                    return
                }
                
                self.imgCount = self.imgCount + 1
                
                if self.imgCount == self.photoIds.count {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    AppDelegate.returnAppDelegate().userProperty.setObject(self.photoIds, forKey: "propertyImages" as NSCopying)
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
    
    


    
    @IBAction func btnAddPhoto_Tapped(_ sender: AnyObject) {
        _ = sender as! UIButton
        let actionSheet = UIAlertController(title: "Photo", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            self.takePhoto()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            self.openLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
            
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func takePhoto() -> Void{
        DispatchQueue.main.async(execute: {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
    }
    
    func openLibrary() -> Void{
        DispatchQueue.main.async(execute: {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
    }
}

extension UCLPhotosViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        self.tmpImg = image
//        let strPID = String(pID)
        photoIds.add(image)
//        Utils.saveImage(image, projectID: pID)
//        pID = pID + 1
        self.dismiss(animated: true) {
            if self.photoIds.count > 0 {
                let x = self.clvPhotos.contentOffset.x
                let w = self.clvPhotos.bounds.size.width
                let currentPage = Int(ceil(x/w))
                self.lblCounter.text = ("\(currentPage + 1)/\(self.photoIds.count)")
            }
            self.clvPhotos.reloadData()
        }
    }
    
}

extension UCLPhotosViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 100 {
            let currentCharacterCount = textField.text?.characters.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.characters.count - range.length
            return newLength <= 6
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if AppDelegate.returnAppDelegate().userProperty.object(forKey: "goal") as! String == "Renting Out" {
            if textField.tag == 0 {
                self.txtPrice.becomeFirstResponder()
                return false
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
}

extension UCLPhotosViewController: UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.photoIds.count > 0 {
            return self.photoIds.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        if self.photoIds.count > 0 {
            cell.ivPhoto.image = self.photoIds[indexPath.row] as? UIImage
        }
        cell.contentView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        self.lblCounter.text = ("0/0")
        if self.photoIds.count > 0 {
            let x = self.clvPhotos.contentOffset.x
            let w = self.clvPhotos.bounds.size.width
            let currentPage = Int(ceil(x/w))
            self.lblCounter.text = ("\(currentPage + 1)/\(self.photoIds.count)")
        }
    }
}

extension UCLPhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let actionSheet = UIAlertController(title: "Photo", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            self.takePhoto()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            self.openLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
            
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}

extension UCLPhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}

extension NSMutableData {
    
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
