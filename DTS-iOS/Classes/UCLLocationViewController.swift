//
//  UCLLocationViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 14/07/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import MapKit


class UCLLocationViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var lblTitle: UILabel!
    var dictSelectedMessage: NSDictionary!
    var dictProperty: NSDictionary!
    var mainTitle: String!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var autocompleteTextfield: AutoCompleteTextField!
    
    fileprivate var responseData:NSMutableData?
    fileprivate var dataTask:URLSessionDataTask?
    
    @IBOutlet weak var btnSideMenu: UIButton!
    fileprivate let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    fileprivate let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    var addressController: AddressViewController?
    var detailController: UCLDetailsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblTitle.text = self.mainTitle
        configureTextField()
        handleTextFieldInterfaces()
        
        let revealController = revealViewController()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)

        
        
        let centerCoordinate = AppDelegate.returnAppDelegate().currentLocation?.coordinate ?? AppDelegate.returnAppDelegate().selectedCoordinates
        self.mapView.centerCoordinate = centerCoordinate!
        let region = MKCoordinateRegionMakeWithDistance(centerCoordinate!, 500, 500)
        self.mapView.setRegion(region, animated: true)

        let annotaion = SimpleAnnotation(coordinate: centerCoordinate!, title: "", subtitle: "")
        self.mapView.addAnnotation(annotaion)
        
        AppDelegate.returnAppDelegate().userProperty.setObject(centerCoordinate!.latitude, forKey: "propertyLatitude" as NSCopying)
        AppDelegate.returnAppDelegate().userProperty.setObject(centerCoordinate!.longitude, forKey: "propertyLongitude" as NSCopying)
        
        let location = CLLocation(latitude: (centerCoordinate?.latitude)!, longitude: (centerCoordinate?.longitude)!)
        
        Location.reverseGeocodeLocation(location, completion: { (placemark, error) in
            DispatchQueue.main.async(execute: {
                var formattedAddress = ""
                var i = 0
                for addressLine in placemark!.addressDictionary!["FormattedAddressLines"] as! [AnyObject] {
                    if i == 0 {
                        formattedAddress.append(addressLine as! String)
                    }
                    else {
                        formattedAddress.append(", \(addressLine)")
                    }
                    
                    i += 1
                }
                self.autocompleteTextfield.text = formattedAddress.replacingOccurrences(of: ", United States", with: "")
                
                guard let dictAddress = placemark?.addressDictionary else {
                    return
                }
                
                let streetAddress = dictAddress["Street"] as? String ?? ""
                let zip = dictAddress["ZIP"] as? String ?? ""
                let city = dictAddress["City"] as? String ?? ""
                let State = dictAddress["State"] as? String ?? ""
                let Country = dictAddress["Country"] as? String ?? ""
                
                AppDelegate.returnAppDelegate().userProperty.setObject(streetAddress, forKey: "address1" as NSCopying)
                AppDelegate.returnAppDelegate().userProperty.setObject(zip, forKey: "zip" as NSCopying)
                AppDelegate.returnAppDelegate().userProperty.setObject(city, forKey: "city" as NSCopying)
                AppDelegate.returnAppDelegate().userProperty.setObject(State, forKey: "state" as NSCopying)
                AppDelegate.returnAppDelegate().userProperty.setObject(Country, forKey: "country" as NSCopying)
                
            })
        })
        
        //self.getAddressFromLocatio(centerCoordinate!.latitude, andLongitude: centerCoordinate!.longitude)
    }
    
    func getAddressFromLocatio(_ latitude: Double, andLongitude longitude: Double) -> Void {
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=AIzaSyCLAdXdnslw3gRzcyzOWl7kogL6Y9l3Rt0"
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let result = json as? NSDictionary
                let results = result!["results"] as! NSArray
                let dictAddressComponents = results[0] as! NSDictionary
//                let formattedAddress = dictAddressComponents["formatted_address"] as! String
//                self.autocompleteTextfield.text = formattedAddress
                let arrayAddressComponents = dictAddressComponents["address_components"] as! NSArray
                
                let dictAddress = NSMutableDictionary()
                
                
            
                
                for dict in arrayAddressComponents {
                    let dictTemp = dict as! NSDictionary
                    
                    let types = dictTemp["types"] as! NSArray
                    
                    if types.contains("street_number") {
                        dictAddress.setObject(dictTemp["short_name"] as! String, forKey: "Street" as NSCopying)
                    }
                    if types.contains("route") {
                        dictAddress.setObject(dictTemp["short_name"] as! String, forKey: "Route" as NSCopying)
                    }
                    if types.contains("locality") {
                        dictAddress.setObject(dictTemp["short_name"] as! String, forKey: "City" as NSCopying)
                    }
                    if types.contains("administrative_area_level_1") {
                        dictAddress.setObject(dictTemp["short_name"] as! String, forKey: "State" as NSCopying)
                    }
                    if types.contains("country") {
                        dictAddress.setObject(dictTemp["long_name"] as! String, forKey: "Country" as NSCopying)
                    }
                    if types.contains("postal_code") {
                        dictAddress.setObject(dictTemp["short_name"] as! String, forKey: "Zip" as NSCopying)
                    }
                }
                
                var address1 = ""
                
                if dictAddress["street"] as? String != nil && dictAddress["Route"] as? String != nil {
                    address1 = "\(dictAddress["Street"] as! String) \(dictAddress["Route"] as! String)"
                }
                else if dictAddress["street"] as? String != nil && dictAddress["Route"] as? String == nil {
                    address1 = "\(dictAddress["Street"] as! String)"
                }
                else if dictAddress["street"] as? String == nil && dictAddress["Route"] as? String != nil {
                    address1 = "\(dictAddress["Route"] as! String)"
                }
                
                var zip = "10075"
                if dictAddress["Zip"] != nil {
                    zip = dictAddress["Zip"] as! String
                }
                
                let city = dictAddress["City"] as! String
                let State = dictAddress["State"] as! String
                    
                    DispatchQueue.main.async(execute: {
                        self.autocompleteTextfield.text = ("\(city), \(State)")
                    })
                    
                
                let Country = dictAddress["Country"] as! String
                AppDelegate.returnAppDelegate().userProperty.setObject(address1, forKey: "address1" as NSCopying)
                AppDelegate.returnAppDelegate().userProperty.setObject(zip, forKey: "zip" as NSCopying)
                AppDelegate.returnAppDelegate().userProperty.setObject(city, forKey: "city" as NSCopying)
                AppDelegate.returnAppDelegate().userProperty.setObject(State, forKey: "state" as NSCopying)
                AppDelegate.returnAppDelegate().userProperty.setObject(Country, forKey: "country" as NSCopying)

                }
                catch {
                    
                }
            }
            else {
                
            }
        }.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     
    }
    @IBAction func btnNext_Tapped(_ sender: AnyObject) {
        if self.detailController == nil {
            self.detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ucldetailVC") as? UCLDetailsViewController
            detailController?.detailType = "detail"
        }
        self.navigationController?.pushViewController(self.detailController!, animated: true)
    }
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    fileprivate func configureTextField(){
        autocompleteTextfield.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        autocompleteTextfield.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        autocompleteTextfield.autoCompleteCellHeight = 35.0
        autocompleteTextfield.maximumAutoCompleteCount = 20
        autocompleteTextfield.hidesWhenSelected = true
        autocompleteTextfield.hidesWhenEmpty = true
        autocompleteTextfield.enableAttributedText = true
        autocompleteTextfield.isFromMap = false
        autocompleteTextfield.delegate = self
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        autocompleteTextfield.autoCompleteAttributes = attributes
    }
    
    fileprivate func handleTextFieldInterfaces(){
        autocompleteTextfield.onTextChange = {[weak self] text in
            if !text.isEmpty{
                if let dataTask = self?.dataTask {
                    dataTask.cancel()
                }
                self?.fetchAutocompletePlaces(text)
            }
        }
        
        autocompleteTextfield.onSelect = {[weak self] text, indexpath in
            if text == "Don't see your address?" {
                //uclAddressVC
                if self?.addressController == nil {
                    self?.addressController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "uclAddressVC") as? AddressViewController
                }
                self!.navigationController?.pushViewController((self?.addressController)!, animated: true)
            }
            else {
                Location.geocodeAddressString(text, completion: { (placemark, error) -> Void in
//                    if let dictAddress = placemark?.addressDictionary {
//                        let street = dictAddress["Street"] as? String ?? ""
//                        let zip = dictAddress["ZIP"] as? String ?? ""
//                        let city = dictAddress["City"] as? String ?? ""
//                        let state = dictAddress["State"] as? String ?? ""
//                        let country = dictAddress["Country"] as? String ?? ""
//
//                        AppDelegate.returnAppDelegate().userProperty.setObject(street, forKey: "address1" as NSCopying)
//                        AppDelegate.returnAppDelegate().userProperty.setObject(zip, forKey: "zip" as NSCopying)
//                        AppDelegate.returnAppDelegate().userProperty.setObject(city, forKey: "city" as NSCopying)
//                        AppDelegate.returnAppDelegate().userProperty.setObject(state, forKey: "state" as NSCopying)
//                        AppDelegate.returnAppDelegate().userProperty.setObject(country, forKey: "country" as NSCopying)
//                    }
                    
                    
                    DispatchQueue.main.async(execute: {
                        var formattedAddress = ""
                        var i = 0
                        for addressLine in placemark!.addressDictionary!["FormattedAddressLines"] as! [AnyObject] {
                            if i == 0 {
                                formattedAddress.append(addressLine as! String)
                            }
                            else {
                                formattedAddress.append(", \(addressLine)")
                            }
                            
                            i += 1
                        }
                        self?.autocompleteTextfield.text = formattedAddress.replacingOccurrences(of: ", United States", with: "")
                        
                        guard let dictAddress = placemark?.addressDictionary else {
                            return
                        }
                        
                        let streetAddress = dictAddress["Street"] as? String ?? ""
                        let zip = dictAddress["ZIP"] as? String ?? ""
                        let city = dictAddress["City"] as? String ?? ""
                        let State = dictAddress["State"] as? String ?? ""
                        let Country = dictAddress["Country"] as? String ?? ""
                        
                        AppDelegate.returnAppDelegate().userProperty.setObject(streetAddress, forKey: "address1" as NSCopying)
                        AppDelegate.returnAppDelegate().userProperty.setObject(zip, forKey: "zip" as NSCopying)
                        AppDelegate.returnAppDelegate().userProperty.setObject(city, forKey: "city" as NSCopying)
                        AppDelegate.returnAppDelegate().userProperty.setObject(State, forKey: "state" as NSCopying)
                        AppDelegate.returnAppDelegate().userProperty.setObject(Country, forKey: "country" as NSCopying)
                        
                    })
                    
                    
                    if let coordinate = placemark?.location?.coordinate {
                        self?.autocompleteTextfield.resignFirstResponder()
                        let centerCoordinate = coordinate
                        AppDelegate.returnAppDelegate().userProperty.setObject(centerCoordinate.latitude, forKey: "propertyLatitude" as NSCopying)
                        AppDelegate.returnAppDelegate().userProperty.setObject(centerCoordinate.longitude, forKey: "propertyLongitude" as NSCopying)
                        self!.mapView.centerCoordinate = centerCoordinate
                        let region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 5000, 5000)
                        self!.mapView.setRegion(region, animated: true)
                        
                        let annotaion = SimpleAnnotation(coordinate: centerCoordinate, title: "", subtitle: "")
                        self!.mapView.addAnnotation(annotaion)

                    }
                })
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    fileprivate func fetchAutocompletePlaces(_ keyword:String) {
        let urlString = "\(baseURLString)?key=\(googleMapsKey)&input=\(keyword)&components=country:usa"
        let s = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        s.addCharacters(in: "+&")
        print("google api: \(urlString)")
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            if let url = URL(string: encodedString) {
                let request = URLRequest(url: url)
                dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                    if let data = data{
                        
                        do{
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                            
                            if let status = result["status"] as? String{
                                if status == "OK"{
                                    if let predictions = (result )["predictions"] as? NSArray{
                                        var locations = [String]()
                                        for dict in predictions as! [NSDictionary]{
                                            let prediction = (dict["description"] as! String).replacingOccurrences(of: ", United States", with: "")
                                            locations.append(prediction)
                                        }
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            self.autocompleteTextfield.autoCompleteStrings = locations
                                        })
                                        return
                                    }
                                }
                            }
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.autocompleteTextfield.autoCompleteStrings = nil
                            })
                        }
                        catch let error as NSError{
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                })
                dataTask?.resume()
            }
        }
    }
}

extension UCLLocationViewController: MKMapViewDelegate {
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
}
