//
//  SearchPropertiesViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 22/08/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
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


protocol SearchPropertiesDelegate {
    func didPressedDoneButton(_ isAgent: Bool)
}

class SearchPropertiesViewController: BaseViewController {
    @IBOutlet weak var txtEnd: UITextField!
    @IBOutlet weak var segmentAgentOption: UISegmentedControl!
    @IBOutlet weak var txtFrequency: UITextField!
    @IBOutlet weak var txtStart: UITextField!
    @IBOutlet weak var viewAgentOptions: UIView!
    @IBOutlet weak var viewAgentConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var segmentBed: UISegmentedControl!
    @IBOutlet weak var segmentBaths: UISegmentedControl!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var btnUnitAnimities: UIButton!
    @IBOutlet weak var btnShowMoreFilter: UIButton!
    @IBOutlet weak var btnBuildingAnimities: UIButton!
    @IBOutlet weak var constraintButtonMoreFilter: NSLayoutConstraint!
    @IBOutlet weak var viewDefaultFilters: UIView!
    @IBOutlet weak var viewMoreFilters: UIView!
    
    @IBOutlet weak var priceRangeSlider: NMRangeSlider!
    @IBOutlet weak var constraintHeightViewMoreFilters: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var btnShortTerm: UIButton!
    @IBOutlet weak var btnLongTerm: UIButton!
    
    
    var selectedCoordinates: CLLocationCoordinate2D?
    var latitude: String?
    var longitude: String?
    var listingType: NSMutableArray!
    var terms: NSMutableArray!
    @IBOutlet weak var autocompleteTextfield: AutoCompleteTextField!
    fileprivate var responseData:NSMutableData?
    fileprivate var dataTask:URLSessionDataTask?
    var delegate: SearchPropertiesDelegate?
    var lowerPrice: String!
    var upperPrice: String!
    var isPropertySearch: Bool!
    var dictListing: NSDictionary!
    var dictTerm: NSDictionary!
    var dictAgentOptions: NSMutableDictionary?
    var dictAgentOptionsMap: NSMutableDictionary?
    var customPicker: CustomPickerView?
    var autoCompleteLocations: [String]?
    var currentLocationSelected: Bool!
    var listingCategory: String!
    
    
    fileprivate let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    fileprivate let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    
    
    
    @IBAction func backButton_Tapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func resetSearchSettingsButtonTapped(_ sender: AnyObject) {
        self.constraintButtonMoreFilter.constant = 30
        self.btnShowMoreFilter.isHidden = false
        self.constraintHeightViewMoreFilters.constant = 0
        self.segmentAgentOption.selectedSegmentIndex = 0
        self.viewAgentConstraintHeight.constant = 0
        self.viewAgentOptions.isHidden = true
        AppDelegate.returnAppDelegate().arrSearchCriteria = NSMutableArray()
//        self.lblPriceRange.text = "Over $800 to $10000"
        self.resetAllControls()
        self.segmentBed.selectedSegmentIndex = -1
        self.segmentBaths.selectedSegmentIndex = -1
        UserDefaults.standard.set(nil, forKey: "selectedRegion")
        if self.isPropertySearch == true {
            UserDefaults.standard.set(false, forKey: "isMoreViewLoaded")
            UserDefaults.standard.set(nil, forKey: "agentOptions")
            UserDefaults.standard.set(false, forKey: "isAgent")
            UserDefaults.standard.set(nil, forKey: "propertySearch")
            UserDefaults.standard.synchronize()
        }
        else {
            UserDefaults.standard.set(false, forKey: "isMoreViewLoadedMap")
            UserDefaults.standard.set(nil, forKey: "agentOptionsMap")
            UserDefaults.standard.set(false, forKey: "isAgentMap")
            UserDefaults.standard.set(nil, forKey: "mapSearch")
            UserDefaults.standard.synchronize()
        }
        
    }
    
