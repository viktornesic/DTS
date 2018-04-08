//
//  PropertiesMapViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 15/04/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import MapKit
import KVNProgress
import SDWebImage

protocol MapPropertiesDelegate {
    func didListingButtonTappe(_ properties: NSMutableArray)
}

class PropertiesMapViewController: BaseViewController, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var cvConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var cvMapProperty: UICollectionView!
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var mapBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    var properties: NSMutableArray!
    var globalProperties: NSMutableArray!
    var dictProperty: NSDictionary!
    var searchController: SearchPropertiesViewController?
    
    var delegate: MapPropertiesDelegate?
    var swipeGesture: UISwipeGestureRecognizer!
    var annTag = 0
    var reqType = 2
    var selectedRow: Int?
    var originalURL = "\(APIConstants.BasePath)/api/getproperty?page=1"
    var mainData: NSDictionary?
    var nextURL: String?
    var isAnnotationTappedAlready: Bool!
    
    fileprivate var responseData:NSMutableData?
    fileprivate var dataTask:URLSessionDataTask?
    
    
    
    @IBAction func btnListing_Tapped(_ sender: AnyObject) {
        UIView.transition(with: (self.navigationController?.view)!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            if self.delegate != nil {
                self.delegate?.didListingButtonTappe(self.properties)
            }
            self.navigationController?.popToRootViewController(animated: false)
        }) { (completed: Bool) in
            
        }
    }
    
    func hideMap(_ gesture: AnyObject) -> Void {
        self.view.layoutIfNeeded()
        self.cvConstraintHeight.constant = 0
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isAnnotationTappedAlready = false
        self.swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideMap(_:)))
        swipeGesture.direction = .down
        self.cvMapProperty.addGestureRecognizer(self.swipeGesture)
        
        self.lblHeaderTitle.numberOfLines = 2
        cvConstraintHeight.constant = 0
        //self.btnNearMe.hidden = true
        
        let centerCoordinate = AppDelegate.returnAppDelegate().selectedCoordinates!
        
        print(AppDelegate.returnAppDelegate().selectedCoordinates!)
    
        
        if let savedRegion = UserDefaults.standard.object(forKey: "selectedRegion") as? String {
            
            AppDelegate.returnAppDelegate().selectedSearchRegion = savedRegion
            if let selectedRegion = AppDelegate.returnAppDelegate().selectedSearchRegion {
                if selectedRegion.characters.count > 0 {
                    var selectedRegionWithAbb = selectedRegion.replacingOccurrences(of: ", United States", with: "")
                    AppDelegate.returnAppDelegate().selectedZip = UserDefaults.standard.object(forKey: "selectedZip") as? String
                    if AppDelegate.returnAppDelegate().selectedZip != nil {
                        selectedRegionWithAbb = selectedRegionWithAbb.replacingOccurrences(of: AppDelegate.returnAppDelegate().selectedZip!, with: "\n\(AppDelegate.returnAppDelegate().selectedZip!)")
                        self.lblHeaderTitle.font = UIFont(name: "HelveticaNeue", size: 19)
                        let zipFont = UIFont(name: "HelveticaNeue", size: 14)
                        let title = NSMutableAttributedString(string: selectedRegionWithAbb)
                        title.setFontForText(AppDelegate.returnAppDelegate().selectedZip!, with: zipFont)
                        self.lblHeaderTitle.attributedText = title
                        
                    }
                    else {
                        self.lblHeaderTitle.text = selectedRegionWithAbb
                    }
                }
            }
            
        }

        
        
