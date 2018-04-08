//
//  EditSearchAgentViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 12/01/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation
import KVNProgress
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


class EditSearchAgentViewController: BaseViewController {
    
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var txtEnd: UITextField!
    @IBOutlet weak var txtFrequency: UITextField!
    @IBOutlet weak var txtStart: UITextField!
    @IBOutlet weak var viewAgentOptions: UIView!
    @IBOutlet weak var segmentBed: UISegmentedControl!
    @IBOutlet weak var segmentBaths: UISegmentedControl!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnUnitAnimities: UIButton!
    @IBOutlet weak var btnBuildingAnimities: UIButton!
    @IBOutlet weak var viewDefaultFilters: UIView!
    @IBOutlet weak var viewMoreFilters: UIView!
    @IBOutlet weak var lblPriceRange: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var btnShortTerm: UIButton!
    @IBOutlet weak var btnLongTerm: UIButton!
    
    
    var selectedCoordinates: CLLocationCoordinate2D?
    var selectedRegion: String?
    var latitude: String?
    var longitude: String?
    var rangeSlider1: RangeSlider!
    var listingType: NSMutableArray!
    var terms: NSMutableArray!
    @IBOutlet weak var autocompleteTextfield: AutoCompleteTextField!
    fileprivate var responseData:NSMutableData?
    fileprivate var dataTask:URLSessionDataTask?
    
    var stratDate: String!
    var EndDate: String!
    
    var lowerPrice: String!
    var upperPrice: String!
    
    var dictListing: NSDictionary!
    var dictTerm: NSDictionary!
    
    
    var customPicker: CustomPickerView?
    var autoCompleteLocations: [String]?
    var currentLocationSelected: Bool!
    
    var dictSearchAgent: NSDictionary!
    var dictSearchData: NSDictionary!
    
    var dictSchedule: NSMutableDictionary!
    var searchCriteriaArray: NSMutableArray!
    
    fileprivate let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    fileprivate let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.listingType = NSMutableArray()
        self.terms = NSMutableArray()
        
        let revealController = revealViewController()
        revealController?.panGestureRecognizer().isEnabled = false
        revealController?.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        
        Utils.formateButtonInView(self.viewDefaultFilters)
        Utils.formateButtonInView(self.viewMoreFilters)
        self.viewMoreFilters.clipsToBounds = true   
        rangeSlider1 = RangeSlider(frame: CGRect.zero)
    
        
        rangeSlider1.minimumValue = 0.0
        rangeSlider1.maximumValue = 0.6
        
        rangeSlider1.lowerValue = 0.0
        rangeSlider1.upperValue = 0.2
        
        
        rangeSlider1.addTarget(self, action: #selector(SearchPropertiesViewController.rangeSliderValueChanged(_:)), for: .valueChanged)
        self.viewDefaultFilters.addSubview(rangeSlider1)
        self.viewDefaultFilters.sendSubview(toBack: rangeSlider1)
        self.viewDefaultFilters.bringSubview(toFront: autocompleteTextfield)
        
        
        configureTextField()
        handleTextFieldInterfaces()
        Utils.formateSingleButton(btnUnitAnimities)
        Utils.formateSingleButton(btnBuildingAnimities)
        
        self.lblMessage.isHidden = true
        self.mainScrollView.isHidden = true
        self.btnSave.isHidden = true
        self.btnDelete.isHidden = true
    
        
        let currentDate = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"

        self.stratDate = df.string(from: currentDate)
        
        let df1 = DateFormatter()
        df1.dateFormat = "MMM dd yyyy"
        self.txtStart.text = df1.string(from: currentDate)
        
        
        let endDate = Date().addingTimeInterval(60*60*24*7)
        self.stratDate = df.string(from: endDate)
        self.txtStart.text = df1.string(from: endDate)
        
        self.txtFrequency.text = "Daily"
        
        lowerPrice = String(Int(0.0 * 10000))
        upperPrice = String(Int(0.2 * 10000))
        
        self.viewAgentOptions.isHidden = false
       
        self.getSearchAgents()
        
    }
    