    func resetAllControls() -> Void {
        
        self.autocompleteTextfield.text = ""
        let currentDate = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.txtStart.text = df.string(from: currentDate)
        
        let endDate = Date().addingTimeInterval(60*60*24*7)
        self.txtEnd.text = df.string(from: endDate)
        
        self.txtFrequency.text = "Daily"
        
        lowerPrice = String(Int(0.0 * 10000.0))
        upperPrice = String(Int(1 * 10000.0))
        
        priceRangeSlider.lowerValue = 0.0
        priceRangeSlider.upperValue = 0.6
        
        
        
        self.segmentBed.selectedSegmentIndex = -1
        self.segmentBaths.selectedSegmentIndex = -1
        
        Utils.resetAllBttonsInView(self.viewDefaultFilters)
        Utils.resetAllBttonsInView(self.viewMoreFilters)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listingType = NSMutableArray()
        self.terms = NSMutableArray()
        
        
        Utils.formateButtonInView(self.viewDefaultFilters)
        Utils.formateButtonInView(self.viewMoreFilters)
        self.constraintHeightViewMoreFilters.constant = 0
        self.viewMoreFilters.clipsToBounds = true
        //rangeSlider1 = RangeSlider(frame: CGRectZero)
        
        let btnShort = self.viewDefaultFilters.viewWithTag(1000) as! UIButton
        btnShort.isSelected = true
        terms.add("short")
        
        let btn = self.viewDefaultFilters.viewWithTag(1001) as! UIButton
        btn.isSelected = true
        terms.add("long")
        
        let btnApt = self.viewDefaultFilters.viewWithTag(2) as! UIButton
        btnApt.isSelected = true
        listingType.add("apt")
        
        let btnCondo = self.viewDefaultFilters.viewWithTag(3) as! UIButton
        btnCondo.isSelected = true
        listingType.add((btnCondo.titleLabel?.text!.lowercased())!)
        
        let btnHome = self.viewDefaultFilters.viewWithTag(4) as! UIButton
        btnHome.isSelected = true
        listingType.add((btnHome.titleLabel?.text!.lowercased())!)
        
        let btnOther = self.viewDefaultFilters.viewWithTag(5) as! UIButton
        btnOther.isSelected = true
        listingType.add((btnOther.titleLabel?.text!.lowercased())!)
        

        
        self.priceRangeSlider.minimumValue = 0.0
        self.priceRangeSlider.maximumValue = 0.6
        self.priceRangeSlider.lowerValue = 0.0
        self.priceRangeSlider.upperValue = 0.6
        self.priceRangeSlider.stepValue = 0.1
        
        listingCategory = "rent"
        
        

        
        
        configureTextField()
        handleTextFieldInterfaces()
        Utils.formateSingleButton(btnUnitAnimities)
        Utils.formateSingleButton(btnBuildingAnimities)

        
        
        
        self.segmentAgentOption.selectedSegmentIndex = 0
        self.viewAgentConstraintHeight.constant = 0
        self.viewAgentOptions.isHidden = true
        
        let currentDate = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.txtStart.text = df.string(from: currentDate)
        
        let endDate = Date().addingTimeInterval(60*60*24*7)
        self.txtEnd.text = df.string(from: endDate)
        
        self.txtFrequency.text = "Daily"
        
        lowerPrice = String(Int(0.1 * 10000.0))
        upperPrice = String(Int(1.0 * 10000.0))
        
        self.autocompleteTextfield.text = "Current Location"
        
        if self.isPropertySearch == true {
            
            if UserDefaults.standard.bool(forKey: "isMoreViewLoaded") == true {
                self.constraintButtonMoreFilter.constant = 0
                self.btnShowMoreFilter.isHidden = true
                self.constraintHeightViewMoreFilters.constant = 276
            }
            
            let dictTemp = UserDefaults.standard.object(forKey: "agentOptions") as? NSDictionary
            if dictTemp != nil {
                self.dictAgentOptions = dictTemp?.mutableCopy() as? NSMutableDictionary
            }
            else {
                self.dictAgentOptions = NSMutableDictionary()
            }
            
            if UserDefaults.standard.bool(forKey: "isAgent") == true {
                self.segmentAgentOption.selectedSegmentIndex = 1
//                self.viewAgentConstraintHeight.constant = 193
                self.viewAgentConstraintHeight.constant = 0
                self.viewAgentOptions.isHidden = true
                
            }
            
            let arrCriteria = Utils.unarchiveSearch("propertySearch")
            if arrCriteria == nil  {
                AppDelegate.returnAppDelegate().arrSearchCriteria = NSMutableArray()
            }
            else {
                AppDelegate.returnAppDelegate().arrSearchCriteria = arrCriteria!.mutableCopy() as! NSMutableArray
                populateFields()
            }
            
        }
        else {
            
            if UserDefaults.standard.bool(forKey: "isMoreViewLoadedMap") == true {
                self.constraintButtonMoreFilter.constant = 0
                self.btnShowMoreFilter.isHidden = true
                self.constraintHeightViewMoreFilters.constant = 276
            }
            
            let dictTemp = UserDefaults.standard.object(forKey: "agentOptionsMap") as? NSDictionary
            if dictTemp != nil {
                self.dictAgentOptionsMap = dictTemp?.mutableCopy() as? NSMutableDictionary
            }
            else {
                self.dictAgentOptionsMap = NSMutableDictionary()
            }
            
            if UserDefaults.standard.bool(forKey: "isAgentMap") == true {
                self.segmentAgentOption.selectedSegmentIndex = 1
//                self.viewAgentConstraintHeight.constant = 193
                self.viewAgentConstraintHeight.constant = 0
                self.viewAgentOptions.isHidden = true
            }
            
            let arrCriteria = Utils.unarchiveSearch("mapSearch")
            if arrCriteria == nil  {
                AppDelegate.returnAppDelegate().arrSearchCriteria = NSMutableArray()
            }
            else {
                AppDelegate.returnAppDelegate().arrSearchCriteria = arrCriteria!.mutableCopy() as! NSMutableArray
                populateFields()
            }
        }
        
        
        
        
    }
    