//        if let selectedRegion = AppDelegate.returnAppDelegate().selectedSearchRegion {
//            if selectedRegion.characters.count > 0 {
//                /**centerCoordinate = CLLocationCoordinate2DMake(NSUserDefaults.standardUserDefaults().doubleForKey("selectedLat"), NSUserDefaults.standardUserDefaults().doubleForKey("selectedLong"))*/
//                let selectedRegionWithAbb = selectedRegion.replacingOccurrences(of: ", United States", with: "")
//                self.btnNearMe.setTitle(selectedRegionWithAbb, for: UIControlState())
//                self.btnNearMe.isHidden = false
//            }
//        }
        self.mapView.centerCoordinate = centerCoordinate
        let region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 25000, 25000)
        self.mapView.setRegion(region, animated: true)
        self.btnAccount.isHidden = true
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            self.btnAccount.isHidden = false
            let revealController = revealViewController()
            revealController?.panGestureRecognizer().isEnabled = false
            revealController?.tapGestureRecognizer()
            self.btnAccount.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        }
        
        
        

        self.addAnnotationsToMap()
        self.cvMapProperty.reloadData()
        
    }
    
    func addAnnotationsToMap() -> Void {
        annTag = 0
        
        self.globalProperties = self.properties
        
        let tempProperties = self.properties.copy() as! NSArray
        let precidate = NSPredicate(format: "id.intValue > 0", argumentArray: nil)
        self.properties = (tempProperties.filtered(using: precidate) as NSArray).mutableCopy() as! NSMutableArray
        
        
        for dictTemp in properties {
            let dict = dictTemp as! NSDictionary
            let propertyId = dict["id"] as? Int ?? 0
            if propertyId != 0 {
                let latitude = Double(dict["latitude"] as! String)
                let longitude = Double(dict["longitude"] as! String)
                
                
                
                let coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                //let imgURL = dict["img_url"]!!["md"] as! String
                
                
                let price = String(dict["price"] as! Int)
                let bed = String(dict["bed"] as! Int)
                let subTitle = ("\(bed)BR $\(price)/\(dict["term"] as! String)")
                
                let priceNumber = NSNumber.init(value: dict["price"] as! Int as Int)
                let shortPrice = Utils.suffixNumber(priceNumber)
                
                let annotaion = PropertyAnnotation(coordinate: coordinate, title: dict["title"] as! String, subtitle: subTitle, img: nil, withPropertyDictionary: dict , andTag: self.annTag, andPrice: shortPrice as String, andType: dict["type"] as? String)
                self.annTag = self.annTag + 1
                print("property title: ")
                print("lat: \(annotaion.coordinate.latitude), long: \(annotaion.coordinate.longitude)")
                self.mapView.addAnnotation(annotaion)
            }
            
            /*SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgURL), options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
                
                let finalImage = self.ResizeImage(image, targetSize: CGSizeMake(50, 30))
                let price = String(dict["price"] as! Int)
                let bed = String(dict["bed"] as! Int)
                let subTitle = ("\(bed)BR $\(price)/\(dict["term"] as! String)")
                
                let priceNumber = NSNumber.init(integer: dict["price"] as! Int)
                let shortPrice = Utils.suffixNumber(priceNumber)
                
                let annotaion = PropertyAnnotation(coordinate: coordinate, title: dict["title"] as! String, subtitle: subTitle, img: finalImage, withPropertyDictionary: dict as! NSDictionary, andTag: self.annTag, andPrice: shortPrice as String, andType: dict["type"] as? String)
                self.annTag = self.annTag + 1
                print("property title: ")
                print("lat: \(annotaion.coordinate.latitude), long: \(annotaion.coordinate.longitude)")
                self.mapView.addAnnotation(annotaion)
            })*/
            
        }
    }

    func getProperties(_ strURL: String) -> Void {
        
        KVNProgress.show(withStatus: "Loading Properties")
        var strURL = "\(strURL)&token=\(DTSConstants.Constants.guestToken)&show_owned_only=0&show_active_only=1&latitude=\(AppDelegate.returnAppDelegate().selectedCoordinates!.latitude)&longitude=\(AppDelegate.returnAppDelegate().selectedCoordinates!.longitude)"
        
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(strURL)&token=\(token)&show_owned_only=0&show_active_only=1&latitude=\(AppDelegate.returnAppDelegate().selectedCoordinates!.latitude)&longitude=\(AppDelegate.returnAppDelegate().selectedCoordinates!.longitude)")
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
                if tempData != nil {
                    if tempData!["error"] as? String != nil {
                        let error = tempData!["error"] as! String
                        if error == "user_not_found" {
                            UserDefaults.standard.set(nil, forKey: "token")
                            AppDelegate.returnAppDelegate().logOut()
                            return
                        }
                    }
                }
                let isSuccess = tempData!["success"] as! Bool
                
                if isSuccess == false {
                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                    return
                }
                
                self.mainData = tempData!["data"] as? NSDictionary
                self.nextURL = self.mainData!["next_page_url"] as? String
                self.properties = (self.mainData!["data"] as? NSDictionary)?.mutableCopy() as! NSMutableArray
                
                    DispatchQueue.main.async(execute: {
                        self.view.layoutIfNeeded()
                        self.cvConstraintHeight.constant = 0
                        
                        UIView.animate(withDuration: 0.2, animations: {
                            self.view.layoutIfNeeded()
                        }) 
                        
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        
                        //self.addAnnotationsToMap()
                        self.cvMapProperty.reloadData()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - MapView
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let customAnnotation = annotation as! PropertyAnnotation
        let reuseId = "property"
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = false
//            anView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
            
        }
        else {
            //we are re-using a view, update its annotation reference...
            anView!.annotation = annotation
        }
        
        
        
//        anView?.addSubview(tempView)
        
        
        anView?.tag = customAnnotation.anTag
        anView?.image = getImageFromCustomView(customAnnotation.price!, withColor: "01c8ff", andType: customAnnotation.type!) //screenShot//?.imageWithAlpha(0.6)
//        anView?.image = customAnnotation.img
//        anView?.layer.borderWidth = 1
//        anView?.layer.borderColor = UIColor.whiteColor().CGColor
        return anView
 
    }
    
    func getImageFromCustomView(_ price: String, withColor color: String, andType type: String) -> UIImage? {
        var tempFrame = CGRect(x: 0, y: 0, width: 60, height: 60)
        let tempView = UIView(frame: tempFrame)
        
        tempView.layer.borderColor = UIColor(hexString: "7a7974").cgColor
        
        if price == "0" {
            tempView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
            tempFrame = CGRect(x: 0, y: 0, width: 60, height: 60)
            tempView.layer.cornerRadius = tempView.frame.size.width / 2
            tempView.layer.borderColor = UIColor.red.cgColor
        }
        else {
            tempView.layer.cornerRadius = tempView.frame.size.width / 2
        }

        //tempView.backgroundColor = UIColor(hexString: color)
        tempView.layer.borderWidth = 2
        
        tempView.clipsToBounds = true
        tempView.backgroundColor = UIColor.clear
        
        let middleView = UIView(frame: tempFrame)
        middleView.backgroundColor = UIColor(hexString: color)
        middleView.alpha = 0.6
        tempView.addSubview(middleView)
        
        
        let lblFrame = CGRect(x: 5, y: 5, width: 50, height: 50)
        let lblPrice = UILabel(frame: lblFrame)
        if price == "0" {
            lblPrice.frame = CGRect(x: 5, y: 5, width: 50, height: 50)
        }
        lblPrice.textAlignment = .center
        lblPrice.text = price
        if price == "0" {
            lblPrice.text = "911"
        }
        lblPrice.textColor = UIColor.white
        lblPrice.font = UIFont.boldSystemFont(ofSize: 17)
        tempView.addSubview(lblPrice)
        
        if type == "SUBLET" {
            let frameViewSub = CGRect(x: 15, y: 0, width: 30, height: 16)
            let viewSub = UIView(frame: frameViewSub)
            viewSub.backgroundColor = UIColor.green
            
            let lblSubFrame = CGRect(x: 0, y: 3, width: 30, height: 12)
            let lblSub = UILabel(frame: lblSubFrame)
            lblSub.font = UIFont.boldSystemFont(ofSize: 10)
            lblSub.textAlignment = .center
            lblSub.textColor = UIColor.white
            lblSub.backgroundColor = UIColor.clear
            lblSub.text = "SUB"
            viewSub.addSubview(lblSub)
            tempView.addSubview(viewSub)
        }
        
        //let tempSize = CGSizeMake(50, 50)
        
        //UIGraphicsBeginImageContext(tempView.bounds.size)
        UIGraphicsBeginImageContextWithOptions(tempView.bounds.size, false, 3)
        tempView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenShot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return screenShot
    }
    
//    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
//        if fullyRendered == true {
//            self.addAnnotationsToMap()
//        }
//    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        var indexPath = IndexPath(item: view.tag, section: 0)
        
        if self.isAnnotationTappedAlready == false {
            self.isAnnotationTappedAlready = true
            self.view.layoutIfNeeded()
            self.cvConstraintHeight.constant = 300
            
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            }) 
            //self.cvMapProperty.reloadData()
        }
        
        //view.image = getImageFromCustomView(customAnnotation.price!, withColor: "01c8ff")
        
        var selectedAnnotation: PropertyAnnotation?
        
        for i in 0..<mapView.annotations.count {
            let annotation = mapView.annotations[i] as! PropertyAnnotation
            if let annotationView = mapView.view(for: annotation) {
                annotationView.layer.borderColor = UIColor.white.cgColor
                annotationView.image = getImageFromCustomView(annotation.price!, withColor: "01c8ff", andType: annotation.type!)
                
            }
            if annotation.anTag == view.tag {
                view.image = self.getImageFromCustomView(annotation.price!, withColor: "ff0000", andType: annotation.type!)
                selectedAnnotation = annotation
            }
        }
        
        
        
        