    @IBAction func buildingAmenitiesButtonTapped(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "showBuildingAmenities", sender: self)
    }
    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 20.0
        let width = view.bounds.width - 2.0 * margin
        rangeSlider1.frame = CGRect(x: margin, y: margin + topLayoutGuide.length + 70,
                                    width: width, height: 31.0)
        lblPriceRange.frame = CGRect(x: margin, y: lblPriceRange.frame.origin.y,
                                     width: width, height: 31.0)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButton_Tapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
        //self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func shortTermButtonTapped(_ sender: AnyObject) {
        let button = sender as! UIButton
        if button.isSelected {
            button.isSelected = false
            for index in (0..<self.terms.count).reversed() {
                if "short" == self.terms[index] as? String {
                    self.terms.removeObject(at: index)
                }
            }
        }
        else {
            button.isSelected = true
            self.terms.add("short")
        }
        
    }
    
    @IBAction func longTermButtonTapped(_ sender: AnyObject) {
        let button = sender as! UIButton
        if button.isSelected {
            button.isSelected = false
            for index in (0..<self.terms.count).reversed() {
                if "long" == self.terms[index] as? String {
                    self.terms.removeObject(at: index)
                }
            }
        }
        else {
            button.isSelected = true
            self.terms.add("long")
        }
    }
    
    
    
    @IBAction func actionFiltersSelected(_ sender: AnyObject) {
        let button = sender as! UIButton
        if button.isSelected {
            button.isSelected = false
            if button.titleLabel?.text! == "Apartment" {
                for index in (0..<self.listingType.count).reversed() {
                    if "apt" == self.listingType[index] as? String {
                        self.listingType.removeObject(at: index)
                    }
                }
            }
            else {
                for index in (0..<self.listingType.count).reversed() {
                    if button.titleLabel?.text?.lowercased() == self.listingType[index] as? String {
                        self.listingType.removeObject(at: index)
                    }
                }
            }
            
        }
        else {
            button.isSelected = true
            
            if button.titleLabel?.text! == "Apartment" {
                self.listingType.add("apt")
            }
            else {
                self.listingType.add((button.titleLabel?.text?.lowercased())!)
            }
            
        }
    }
    
    func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        //        self.lblPriceRange.text = "Over $(\(Int(rangeSlider.lowerValue * 10000)) to $\(Int(rangeSlider.upperValue * 10000)))"
        let roundedLowerValue = round(rangeSlider.lowerValue / 0.1) * 0.1
        rangeSlider.lowerValue = roundedLowerValue
        
        let roundedUpperValue = round(rangeSlider.upperValue / 0.1) * 0.1
        rangeSlider.upperValue = roundedUpperValue
        
        lowerPrice = String(Int(rangeSlider.lowerValue * 10000))
        upperPrice = String(Int(rangeSlider.upperValue * 10000))
        
    }
    
    fileprivate func configureTextField(){
        autocompleteTextfield.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        autocompleteTextfield.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        autocompleteTextfield.autoCompleteCellHeight = 35.0
        autocompleteTextfield.maximumAutoCompleteCount = 20
        autocompleteTextfield.hidesWhenSelected = true
        autocompleteTextfield.hidesWhenEmpty = true
        autocompleteTextfield.enableAttributedText = true
        autocompleteTextfield.isFromMap = true
        autocompleteTextfield.tag = 105
        autocompleteTextfield.delegate = self
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        autocompleteTextfield.autoCompleteAttributes = attributes
        autocompleteTextfield.placeholder = "Enter City / Region"
        autocompleteTextfield.showCurrentLocation = true
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
            self!.autocompleteTextfield.resignFirstResponder()
            
            if text == "Current Location" {
                //                self?.currentLocationSelected = true
                self?.selectedCoordinates = AppDelegate.returnAppDelegate().currentLocation?.coordinate
                
            }
            else {
                DispatchQueue.main.async(execute: {
                    KVNProgress.show(withStatus: "Getting Location Info")
                })
                Location.geocodeAddressString(text, completion: { (placemark, error) -> Void in
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    self!.selectedCoordinates = placemark?.location?.coordinate
                    self?.selectedRegion = text
                    
                    
                })
            }
        }
    }
    
    func showPicker(_ items: NSArray, indexPath: IndexPath, andKey key: String) {
        if self.customPicker != nil {
            self.customPicker?.removeFromSuperview()
            self.customPicker = nil
        }
        self.customPicker = CustomPickerView.createPickerViewWithItmes(items, withIndexPath: indexPath, forKey: key)
        self.customPicker?.delegate = self
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.customPicker?.frame = CGRect(x: self.customPicker!.frame.origin.x, y: self.customPicker!.frame.origin.y, width: appDelegate.window!.frame.size.width, height: self.customPicker!.frame.size.height);
        
        self.customPicker!.center = CGPoint(x: self.customPicker!.center.x, y: (appDelegate.window?.frame.size.height)!+192)
        
        self.view.addSubview(self.customPicker!)
        
        UIView.beginAnimations("bringUp", context: nil)
        UIView.setAnimationDuration(0.3)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.customPicker!.center = CGPoint(x: self.customPicker!.center.x, y: (appDelegate.window?.frame.size.height)!-130)
        UIView.commitAnimations()
    }
    
    func hideCustomPicker() {
        if self.customPicker == nil {
            return
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        UIView.beginAnimations("bringDown", context: nil)
        UIView.setAnimationDuration(0.3)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.customPicker!.center = CGPoint(x: self.customPicker!.center.x, y: (appDelegate.window?.frame.size.height)!+192)
        UIView.commitAnimations()
    }
    
    
    func showDatePicker(_ selectedDate: Date, withIndexPath indexPath: IndexPath) {
        if self.customPicker != nil {
            self.customPicker?.removeFromSuperview()
            self.customPicker = nil
        }
        
        let currentDate = selectedDate
        self.customPicker = CustomPickerView.createPickerViewWithDate(true, withIndexPath: indexPath, isDateTime: false, andSelectedDate: currentDate)
        self.customPicker?.delegate = self
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.customPicker?.frame = CGRect(x: self.customPicker!.frame.origin.x, y: self.customPicker!.frame.origin.y, width: appDelegate.window!.frame.size.width, height: self.customPicker!.frame.size.height);
        
        self.customPicker!.center = CGPoint(x: self.customPicker!.center.x, y: (appDelegate.window?.frame.size.height)!+192)
        
        self.view.addSubview(self.customPicker!)
        
        UIView.beginAnimations("bringUp", context: nil)
        UIView.setAnimationDuration(0.3)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.customPicker!.center = CGPoint(x: self.customPicker!.center.x, y: (appDelegate.window?.frame.size.height)!-130)
        UIView.commitAnimations()
    }
    
    @IBAction func segmentBathsValueChanged(_ sender: AnyObject) {
        
    }
    @IBAction func segmentBedValueChanged(_ sender: AnyObject) {
        
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        self.deleteSearchAgent()
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        
        if self.selectedRegion != nil {
            if let region = self.selectedRegion?.components(separatedBy: ",").first {
                let dictRegion = ["field": "region", "operator": "=", "value": "city|\(region)"]
                AppDelegate.returnAppDelegate().arrSearchCriteria.add(dictRegion)
            }
        }
        else if self.selectedCoordinates != nil {
            let geoValue = "\(self.selectedCoordinates!.latitude)|\(self.selectedCoordinates!.longitude)|10"
            let dictGeo = ["field": "geo", "operator": "=", "value": geoValue]
            AppDelegate.returnAppDelegate().arrSearchCriteria.add(dictGeo)
        }
        
        
        let dictLowerPrice = ["field": "price", "operator": ">=", "value": lowerPrice]
        
        AppDelegate.returnAppDelegate().arrSearchCriteria.add(dictLowerPrice)
        
        if self.rangeSlider1.upperValue == 0.6 {
            let dictUpperPrice = ["field": "price", "operator": "<=", "value": "10000"]
            AppDelegate.returnAppDelegate().arrSearchCriteria.add(dictUpperPrice)
        }
        else {
            let dictUpperPrice = ["field": "price", "operator": "<=", "value": upperPrice]
            AppDelegate.returnAppDelegate().arrSearchCriteria.add(dictUpperPrice)
        }
        
        if segmentBaths.selectedSegmentIndex > -1 {
            let baths = String(segmentBaths.selectedSegmentIndex + 1)
            let dictBath = ["field" : "bath", "operator" : ">=", "value" : baths]
            AppDelegate.returnAppDelegate().arrSearchCriteria.add(dictBath)
        }
        
        if segmentBed.selectedSegmentIndex > -1 {
            let beds = String(segmentBed.selectedSegmentIndex + 1)
            let dictBed = ["field" : "bed", "operator" : "=", "value" : beds]
            AppDelegate.returnAppDelegate().arrSearchCriteria.add(dictBed)
        }
        
        if AppDelegate.returnAppDelegate().selectedCoordinates != nil {
            UserDefaults.standard.set((AppDelegate.returnAppDelegate().selectedCoordinates?.latitude)!, forKey: "selectedLat")
            UserDefaults.standard.set((AppDelegate.returnAppDelegate().selectedCoordinates?.longitude)!, forKey: "selectedLong")
            
            
            UserDefaults.standard.synchronize()
        }
        
        if listingType.count > 0 {
            dictListing = ["field" : "type", "operator" : "in", "value" : listingType]
            AppDelegate.returnAppDelegate().arrSearchCriteria.add(dictListing)
        }
        
        if terms.count > 0 {
            dictTerm = ["field" : "term", "operator" : "in", "value" : terms]
            AppDelegate.returnAppDelegate().arrSearchCriteria.add(dictTerm)
        }
        
        
        self.dictSchedule.setObject(self.txtFrequency.text!.lowercased(), forKey: "frequency" as NSCopying)
        self.dictSchedule.setObject(self.stratDate, forKey: "start" as NSCopying)
        self.dictSchedule.setObject(self.EndDate, forKey: "end" as NSCopying)
        
        let search_data: NSDictionary = [
            "schedule": self.dictSchedule,
            "criteria": AppDelegate.returnAppDelegate().arrSearchCriteria
        ]
        
        self.saveSearchAgent(search_data)
        
    }
    
    @IBAction func selectUnitAnimitiesButtonTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "showFilters", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFilters" {
            let unitController = segue.destination as! UnitAnimitiesViewController
            unitController.constraintValue = 58
        }
        else if segue.identifier == "showBuildingAmenities" {
            let buildingController = segue.destination as! BuildingAnimitiesViewController
            buildingController.constraintValue = 58
        }
    }
    
    fileprivate func fetchAutocompletePlaces(_ keyword:String) {
        let urlString = "\(baseURLString)?key=\(googleMapsKey)&input=\(keyword)&types=(cities)&components=country:usa"
        let s = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        s.addCharacters(in: "+&")
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            if let url = URL(string: encodedString) {
                let request = URLRequest(url: url)
                dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                    if let data = data{
                        
                        do{
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                            
                            if let status = result["status"] as? String{
                                if status == "OK"{
                                    if let predictions = result["predictions"] as? NSArray{
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

extension EditSearchAgentViewController {
    
    func convertDictionaryToJson(_ dictionary: NSDictionary) -> String {
        
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            return NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        }
        catch (let exception) {
           print(exception)
        }
        
        return ""
    }
    
    func saveSearchAgent(_ searchData: NSDictionary) -> Void {
        
        KVNProgress.show(withStatus: "Saving My Search")
        
        var strURL = "\(APIConstants.BasePath)/api/editsearchagent"
        var strToken = ""
        let searchAgentId = String(self.dictSearchAgent["id"] as! Int)
        //let searcAgentId = self.dictSearchAgent["id"] as! Int
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            strToken = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/editsearchagent?token=\(strToken)")
        }
        
        let body: NSDictionary = [
            "criteria": AppDelegate.returnAppDelegate().arrSearchCriteria
        ]
        
        print(body)
        
        //let dataSearchData =
        
        let strSearchData = self.convertDictionaryToJson(searchData)
        
        let strParams = "token=\(strToken)&search_agent_id=\(searchAgentId)&disabled=\(String(self.dictSearchAgent["disabled"] as! Int))&name=\(self.dictSearchAgent["name"] as! String)&search_data=\(strSearchData)"
        //let params: NSDictionary = ["token": strToken, "search_agent_id": String(searcAgentId), "disabled": String(self.dictSearchAgent["disabled"] as! Int), "name": self.dictSearchAgent["name"] as! String, "search_data": searchData]
        
        
            let paramData = strParams.data(using: String.Encoding.ascii, allowLossyConversion: true)!
            
            let url = URL(string: strURL)
            var request = URLRequest(url: url!)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            request.httpBody = paramData
            
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
                            })
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        }
                        
                        let _utils = Utils()
                        _utils.showOKAlert("", message: "Search Agent Updated", controller: self, isActionRequired: false)
                        return
    
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
    
    func populateFields() -> Void {
        
        self.dictSearchData = dictSearchAgent["search_data"] as! NSDictionary
        self.dictSchedule = (self.dictSearchData["schedule"] as! NSDictionary).mutableCopy() as! NSMutableDictionary
        AppDelegate.returnAppDelegate().arrSearchCriteria = (self.dictSearchData["criteria"] as! NSArray).mutableCopy() as! NSMutableArray
        
        print(AppDelegate.returnAppDelegate().arrSearchCriteria)
        
        if let frequency = self.dictSchedule["frequency"] as? String {
            self.txtFrequency.text = frequency.capitalized
        }
        
        if let startDate = self.dictSchedule["start"] as? String {
            let arrStartDate = startDate.components(separatedBy: " ")
            if arrStartDate.count > 1 {
                self.stratDate = arrStartDate[0]
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                let df1 = DateFormatter()
                df1.dateFormat = "MMM dd yyyy"
                let startDate = df.date(from: arrStartDate[0])
                self.txtStart.text = df1.string(from: startDate!)
            }
            else {
                self.stratDate = startDate
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                let df1 = DateFormatter()
                df1.dateFormat = "MMM dd yyyy"
                let startDate = df.date(from: self.stratDate)
                self.txtStart.text = df1.string(from: startDate!)
            }
        }
        
        if let endDate = self.dictSchedule["end"] as? String {
            if endDate.characters.count > 0 {
                self.EndDate = endDate
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                let df1 = DateFormatter()
                df1.dateFormat = "MMM dd yyyy"
                let endDate = df.date(from: self.EndDate)
                self.txtEnd.text = df1.string(from: endDate!)
            }
            else {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                if let strStartDate = self.txtStart.text {
                    let df1 = DateFormatter()
                    df1.dateFormat = "MMM dd yyyy"
                    let startDate = df.date(from: strStartDate)
                    let endDate = startDate!.addingTimeInterval(60*60*24*7)
                    self.EndDate = df.string(from: endDate)
                    self.txtEnd.text = df1.string(from: endDate)
                }
            }

        }
        else {
            
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            if let strStartDate = self.txtStart.text {
                let df1 = DateFormatter()
                df1.dateFormat = "MMM dd yyyy"
                let startDate = df.date(from: strStartDate)
                let endDate = startDate!.addingTimeInterval(60*60*24*7)
                self.EndDate = df.string(from: endDate)
                self.txtEnd.text = df1.string(from: endDate)
            }
            
        }
        
        if AppDelegate.returnAppDelegate().arrSearchCriteria.count > 0 {
            var index = AppDelegate.returnAppDelegate().arrSearchCriteria.count - 1;
            let arrTempSearchCriteria = AppDelegate.returnAppDelegate().arrSearchCriteria.copy() as! NSArray
            lowerPrice = ""
            upperPrice = ""
            for dict in arrTempSearchCriteria {
                let dictField = dict as! NSDictionary
                if dictField["field"] as! String == "geo" {
                    AppDelegate.returnAppDelegate().arrSearchCriteria.remove(dictField)
                    
                }
                else if dictField["field"] as! String == "region" {
                    self.autocompleteTextfield.text = (dictField["value"] as AnyObject).components(separatedBy: "|").last
                    AppDelegate.returnAppDelegate().arrSearchCriteria.remove(dictField)
                    
                }
                else if dictField["field"] as! String == "address" {
                    AppDelegate.returnAppDelegate().arrSearchCriteria.remove(dictField)
                }
                else if dictField["field"] as! String == "price" {
                    if dictField["operator"] as! String == ">=" {
                        let lowerValue = Double(dictField["value"] as! String)!/10000
                        self.rangeSlider1.lowerValue = lowerValue
                        lowerPrice = dictField["value"] as! String
                        
                    }
                    else if dictField["operator"] as! String == "<=" {
                        let upperValue = Double(dictField["value"] as! String)!/10000
                        self.rangeSlider1.upperValue = upperValue
                        upperPrice = dictField["value"] as! String
                    }
                    if lowerPrice.characters.count > 0 && upperPrice.characters.count > 0 {
                        //                        self.lblPriceRange.text = "Over $\(lowerPrice) to $\(upperPrice)"
                    }
                    AppDelegate.returnAppDelegate().arrSearchCriteria.remove(dictField)
                }
                else if dictField["field"] as! String == "bed" {
                    self.segmentBed.selectedSegmentIndex = (Int(dictField["value"] as! String)! - 1)
                    //                AppDelegate.returnAppDelegate().arrSearchCriteria.removeObjectAtIndex(index)
                    AppDelegate.returnAppDelegate().arrSearchCriteria.remove(dictField)
                }
                else if dictField["field"] as! String == "bath" {
                    self.segmentBaths.selectedSegmentIndex = (Int(dictField["value"] as! String)! - 1)
                    //                AppDelegate.returnAppDelegate().arrSearchCriteria.removeObjectAtIndex(index)
                    AppDelegate.returnAppDelegate().arrSearchCriteria.remove(dictField)
                }
                else if dictField["field"] as! String == "term" {
                    terms = (dictField["value"] as! NSArray).mutableCopy() as! NSMutableArray
                    if terms.count > 0 {
                        let btnLong = self.viewDefaultFilters.viewWithTag(1001) as! UIButton
                        btnLong.isSelected = false
                        let btnShort = self.viewDefaultFilters.viewWithTag(1000) as! UIButton
                        btnShort.isSelected = false
                        
                        for term in terms {
                            if term as! String == "long" {
                                btnLong.isSelected = true
                            }
                            else if term as! String == "short" {
                                
                                btnShort.isSelected = true
                            }
                        }
                    }
                    
                    AppDelegate.returnAppDelegate().arrSearchCriteria.remove(dictField)
                }
                else if dictField["field"] as! String == "type" {
                    listingType = (dictField["value"] as! NSArray).mutableCopy() as! NSMutableArray
                    if listingType.count > 0 {
                        
                        let btnApt = self.viewDefaultFilters.viewWithTag(2) as! UIButton
                        btnApt.isSelected = false
                        
                        let btnCondo = self.viewDefaultFilters.viewWithTag(3) as! UIButton
                        btnCondo.isSelected = false
                        
                        
                        let btnHome = self.viewDefaultFilters.viewWithTag(4) as! UIButton
                        btnHome.isSelected = false
                        
                        
                        let btnOther = self.viewDefaultFilters.viewWithTag(5) as! UIButton
                        btnOther.isSelected = false
                        
                        
                        for type in listingType {
                            if type as! String == "apt" {
                                let btn = self.viewDefaultFilters.viewWithTag(2) as! UIButton
                                btn.isSelected = true
                            }
                            else if type as! String == "condo" {
                                let btn = self.viewDefaultFilters.viewWithTag(3) as! UIButton
                                btn.isSelected = true
                            }
                            else if type as! String == "house" {
                                let btn = self.viewDefaultFilters.viewWithTag(4) as! UIButton
                                btn.isSelected = true
                            }
                            else if type as! String == "other" {
                                let btn = self.viewDefaultFilters.viewWithTag(5) as! UIButton
                                btn.isSelected = true
                            }
                        }
                    }
                    
                    AppDelegate.returnAppDelegate().arrSearchCriteria.remove(dictField)
                }
                index = index - 1
            }
        }
        
    }
}

extension EditSearchAgentViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            self.txtFrequency.resignFirstResponder()
            self.txtStart.resignFirstResponder()
            self.txtEnd.resignFirstResponder()
            self.showPicker([["title": "Daily"], ["title": "Weekly"]], indexPath: IndexPath(row: textField.tag, section: 0), andKey: "title")
            
            return false
        }
        else if textField.tag == 1 {
            self.txtFrequency.resignFirstResponder()
            self.txtStart.resignFirstResponder()
            self.txtEnd.resignFirstResponder()
            
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            self.showDatePicker(df.date(from: self.stratDate)!, withIndexPath: IndexPath(row: textField.tag, section: 0))
            
            return false
        }
        else if textField.tag == 2 {
            self.txtFrequency.resignFirstResponder()
            self.txtStart.resignFirstResponder()
            self.txtEnd.resignFirstResponder()
            
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            self.showDatePicker(df.date(from: self.EndDate)!, withIndexPath: IndexPath(row: textField.tag, section: 0))
            
            return false
            
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 105 {
            if autocompleteTextfield.autoCompleteStrings?.count > 0 {
                self.autocompleteTextfield.text = autocompleteTextfield.autoCompleteStrings![0]
                DispatchQueue.main.async(execute: {
                    KVNProgress.show(withStatus: "Geting Location Info")
                })
                Location.geocodeAddressString(self.autocompleteTextfield.text!, completion: { (placemark, error) -> Void in
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    self.selectedCoordinates = placemark?.location?.coordinate
                    AppDelegate.returnAppDelegate().selectedSearchRegion = self.autocompleteTextfield.text!
                    AppDelegate.returnAppDelegate().selectedCoordinates = placemark?.location?.coordinate
                    
                })
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
    
}

extension EditSearchAgentViewController: CustomPickerDelegate {
    func didCancelTapped() {
        self.hideCustomPicker()
    }
    
    func didDateSelected(_ date: Date, withIndexPath indexPath: IndexPath) {
        self.hideCustomPicker()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        
        let df1 = DateFormatter()
        df1.dateFormat = "MMM dd yyyy"
        
        if indexPath.row == 1 {
            self.stratDate = df.string(from: date)
            self.txtStart.text = df1.string(from: date)
        }
        else if indexPath.row == 2 {
            self.EndDate = df.string(from: date)
            self.txtEnd.text = df1.string(from: date)
        }
        
    }
    
    func didDurationSelected(_ duration: String, withIndexPath indexPath: IndexPath) {
        
    }
    
    func didItemSelected(_ optionIndex: NSInteger, andSeletedText selectedText: String, withIndexPath indexPath: IndexPath, andSelectedObject selectedObject: NSDictionary) {
        self.hideCustomPicker()
        if (indexPath.row == 0) {
            self.txtFrequency.text = selectedText
        }
    }
}

extension EditSearchAgentViewController {
    
    func deleteSearchAgent() -> Void {
        
        KVNProgress.show(withStatus: "Deleting My Search")
    
        var strURL = "\(APIConstants.BasePath)/api/deletesearchagent"
        var strToken = ""
        let searchAgentId = String(self.dictSearchAgent["id"] as! Int)
        //let searcAgentId = self.dictSearchAgent["id"] as! Int
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            strToken = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/deletesearchagent?token=\(strToken)&id=\(searchAgentId)")
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
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                        })
                        let _utils = Utils()
                        _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        return
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.lblMessage.isHidden = false
                        self.mainScrollView.isHidden = true
                        self.btnSave.isHidden = true
                        self.btnDelete.isHidden = true
                        UserDefaults.standard.set(0, forKey: "searchType")
                        UserDefaults.standard.synchronize()
                        
                        let _utils = Utils()
                        _utils.showOKAlert("", message: "Search Agent Deleted", controller: self, isActionRequired: false)
                    })
                    
                    return
                    
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
    
    
    func getSearchAgents() -> Void {
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getsearchagents?token=\(token)")
        }
        
        KVNProgress.show(withStatus: "Loading My Search")
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let result = json as? NSDictionary
                    
                    let isSuccess = result!["success"] as! Bool
                    
                    if isSuccess == false {
                        
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            self.lblMessage.isHidden = false
//                            let _utils = Utils()
//                            _utils.showOKAlert("Error:", message: result!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        
                        return
                    }
                    
                    let allSearchAgents = result!["data"] as! [AnyObject]
                    
                    if allSearchAgents.count > 0 {

                        var isDisabled = true
                        
                        for searchAgent in allSearchAgents {
                            if let disabled = searchAgent["disabled"] as? Int {
                                if disabled == 0 {
                                    isDisabled = false
                                    self.dictSearchAgent = searchAgent as! NSDictionary
                                    DispatchQueue.main.async(execute: {
                                        
                                        self.mainScrollView.isHidden = false
                                        self.btnSave.isHidden = false
                                        self.btnDelete.isHidden = false
                                        self.populateFields()
                                    })
                                }
                            }
                        }
                        if isDisabled == true {
                            DispatchQueue.main.async(execute: {
                                self.lblMessage.isHidden = false
                            })
                        }
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            self.lblMessage.isHidden = false
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