    func populateFields() -> Void {
        
        
        if let selectedRegion = UserDefaults.standard.object(forKey: "selectedRegion") as? String {
            self.autocompleteTextfield.text = selectedRegion
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
                    AppDelegate.returnAppDelegate().arrSearchCriteria.remove(dictField)
                    //self.autocompleteTextfield.text = dictField["value"] as? String
                }
                else if dictField["field"] as! String == "address" {
                    AppDelegate.returnAppDelegate().arrSearchCriteria.remove(dictField)
                }
                else if dictField["field"] as! String == "price" {
                    if dictField["operator"] as! String == ">=" {
                        let lowerValue = Float(dictField["value"] as! String)!/10000.0
                        self.priceRangeSlider.lowerValue = lowerValue
                        lowerPrice = dictField["value"] as! String
                        
                    }
                    else if dictField["operator"] as! String == "<=" {
                        let upperValue = Float(dictField["value"] as! String)!/10000.0
                        self.priceRangeSlider.upperValue = upperValue
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
                else if dictField["field"] as! String == "listing_category" {
                    self.listingCategory = dictField["value"] as! String
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
    
    @IBAction func actionSegmentClientValueChanged(_ sender: AnyObject) {
        let segment = sender as! UISegmentedControl
        if self.isPropertySearch == true {
            if segment.selectedSegmentIndex == 0 {
                UserDefaults.standard.set(false, forKey: "isAgent")
                self.viewAgentConstraintHeight.constant = 0
                self.viewAgentOptions.isHidden = true
            }
            else {
                UserDefaults.standard.set(true, forKey: "isAgent")
//                self.viewAgentConstraintHeight.constant = 193
                self.viewAgentConstraintHeight.constant = 0
                self.viewAgentOptions.isHidden = true
            }
        }
        else {
            if segment.selectedSegmentIndex == 0 {
                UserDefaults.standard.set(false, forKey: "isAgentMap")
                self.viewAgentConstraintHeight.constant = 0
                self.viewAgentOptions.isHidden = true
            }
            else {
                UserDefaults.standard.set(true, forKey: "isAgentMap")
//                self.viewAgentConstraintHeight.constant = 193
                self.viewAgentConstraintHeight.constant = 0
                self.viewAgentOptions.isHidden = true
            }
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        
        let btn = sender as! UIButton
        
        if btn.tag == 1 {
            if UserDefaults.standard.object(forKey: "token") == nil {
                self.dismiss(animated: false, completion: {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "signupFired"), object: nil)
                })
                return
            }
        }
        
        
        
        if self.isPropertySearch == true {
            if btn.tag == 0 {
                UserDefaults.standard.set(false, forKey: "isAgent")
                
            }
            else if btn.tag == 1 {
                UserDefaults.standard.set(true, forKey: "isAgent")
            }

        }
        else {
            if btn.tag == 0 {
                UserDefaults.standard.set(false, forKey: "isAgentMap")
                
            }
            else if btn.tag == 1 {
                UserDefaults.standard.set(true, forKey: "isAgentMap")
            }
        }
        
//        let geoValue = "\(AppDelegate.returnAppDelegate().selectedCoordinates!.latitude)|\(AppDelegate.returnAppDelegate().selectedCoordinates!.longitude)|10"
//        let dictGeo = ["field": "geo", "operator": "=", "value": geoValue]
//        
//        
//        
//        AppDelegate.returnAppDelegate().arrSearchCriteria.addObject(dictGeo)

        
        if AppDelegate.returnAppDelegate().selectedZip != nil {
            let dictRegion = ["field": "region", "operator": "=", "value": "zip|\(AppDelegate.returnAppDelegate().selectedZip!)"]
            AppDelegate.returnAppDelegate().arrSearchCriteria.add(dictRegion)
            UserDefaults.standard.set(AppDelegate.returnAppDelegate().selectedSearchRegion!, forKey: "selectedRegion")
        }
        else if AppDelegate.returnAppDelegate().selectedSearchRegion != nil && AppDelegate.returnAppDelegate().selectedSearchRegion?.characters.count > 0 && self.autocompleteTextfield.text != "Current Location" {
            if let region = AppDelegate.returnAppDelegate().selectedSearchRegion?.components(separatedBy: ",").first {
                //{ "field": "region", "operator": "=", "value": "city|New York" }
                
                var dictRegion = ["field": "region", "operator": "=", "value": "city|\(region)"]
                if let state = Utils.getAbbreviationByStateName(stateName: region) {
                    dictRegion = ["field": "region", "operator": "=", "value": "state|\(state)"]
                }
                AppDelegate.returnAppDelegate().arrSearchCriteria.add(dictRegion)
                UserDefaults.standard.set(AppDelegate.returnAppDelegate().selectedSearchRegion!, forKey: "selectedRegion")
            }
        }
        else {
            let geoValue = "\(AppDelegate.returnAppDelegate().selectedCoordinates!.latitude)|\(AppDelegate.returnAppDelegate().selectedCoordinates!.longitude)|10"
            let dictGeo = ["field": "geo", "operator": "=", "value": geoValue]
            UserDefaults.standard.set(nil, forKey: "selectedRegion")
            AppDelegate.returnAppDelegate().arrSearchCriteria.add(dictGeo)
        }
        
        let lowerPrice = String(self.priceRangeSlider.lowerValue * 10000)
        let upperPrice = String(self.priceRangeSlider.upperValue * 10000)
        
        let dictLowerPrice = ["field": "price", "operator": ">=", "value": lowerPrice]
        
//        let dictLowerPrice = ["field": "price", "operator": ">=", "value": "5000"]
        
        AppDelegate.returnAppDelegate().arrSearchCriteria.add(dictLowerPrice)
        
        //let dictUpperPrice = ["field": "price", "operator": "<=", "value": "999999"]
        //AppDelegate.returnAppDelegate().arrSearchCriteria.add(dictUpperPrice)
        
        if self.priceRangeSlider.upperValue == 0.6 {
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
        
//        let dictListingCategory = ["field" : "listing_category", "operator" : "=", "value" : listingCategory];
//        AppDelegate.returnAppDelegate().arrSearchCriteria.addObject(dictListingCategory)
        
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
        
        if self.isPropertySearch == true {
            if btn.tag == 1 {
                dictAgentOptions?.setObject((self.txtFrequency.text?.lowercased())!, forKey: "frequency" as NSCopying)
                dictAgentOptions?.setObject(self.txtStart.text!, forKey: "start" as NSCopying)
                dictAgentOptions?.setObject(self.txtEnd.text!, forKey: "end" as NSCopying)
                UserDefaults.standard.set(dictAgentOptions?.copy() as! NSDictionary, forKey: "agentOptions")
                
            }
            Utils.archiveSearch(AppDelegate.returnAppDelegate().arrSearchCriteria.copy() as! NSArray, keyTitle: "propertySearch")
            
        }
        else {
            if self.segmentAgentOption.selectedSegmentIndex == 1 {
                dictAgentOptionsMap?.setObject(self.txtFrequency.text!, forKey: "frequency" as NSCopying)
                dictAgentOptionsMap?.setObject(self.txtStart.text!, forKey: "start" as NSCopying)
                dictAgentOptionsMap?.setObject(self.txtEnd.text!, forKey: "end" as NSCopying)
                UserDefaults.standard.set(dictAgentOptionsMap?.copy() as! NSDictionary, forKey: "agentOptionsMap")
                
            }
            Utils.archiveSearch(AppDelegate.returnAppDelegate().arrSearchCriteria.copy() as! NSArray, keyTitle: "mapSearch")
        }
        
        
        
        self.dismiss(animated: true) {
            if self.delegate != nil {
                if self.isPropertySearch == true {
                    
                    self.delegate?.didPressedDoneButton(UserDefaults.standard.bool(forKey: "isAgent"))
                }
                else {
                    self.delegate?.didPressedDoneButton(UserDefaults.standard.bool(forKey: "isAgentMap"))
                }
            }
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
    
//    override func viewDidLayoutSubviews() {
//        let margin: CGFloat = 20.0
//        let width = view.bounds.width - 2.0 * margin
//        rangeSlider1.frame = CGRect(x: margin, y: margin + topLayoutGuide.length + 100,
//                                    width: width, height: 31.0)
//        
//    }
    
    @IBAction func actionLaodMoreFilters(_ sender: AnyObject) {
        self.constraintButtonMoreFilter.constant = 0
        self.btnShowMoreFilter.isHidden = true
        self.constraintHeightViewMoreFilters.constant = 276
        if self.isPropertySearch == true {
            UserDefaults.standard.set(true, forKey: "isMoreViewLoaded")
            UserDefaults.standard.synchronize()
        }
        else {
            UserDefaults.standard.set(true, forKey: "isMoreViewLoadedMap")
            UserDefaults.standard.synchronize()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetButtonTapped(_ sender: AnyObject) {
        self.constraintButtonMoreFilter.constant = 30
        self.btnShowMoreFilter.isHidden = false
        self.constraintHeightViewMoreFilters.constant = 0
        if self.isPropertySearch == true {
            UserDefaults.standard.set(false, forKey: "isMoreViewLoaded")
            UserDefaults.standard.synchronize()
        }
        else {
            UserDefaults.standard.set(false, forKey: "isMoreViewLoadedMap")
            UserDefaults.standard.synchronize()
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
        autocompleteTextfield.placeholder = "ZIPCODE or CITY"//"Enter City / Region"
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
                AppDelegate.returnAppDelegate().selectedSearchRegion = nil
                AppDelegate.returnAppDelegate().selectedCoordinates = AppDelegate.returnAppDelegate().currentLocation?.coordinate
                
                DispatchQueue.main.async(execute: {
                    KVNProgress.show(withStatus: "Getting Location Info")
                })
                
                Location.reverseGeocodeLocation(AppDelegate.returnAppDelegate().currentLocation!, completion: { (placemark, error) in
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    print("zip")
                    if let zipCode = placemark?.addressDictionary?["ZIP"] as? String {
                        UserDefaults.standard.set(zipCode, forKey: "adZip")
                        UserDefaults.standard.synchronize()
                    }
                    
                })
            }
            else {
                DispatchQueue.main.async(execute: {
                    KVNProgress.show(withStatus: "Getting Location Info")
                })
    
                
                
                Location.geocodeAddressString(text, completion: { (placemark, error) -> Void in
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    
                    AppDelegate.returnAppDelegate().selectedZip = nil
                    self!.selectedCoordinates = placemark?.location?.coordinate
                    AppDelegate.returnAppDelegate().selectedSearchRegion = text
                    AppDelegate.returnAppDelegate().selectedCoordinates = placemark?.location?.coordinate
                    
                    if let dictAddress = placemark?.addressDictionary {
                        self!.selectedCoordinates = placemark?.location?.coordinate
                        AppDelegate.returnAppDelegate().selectedSearchRegion = text
                        if let zipString = dictAddress["ZIP"] as? String {
                            AppDelegate.returnAppDelegate().selectedZip = zipString
                            UserDefaults.standard.set(zipString, forKey: "selectedZip")
                            UserDefaults.standard.set(zipString, forKey: "adZip")
                            UserDefaults.standard.synchronize()
                            UserDefaults.standard.synchronize()
                            AppDelegate.returnAppDelegate().adZip = zipString
                        }
                        AppDelegate.returnAppDelegate().selectedCoordinates = placemark?.location?.coordinate
                    }
                    
//                    let addressComponents = text.components(separatedBy: ",")
//                    if addressComponents.count > 1 {
//                        let stringAfterComma = addressComponents[1].trimmingCharacters(in: CharacterSet.whitespaces)
//                        let zipComponents = stringAfterComma.components(separatedBy: " ")
//                        if zipComponents.count == 2 {
//                            let zipString = zipComponents[1]
//                            self!.selectedCoordinates = placemark?.location?.coordinate
//                            AppDelegate.returnAppDelegate().selectedSearchRegion = text
//                            AppDelegate.returnAppDelegate().selectedZip = zipString
//                            UserDefaults.standard.set(zipString, forKey: "selectedZip")
//                            UserDefaults.standard.synchronize()
//                            AppDelegate.returnAppDelegate().adZip = zipString
//                            AppDelegate.returnAppDelegate().selectedCoordinates = placemark?.location?.coordinate
//                        }
//                    }
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
    @IBOutlet weak var selectBuildingAnimitiesButtonTapped: UIButton!
    @IBAction func selectUnitAnimitiesButtonTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "showFilters", sender: self)
    }
    fileprivate func fetchAutocompletePlaces(_ keyword:String) {
        let urlString = "\(baseURLString)?key=\(googleMapsKey)&input=\(keyword)&types=(regions)&components=country:usa"
        let s = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        s.addCharacters(in: "+&")
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            if let url = URL(string: encodedString) {
                let request = URLRequest(url: url)
                dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                    if let data = data{
                        
                        do{
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            
                            if let status = (result as! NSDictionary)["status"] as? String{
                                if status == "OK"{
                                    if let predictions = (result as! NSDictionary)["predictions"] as? NSArray{
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

extension SearchPropertiesViewController: UITextFieldDelegate {
    
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
            self.showDatePicker(df.date(from: textField.text!)!, withIndexPath: IndexPath(row: textField.tag, section: 0))
            
            return false
        }
        else if textField.tag == 2 {
            self.txtFrequency.resignFirstResponder()
            self.txtStart.resignFirstResponder()
            self.txtEnd.resignFirstResponder()
            
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            self.showDatePicker(df.date(from: textField.text!)!, withIndexPath: IndexPath(row: textField.tag, section: 0))
            
            return false
            
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 105 {
            if autocompleteTextfield.autoCompleteStrings?.count > 0 {
                self.autocompleteTextfield.text = autocompleteTextfield.autoCompleteStrings![0]
                DispatchQueue.main.async(execute: {
                    KVNProgress.show(withStatus: "Getting Loation Info")
                })
                Location.geocodeAddressString(self.autocompleteTextfield.text!, completion: { (placemark, error) -> Void in
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let addressComponents = self.autocompleteTextfield.text!.components(separatedBy: ",")
                    let stringAfterComma = addressComponents[1].trimmingCharacters(in: CharacterSet.whitespaces)
                    let zipComponents = stringAfterComma.components(separatedBy: " ")
                    if zipComponents.count == 2 {
                        let zipString = zipComponents[1]
                        self.selectedCoordinates = placemark?.location?.coordinate
                        AppDelegate.returnAppDelegate().selectedSearchRegion = self.autocompleteTextfield.text!
                        AppDelegate.returnAppDelegate().selectedZip = zipString
                        AppDelegate.returnAppDelegate().selectedCoordinates = placemark?.location?.coordinate
                    }
                    else {
                        AppDelegate.returnAppDelegate().selectedZip = nil
                        self.selectedCoordinates = placemark?.location?.coordinate
                        AppDelegate.returnAppDelegate().selectedSearchRegion = self.autocompleteTextfield.text!
                        AppDelegate.returnAppDelegate().selectedCoordinates = placemark?.location?.coordinate
                    }
                    
                })
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
    
}

extension SearchPropertiesViewController: CustomPickerDelegate {
    func didCancelTapped() {
        self.hideCustomPicker()
    }
    
    func didDateSelected(_ date: Date, withIndexPath indexPath: IndexPath) {
        self.hideCustomPicker()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        if indexPath.row == 1 {
            self.txtStart.text = df.string(from: date)
        }
        else if indexPath.row == 2 {
            self.txtEnd.text = df.string(from: date)
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