//        let dictPropertyAnn = self.properties[view.tag] as! NSDictionary
        view.layer.borderColor = UIColor.red.cgColor
        
//        let annMTitle = dictPropertyAnn["title"] as! String
//        let annPrice = String(dictPropertyAnn["price"] as! Int)
//        let annTitle = ("$\(annPrice)/\(dictPropertyAnn["term"]!)")
        var index = 0
        for lTempDictProperty in self.properties {
            let lDictProperty = lTempDictProperty as! NSDictionary
            let price = String(lDictProperty["price"] as! Int)
            let bed = String(lDictProperty["bed"] as! Int)
            let title = ("\(bed)BR $\(price)/\(lDictProperty["term"] as! String)")
            let mTitle = lDictProperty["title"] as! String
            
            
            if title == selectedAnnotation?.subtitle! && mTitle == selectedAnnotation?.title {
                
                

                let selectedAnnotationCoordinate = selectedAnnotation!.coordinate
                self.mapView.setCenter(selectedAnnotationCoordinate, animated: true)
                
                
                indexPath = IndexPath(item: index, section: 0)
                self.cvMapProperty.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                
                self.view.layoutIfNeeded()
                self.cvConstraintHeight.constant = 300
            
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.layoutIfNeeded()
                }) 
            }
            
            index += 1
        }
        
    }
    
    func ResizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let customAnnotation = view.annotation as! PropertyAnnotation
        self.dictProperty = customAnnotation.dictProperty
        self.performSegue(withIdentifier: "mapToDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToSignup" {
            let controller = segue.destination as! SignUpViewController
            controller.propertyId = String(dictProperty["id"] as! Int)
            controller.reqType = reqType
            //controller.delegate = self
        }
        else {
            let controller = segue.destination as! PropertyDetailViewController
            controller.propertyID = String(dictProperty["id"] as! Int)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func btnAccount_Tapped(_ sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "accountVC") as! AccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
    

    
    @IBAction func btnSearch_Tapped(_ sender: AnyObject) {
        
        //        if searchController == nil {
        //            searchController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("searchPropertiesVC") as? SearchPropertiesViewController
        //            searchController?.delegate = self
        //            searchController?.isPropertySearch = true
        //        }
        
        
        searchController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "searchPropertiesVC") as? SearchPropertiesViewController
        searchController?.delegate = self
        searchController?.isPropertySearch = true
        self.navigationController?.present(searchController!, animated: true, completion: nil)
        //        self.performSegueWithIdentifier("propertiesVCToSearchProperties", sender: self)
    }
    
    func createAgentSearch() -> Void {
        
        if let selectedRegion = AppDelegate.returnAppDelegate().selectedSearchRegion {
            if selectedRegion.characters.count > 0 {
                var selectedRegionWithAbb = selectedRegion.replacingOccurrences(of: ", United States", with: "")
                if AppDelegate.returnAppDelegate().selectedZip != nil {
                    selectedRegionWithAbb = selectedRegionWithAbb.replacingOccurrences(of: AppDelegate.returnAppDelegate().selectedZip!, with: "\n\(AppDelegate.returnAppDelegate().selectedZip!)")
                    self.lblHeaderTitle.font = UIFont(name: "HelveticaNeue", size: 19)
                    let zipFont = UIFont(name: "HelveticaNeue", size: 14)
                    let title = NSMutableAttributedString(string: selectedRegionWithAbb)
                    title.setFontForText(AppDelegate.returnAppDelegate().selectedZip!, with: zipFont)
                    self.lblHeaderTitle.attributedText = title
                    
                }
                else {
                    self.lblHeaderTitle.text = selectedRegionWithAbb
                }
            }
        }

        
//        if let selectedRegion = AppDelegate.returnAppDelegate().selectedSearchRegion {
//            if selectedRegion.characters.count > 0 {
//                let selectedRegionWithAbb = selectedRegion.replacingOccurrences(of: ", United States", with: "")
//                self.btnNearMe.setTitle(selectedRegionWithAbb, for: UIControlState())
//                self.btnNearMe.isHidden = false
//            }
//        }
        
        var strURL = "\(APIConstants.BasePath)/api/createusersearch?token=\(DTSConstants.Constants.guestToken)&create_search_agent=1"
        
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/createusersearch?token=\(token)&create_search_agent=1")
        }
        
//        let dictAgentOptions = NSUserDefaults.standardUserDefaults().objectForKey("agentOptions") as! NSDictionary
        
        let body: NSDictionary = [
//            "schedule": dictAgentOptions,
            "criteria": AppDelegate.returnAppDelegate().arrSearchCriteria
        ]
        
        KVNProgress.show(withStatus: "Searching Properties")
        
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
                    if tempData != nil {
                        if tempData!["error"] as? String != nil {
                            let error = tempData!["error"] as! String
                            if error == "user_not_found" {
                                UserDefaults.standard.set(nil, forKey: "token")
                                AppDelegate.returnAppDelegate().logOut()
                                return
                            }
                        }
                    }
                    let isSuccess = tempData!["success"] as! Bool
                    
                        if isSuccess == false {
                            
                            DispatchQueue.main.async(execute: {
                                KVNProgress.dismiss()
                                let _utils = Utils()
                                _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            })
                            
                            return
                        }
                    
                    
                    self.properties = NSMutableArray()
                    self.getUserSearchByData(tempData!["data"] as! String)
                        
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
    
    func createUserSearch() -> Void {
        
        if let selectedRegion = AppDelegate.returnAppDelegate().selectedSearchRegion {
            if selectedRegion.characters.count > 0 {
                var selectedRegionWithAbb = selectedRegion.replacingOccurrences(of: ", United States", with: "")
                if AppDelegate.returnAppDelegate().selectedZip != nil {
                    selectedRegionWithAbb = selectedRegionWithAbb.replacingOccurrences(of: AppDelegate.returnAppDelegate().selectedZip!, with: "\n\(AppDelegate.returnAppDelegate().selectedZip!)")
                    self.lblHeaderTitle.font = UIFont(name: "HelveticaNeue", size: 19)
                    let zipFont = UIFont(name: "HelveticaNeue", size: 14)
                    let title = NSMutableAttributedString(string: selectedRegionWithAbb)
                    title.setFontForText(AppDelegate.returnAppDelegate().selectedZip!, with: zipFont)
                    self.lblHeaderTitle.attributedText = title
                    
                }
                else {
                    self.lblHeaderTitle.text = selectedRegionWithAbb
                }
            }
        }

        
//        if let selectedRegion = AppDelegate.returnAppDelegate().selectedSearchRegion {
//
//            if selectedRegion.characters.count > 0 {
//                let selectedRegionWithAbb = selectedRegion.replacingOccurrences(of: ", United States", with: "")
//                self.btnNearMe.setTitle(selectedRegionWithAbb, for: UIControlState())
//                self.btnNearMe.isHidden = false
//
//            }
//        }
        
        var strURL = "\(APIConstants.BasePath)/api/createusersearch?token=\(DTSConstants.Constants.guestToken)&create_search_agent=0"
        
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/createusersearch?token=\(token)&create_search_agent=0")
        }
        
        let body: NSDictionary = [
            "criteria": AppDelegate.returnAppDelegate().arrSearchCriteria
        ]
        
        
        
        KVNProgress.show(withStatus: "Searching Properties")
        
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
                        if tempData != nil {
                            if tempData!["error"] as? String != nil {
                                let error = tempData!["error"] as! String
                                if error == "user_not_found" {
                                    UserDefaults.standard.set(nil, forKey: "token")
                                    AppDelegate.returnAppDelegate().logOut()
                                    return
                                }
                            }
                        }
                        let isSuccess = tempData!["success"] as! Bool
                        
                        if isSuccess == false {
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        }
                        
                        
                        self.properties = NSMutableArray()
                        self.getUserSearchByData(tempData!["data"] as! String)
                        
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
    
    func getUserSearchByData(_ data: String) -> Void {
        var strURL = "\(APIConstants.BasePath)/api/getsearchresults?token=\(DTSConstants.Constants.guestToken)&type=user_searches&search_agent=0&key=\(data)&from_date=2016-01-01%2000%3A00%3A00&to_date=2018-01-01%2023%3A59%3A59"
        
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getsearchresults?token=\(token)&type=user_searches&search_agent=0&key=\(data)&from_date=2016-01-01%2000%3A00%3A00&to_date=2018-01-01%2023%3A59%3A59")
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
                if tempData != nil {
                    if tempData!["error"] as? String != nil {
                        let error = tempData!["error"] as! String
                        if error == "user_not_found" {
                            UserDefaults.standard.set(nil, forKey: "token")
                            AppDelegate.returnAppDelegate().logOut()
                            return
                        }
                    }
                }
                let isSuccess = tempData!["success"] as! Bool
                
                if isSuccess == false {
                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                    return
                }
                
                self.mainData = tempData!["data"] as? NSDictionary
                
                if let userSearches = self.mainData!["user_searches"] as? NSArray {
                    
                    if let dictSearch = userSearches[0] as? NSDictionary {
                        if let results = dictSearch["results"] as? NSArray {
                            if let dictSearchFields = results[0] as? NSDictionary {
                                if let details = dictSearchFields["details"] as? NSArray {
                                    for dictProperty in details {
                                        if let dictPropertyFields = (dictProperty as! NSDictionary)["propertyFields"] as? NSDictionary {
                                            if dictPropertyFields["latitude"] as? String != nil {
                                                self.properties.add(dictPropertyFields)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                
                DispatchQueue.main.async(execute: {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    let centerCoordinate = CLLocationCoordinate2DMake(AppDelegate.returnAppDelegate().selectedCoordinates!.latitude, (AppDelegate.returnAppDelegate().selectedCoordinates?.longitude)!)
                    
                    self.mapView.centerCoordinate = centerCoordinate
//                    let region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 25000, 25000)
//                    self.mapView.setRegion(region, animated: true)
                    self.addAnnotationsToMap()
                    self.cvMapProperty.reloadData()
//                    let region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 5000, 5000)
//                    self.mapView.setRegion(region, animated: true)
                    
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
    
    @IBAction func btnLike_Tapped(_ sender: AnyObject) {
        let btn = sender as! UIButton
        self.dictProperty = self.properties[btn.tag] as! NSDictionary
        self.selectedRow = btn.tag
        if UserDefaults.standard.object(forKey: "token") == nil {
            reqType = 2
            self.performSegue(withIdentifier: "mapToSignup", sender: self)
        }
        else {
            let propertyCell = self.cvMapProperty.cellForItem(at: IndexPath(item: self.selectedRow!, section: 0)) as! MapPropertyCollectionViewCell
            
            if propertyCell.btnLike.isSelected == false {
                propertyCell.btnLike.isSelected = true
            }
            else {
                propertyCell.btnLike.isSelected = false
            }
            
            
            let token = UserDefaults.standard.object(forKey: "token") as! String
            self.likeProperty(token, listingCategory: dictProperty["listing_category"] as? String ?? "", propertyId: String(dictProperty["id"] as! Int))
        }
    }
    
    func getPropertyForLike(_ propertyID: String, listingCategory: String, selectedIndex: Int) -> Void {
        var strURL = "\(APIConstants.BasePath)/api/getproperty?token=\(DTSConstants.Constants.guestToken)&property_id=\(propertyID)&show_owned_only=0&show_active_only=1&listing_category=\(listingCategory)"
        
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = "\(APIConstants.BasePath)/api/getproperty?token=\(token)&property_id=\(propertyID)&show_owned_only=0&show_active_only=1&listing_category=\(listingCategory)"
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
                
                let dictData = (tempData!["data"] as! NSDictionary)["data"] as! NSArray
                let dictProperty = dictData[0] as! NSDictionary
                self.properties.replaceObject(at: selectedIndex, with: dictProperty)
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
    
    func likeProperty(_ token: String, listingCategory: String, propertyId: String) -> Void {
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
                    //self.getProperties()
                    self.getPropertyForLike(propertyId, listingCategory: listingCategory, selectedIndex: self.selectedRow!)
                }
                else {
                    let propertyCell = self.cvMapProperty.cellForItem(at: IndexPath(item: self.selectedRow!, section: 0)) as! MapPropertyCollectionViewCell
                    propertyCell.btnLike.isSelected = false
                    let _utils = Utils()
                    KVNProgress.dismiss()
                    _utils.showOKAlert("Error:", message: dict!["message"] as! String, controller: self, isActionRequired: false)
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

extension PropertiesMapViewController: SearchPropertiesDelegate {
    func didPressedDoneButton(_ isAgent: Bool) {
        
        if isAgent == false {
            UserDefaults.standard.set(1, forKey: "searchType")
            self.createUserSearch()
        }
        else {
            UserDefaults.standard.set(2, forKey: "searchType")
            self.createAgentSearch()
        }
    }
}

extension PropertiesMapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let dictProperty = self.properties[indexPath.row] as? NSDictionary {
            AppDelegate.returnAppDelegate().isNewProperty = nil
            
            let detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pDetailVC") as? PropertyDetailViewController
            
            detailController!.propertyID = String(dictProperty["id"] as! Int)
            detailController!.dictProperty = dictProperty
            detailController!.isFromMainView = true
            self.navigationController?.pushViewController(detailController!, animated: true)
        }
    }
}

extension PropertiesMapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: 300)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.properties.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mapCell", for: indexPath) as! MapPropertyCollectionViewCell
        
        let dictProperty = self.properties[indexPath.row] as! NSDictionary
        if let bgImages = dictProperty["imgs"] as? NSArray {
            if bgImages.count > 0 {
                let dictImage = bgImages[0] as! NSDictionary
                let dictImages = dictProperty["img_url"] as! [String: AnyObject]
                let imgURL = dictImages["md"] as! String
                cell.ivBg.sd_setImage(with: URL(string: imgURL))
            }
        }
        
        let priceNumber = NSNumber.init(value: dictProperty["price"] as! Int as Int)
        let price = Utils.suffixNumber(priceNumber)//String(dictProperty["price"] as! Int)
        let font1 = UIFont(name: "FranklinGothic-Demi", size: 39)
        let font2 = UIFont(name: "FranklinGothic-Demi", size: 30)
        let font3 = UIFont(name: "FranklinGothic-Demi", size: 14)
        
        //let gothicFont = cell.lblPrice.font
        
        let priceAttribute = [NSFontAttributeName: font1!]
        let termAttribute = [NSFontAttributeName: font3!]
        
        let priceAttributeString = NSMutableAttributedString(string: "\(price)", attributes: priceAttribute)
        let termAttributeString = NSMutableAttributedString(string: "/\(dictProperty["term"]!)", attributes: termAttribute)
        priceAttributeString.setFontForText("K", with: font2!)
        let listing_category = dictProperty["listing_category"] as! String
        
        if listing_category == "rent" {
            priceAttributeString.append(termAttributeString)
        }
        
        cell.lblTitle.attributedText = priceAttributeString//("$\(price)/\(dictProperty["term"]!)")
        cell.lblTitle.textColor = UIColor(hexString: "42ff00")
        cell.lblAddress.text = (dictProperty["address1"] as? String)?.capitalized
        
        let sqFtString = "\(dictProperty["lot_size"] ?? 0)"
        
        if sqFtString.count > 4 {
            let sqFtNumber = NSNumber.init(value: dictProperty["lot_size"] as? Int ?? 0)
            let sqFt = Utils.suffixNumber(sqFtNumber)
            cell.lblSqFt.text = ("\(sqFt)")
        }
        else {
            cell.lblSqFt.text = ("\(sqFtString)")
        }
        
        cell.ivStamp.isHidden = true
        
        if dictProperty["inquired"] as! Bool == true {
            cell.ivStamp.isHidden = false
        }
        
        let bath = String(dictProperty["bath"] as! Int)
        let bed = String(dictProperty["bed"] as! Int)
        
        cell.lblBath.text = bath
        cell.lblBedroom.text = bed
        
        cell.btnLike.addTarget(self, action: #selector(PropertiesViewController.btnLike_Tapped(_:)), for: .touchUpInside)
        cell.btnLike.isSelected = false
        let isLiked = dictProperty["liked"] as! Bool
        if isLiked == true {
            cell.btnLike.isSelected = true
        }
        
        
        cell.btnLike.tag = indexPath.row
        
        return cell
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = self.cvMapProperty.contentOffset.x
        let w = self.cvMapProperty.bounds.size.width
        let currentPage = Int(ceil(x/w))
        
        
        let dictPropertyAnn = self.properties[currentPage] as! NSDictionary
        let annPrice = String(dictPropertyAnn["price"] as! Int)
        let bed = String(dictPropertyAnn["bed"] as! Int)
        let annTitle = ("\(bed)BR $\(annPrice)/\(dictPropertyAnn["term"]!)")
        let annMTtitle = dictPropertyAnn["title"] as! String
        
        
        for i in 0..<self.mapView.annotations.count {
            let selectedAnnotation = self.mapView.annotations[i] as! PropertyAnnotation
            if annTitle == selectedAnnotation.subtitle! && annMTtitle == selectedAnnotation.title! {
                self.mapView.selectAnnotation(selectedAnnotation, animated: false)
                break
            }
        }
    }

}

extension PropertiesMapViewController: SignupViewControllerDelegate {
    func didSignedUpSuccessfully() {
        showHideBottomBar()
        let propertyCell = self.cvMapProperty.cellForItem(at: IndexPath(item: self.selectedRow!, section: 0)) as! MapPropertyCollectionViewCell
        propertyCell.btnLike.isSelected = true
        self.properties = NSMutableArray()
        self.getProperties(self.originalURL)
        
    }
    
    func showHideBottomBar() -> Void {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
