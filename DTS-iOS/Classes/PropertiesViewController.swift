//
//  ViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 03/04/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

import AVFoundation
import AVKit
import CoreLocation
import KVNProgress
import SDWebImage
import Crashlytics


class PropertiesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, AVPlayerViewControllerDelegate, PropertyTableViewCellDelegate, SignupViewControllerDelegate {
    @IBOutlet weak var tblProperties: UITableView!
    @IBOutlet weak var constraintViewAdTop: NSLayoutConstraint!
    @IBOutlet weak var segmentListingType: UISegmentedControl!
    
    @IBOutlet weak var obTapTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var obHeartTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var obLikePropertyTextTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var obSwipeToConstrainst: NSLayoutConstraint!
    @IBOutlet weak var btnOverlay: UIButton!
    @IBOutlet weak var searchBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewSearcBar: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnGoBack: UIButton!
    @IBOutlet weak var btnLastSearch: UIButton!
    @IBOutlet weak var viewNearMe: UIView!
    @IBOutlet weak var btnNearMe: UIButton!
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var viewThirdOverlay: UIView!
    @IBOutlet weak var viewSecondOverlay: UIView!
    @IBOutlet weak var viewFirstOverlay: UIView!
    @IBOutlet weak var viewTopbarOverlay: UIView!
    @IBOutlet weak var tblViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cvBg: UICollectionView!
    @IBOutlet weak var imgPlaceHolder: UIImageView!
    
    @IBOutlet weak var viewOverlay3: UIView!
    @IBOutlet weak var viewOverlay1: UIView!
    @IBOutlet weak var viewOverlay2: UIView!
    
    @IBOutlet weak var viewListingCountBG: UIView!
    @IBOutlet weak var lblListingCount: UILabel!
    @IBOutlet weak var viewListingCount: UIView!
    @IBOutlet weak var viewAd: UIView!
    @IBOutlet weak var lblHeaderTitle: UILabel!
    var mainData: NSDictionary?
    var properties = NSMutableArray()
    var dictProperty: NSDictionary!
    var player: AVPlayer?
    var playerController: AVPlayerViewController?
    var bgImages: NSArray!
    var cachedImages: NSMutableArray!
    var refreshControl: UIRefreshControl!
    var reqType: Int?
    var selectedRow: Int?
    var pageNumber = 1
    var originalURL = "\(APIConstants.BasePath)/api/getproperty?"
    var nextURL: String?
    var mapController: PropertiesMapViewController!
    var searchController: SearchPropertiesViewController?
    var detailController: PropertyDetailViewController?
    var visitedProperties = [String]()
    var isFromSearch: Bool!
    var listingCategory: String!
    var lastPage: Int?
    var countDown = 3
    var timer: Timer!
    var overlyImagCounter = 1
    var basicConfiguration: KVNProgressConfiguration!
    var isRefreshing: Bool!
    var totalListings: String!
    var propertyIndex: Int!
    var adURL: String?
    var ownerCid: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        basicConfiguration = KVNProgressConfiguration.default()
        
        self.lblHeaderTitle.numberOfLines = 2
        
        //basicConfiguration.isFullScreen = true
        KVNProgress.setConfiguration(basicConfiguration)
        
        isRefreshing = false
        propertyIndex = 0
        
        self.lblListingCount.text = "0 Listings"
        
        self.viewOverlay1.isHidden = false
        self.viewOverlay2.isHidden = true
        self.viewOverlay3.isHidden = true
        
        if UIScreen.main.nativeBounds.height == 2436 {
            obTapTopConstraint.constant = 179
            obLikePropertyTextTopConstraint.constant += 24
            obHeartTopConstraint.constant += 24
            obSwipeToConstrainst.constant += 24
        }
        
        self.viewListingCount.isHidden = true
        self.viewListingCountBG.isHidden = true
        
        self.imgPlaceHolder.isHidden = true
        
        self.lblHeaderTitle.text = AppDelegate.returnAppDelegate().defaultRegion
    
        NotificationCenter.default.addObserver(self, selector: #selector(getMessage), name: NSNotification.Name(rawValue: "universalLInk"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getUserKeyWithNotificatoin), name: NSNotification.Name(rawValue: "universalLinkSA"), object: nil)
        //signupFired
        NotificationCenter.default.addObserver(self, selector: #selector(sendToSignup), name: NSNotification.Name(rawValue: "signupFired"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveToPropertyDetail), name: NSNotification.Name(rawValue: "universalLinkPD"), object: nil)
        //universalLinkPD

    //        if self.tabBarController?.tabBar.isHidden == false {
    //            if searchBottomConstraint.constant == 0 {
    //                searchBottomConstraint.constant = 49
    //            }
    //        }
        
        reqType = 2
        
        
        constraintViewAdTop.constant -= self.view.frame.height
        self.viewAd.isHidden = true
        self.btnSkip.alpha = 0
        
        self.btnSkip.setTitle("SKIP 3", for: .normal)
        
        self.properties = NSMutableArray()
        self.lblMessage.text = "No result found"
        AppDelegate.returnAppDelegate().presentedRow = -1
        //self.tblProperties.superview?.clipsToBounds = false
        //self.tblProperties.clipsToBounds = false
        
        self.view.backgroundColor = UIColor(hexString: "191919")
        self.tblProperties.backgroundColor = UIColor(hexString: "191919")
        
        
        self.segmentListingType.selectedSegmentIndex = 0
        
        
        listingCategory = "rent"
        
        originalURL = "\(APIConstants.BasePath)/api/getproperty?page=\(pageNumber)"
        
        

        self.setUpInfiniteScroll()
        
        self.tblProperties.addPullToRefresh {
            self.doSearch()
        }
        
        //self.setUpInfiniteScroll()
    
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

        
        if let savedLat = UserDefaults.standard.object(forKey: "selectedLat"), let savedLon = UserDefaults.standard.object(forKey: "selectedLong") {
            AppDelegate.returnAppDelegate().selectedCoordinates = CLLocationCoordinate2DMake(savedLat as! Double, savedLon as! Double)
            AppDelegate.returnAppDelegate().defaultRegion = UserDefaults.standard.object(forKey: "defaultRegion") as? String
            self.lblHeaderTitle.text = AppDelegate.returnAppDelegate().defaultRegion
            
            
        }
        
        
        //print(AppDelegate.returnAppDelegate().selectedCoordinates ?? "")
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(PropertiesViewController.updateListingWithCurrentLocation(_:)), name: NSNotification.Name(rawValue: "updateLocationFired"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PropertiesViewController.loadDefautlListings), name: NSNotification.Name(rawValue: "defaultLocationFired"), object: nil)
        
        self.viewOverlay1.isHidden = true
        self.viewOverlay2.isHidden = true
        self.viewOverlay3.isHidden = true
        self.btnOverlay.isHidden = true
        self.viewAd.isHidden = true
        
        if UserDefaults.standard.bool(forKey: "isAppLoadedFirstTime") == false {
            
            
            if AppDelegate.returnAppDelegate().isAppLoading {
                AppDelegate.returnAppDelegate().isAppLoading = false
//                KVNProgress.show()
//                self.doSearch()
                self.imgPlaceHolder.isHidden = false
                
            }
            else {
                self.properties = AppDelegate.returnAppDelegate().properties
            }
            

            
        }
        else {
            self.viewAd.isHidden = true
              self.getAd()
            if AppDelegate.returnAppDelegate().isAppLoading {
                AppDelegate.returnAppDelegate().isAppLoading = false
                KVNProgress.show(withStatus: "Loading Properties")
                self.doSearch()
//                self.getAd()
                
            }
            else {
                self.properties = AppDelegate.returnAppDelegate().properties
            }
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(PropertiesViewController.videoStopped), name: NSNotification.Name(rawValue: "PlayerStopped"), object: nil)
        
        self.btnAccount.isHidden = false
        let revealController = revealViewController()
        
        self.btnAccount.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        

        
        
        self.lblMessage.isHidden = true
        self.viewNearMe.isHidden = true
        self.tblProperties.isHidden = false
        
        
        self.tabBarItem.imageInsets = UIEdgeInsets(top: 19, left: 0, bottom: -12, right: 0)
        
        self.getUserGeneralInfo()

    }
    
    func moveToPropertyDetail() {
        AppDelegate.returnAppDelegate().isNewProperty = nil
        
        self.detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pDetailVC") as? PropertyDetailViewController
        
        detailController!.propertyID = AppDelegate.returnAppDelegate().dlPropertyId
        detailController?.isFromMainView = nil
        self.navigationController?.popToRootViewController(animated: false)
        self.navigationController?.pushViewController(self.detailController!, animated:false)
        
    }

    @IBAction func qrReaderButtonTapped(_ sender: Any) {
        let readerController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "readerVC") as? QRReaderViewController
        readerController?.delegate = self
        self.present(readerController!, animated: true) {
            
        }
    }
    
    @IBAction func adButtonTapped(_ sender: Any) {
        guard let strURL = self.adURL else {
            return
        }
        guard let url = URL(string: strURL) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func crashButtonTapped(_ sender: AnyObject) {
        Crashlytics.sharedInstance().crash()
    }

    
    func sendToSignup() {
        reqType = nil
        self.performSegue(withIdentifier: "propertiesToSignup", sender: self)
    }
    
    func loadDefautlListings() {
        DispatchQueue.main.async(execute: {
            self.imgPlaceHolder.isHidden = true
        })
        KVNProgress.show(withStatus: "Loading Properties")
        self.doSearch()
    }
    
    @IBAction func overlayButtonTapped(_ sender: Any) {
        if overlyImagCounter == 1 {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(showSecondImage), object: self)
            self.showSecondImage()
        }
        else if overlyImagCounter == 2 {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(showThirdImage), object: self)
            self.showThirdImage()
        }
        else if overlyImagCounter == 3 {
            self.hideThirdImage()
        }

    }
    
    func sideMenuButtonTappedForLogin() {
        reqType = nil
        self.performSegue(withIdentifier: "propertiesToSignup", sender: self)
    }
    
    
    func countDown(timer: Timer) -> Void {
        countDown = countDown - 1
        if countDown < 1 {
            self.viewAd.isHidden = true
            timer.invalidate()
            return
        }
        let strCountDown = "SKIP \(countDown)"
        self.btnSkip.setTitle(strCountDown, for: .normal)
    }
    
    func getPropertiesForSelectedState() {
        self.lblHeaderTitle.text = AppDelegate.returnAppDelegate().defaultRegion
        if AppDelegate.returnAppDelegate().selectedCoordinates != nil {
            UserDefaults.standard.set((AppDelegate.returnAppDelegate().selectedCoordinates?.latitude)!, forKey: "selectedLat")
            UserDefaults.standard.set((AppDelegate.returnAppDelegate().selectedCoordinates?.longitude)!, forKey: "selectedLong")
            
            UserDefaults.standard.set((AppDelegate.returnAppDelegate().defaultRegion)!, forKey: "defaultRegion")
            
            UserDefaults.standard.synchronize()
            
        }
        
        self.properties = NSMutableArray()
        self.getPropertiesAvailableState(self.originalURL)
    }
    
    func updateListingWithCurrentLocation(_ notification: Notification) -> Void {
        DispatchQueue.main.async(execute: {
            self.imgPlaceHolder.isHidden = true
            KVNProgress.show(withStatus: "Loading Properties")
        })
        Location.reverseGeocodeLocation(AppDelegate.returnAppDelegate().currentLocation!, completion: { (placemark, error) in
            print("zip")
            if let zipCode = placemark?.addressDictionary?["ZIP"] as? String {
                UserDefaults.standard.set(zipCode, forKey: "adZip")
                UserDefaults.standard.synchronize()
            }
            
            let currentLocation = notification.object as! CLLocation
            AppDelegate.returnAppDelegate().selectedCoordinates = currentLocation.coordinate
            if let state = placemark?.addressDictionary?["State"] as? String {
                
                if let fullStateName = Utils.getStateByAbbreviation(abbreviation: state) {
                    AppDelegate.returnAppDelegate().defaultRegion = fullStateName
                }
                if let city = placemark?.addressDictionary?["locality"] as? String {
                    AppDelegate.returnAppDelegate().defaultRegion = "\(city), \(state)"
                }
                if state != "FL" && state != "NY" && state != "CA" && state != "GA" && state != "TX" && state != "PA" {
                    DispatchQueue.main.async(execute: {
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "statesVC") as! StatesViewController
                        controller.delegate = self
                        self.navigationController?.pushViewController(controller, animated: false)
                        return
                    })
                }
                
                
            }
            
            self.lblHeaderTitle.text = AppDelegate.returnAppDelegate().defaultRegion
            
            if AppDelegate.returnAppDelegate().selectedCoordinates != nil {
                UserDefaults.standard.set((AppDelegate.returnAppDelegate().selectedCoordinates?.latitude)!, forKey: "selectedLat")
                UserDefaults.standard.set((AppDelegate.returnAppDelegate().selectedCoordinates?.longitude)!, forKey: "selectedLong")
                
                UserDefaults.standard.set((AppDelegate.returnAppDelegate().defaultRegion)!, forKey: "defaultRegion")
                
                UserDefaults.standard.synchronize()
                
            }
            
            DispatchQueue.main.async(execute: {
                self.properties = NSMutableArray()
                self.getProperties(self.originalURL)
            })
            
            
        })
//        let currentLocation = notification.object as! CLLocation
//        AppDelegate.returnAppDelegate().selectedCoordinates = currentLocation.coordinate
//        if AppDelegate.returnAppDelegate().selectedCoordinates != nil {
//            UserDefaults.standard.set((AppDelegate.returnAppDelegate().selectedCoordinates?.latitude)!, forKey: "selectedLat")
//            UserDefaults.standard.set((AppDelegate.returnAppDelegate().selectedCoordinates?.longitude)!, forKey: "selectedLong")
//            
//            UserDefaults.standard.synchronize()
//
//        }
//    
//        self.properties = NSMutableArray()
//        self.getProperties(self.originalURL)
    }
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        self.viewAd.isHidden = true
    }
    @IBAction func goBackButtonTapped(_ sender: AnyObject) {
        UserDefaults.standard.set(0, forKey: "searchType")
        UserDefaults.standard.synchronize()
        self.lblHeaderTitle.text = AppDelegate.returnAppDelegate().defaultRegion
        AppDelegate.returnAppDelegate().selectedCoordinates = AppDelegate.returnAppDelegate().currentLocation?.coordinate
        if AppDelegate.returnAppDelegate().selectedCoordinates != nil {
            UserDefaults.standard.set((AppDelegate.returnAppDelegate().selectedCoordinates?.latitude)!, forKey: "selectedLat")
            UserDefaults.standard.set((AppDelegate.returnAppDelegate().selectedCoordinates?.longitude)!, forKey: "selectedLong")
            
            UserDefaults.standard.synchronize()
            
        }
        self.properties = NSMutableArray()
        self.getProperties(self.originalURL)
    }
    @IBAction func lastSearchButtonTapped(_ sender: AnyObject) {
        if let arrCriteria = Utils.unarchiveSearch("propertySearch") {
            AppDelegate.returnAppDelegate().arrSearchCriteria = arrCriteria.mutableCopy() as! NSMutableArray
            //KVNProgress.show()
            KVNProgress.show(withStatus: "Searching Properties")
            self.createUserSearch()
        }
    }
    @IBAction func btnNearMe_Tapped(_ sender: AnyObject) {
        UserDefaults.standard.set(0, forKey: "searchType")
        UserDefaults.standard.synchronize()
        self.lblHeaderTitle.text = "Near My Location"
        AppDelegate.returnAppDelegate().selectedCoordinates = AppDelegate.returnAppDelegate().currentLocation?.coordinate
        if AppDelegate.returnAppDelegate().selectedCoordinates != nil {
            UserDefaults.standard.set((AppDelegate.returnAppDelegate().selectedCoordinates?.latitude)!, forKey: "selectedLat")
            UserDefaults.standard.set((AppDelegate.returnAppDelegate().selectedCoordinates?.longitude)!, forKey: "selectedLong")
            
            UserDefaults.standard.synchronize()
            
        }
        self.properties = NSMutableArray()
        KVNProgress.show(withStatus: "Loading Properties")
        self.getProperties(self.originalURL)
    }
    
    func videoStopped() -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.viewTopbarOverlay.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) in
            self.viewTopbarOverlay.isHidden = true
            
            UIView.animate(withDuration: 0.3, animations: {
                self.viewFirstOverlay.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                self.viewFirstOverlay.isHidden = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.viewSecondOverlay.alpha = 0
                    self.view.layoutIfNeeded()
                }, completion: { (finished: Bool) in
                    self.viewSecondOverlay.isHidden = true
                    UIView.animate(withDuration: 0.3, animations: {
                        self.viewThirdOverlay.alpha = 0
                        self.view.layoutIfNeeded()
                    }, completion: { (finished: Bool) in
                        self.viewThirdOverlay.isHidden = true
                    }) 
                }) 
            }) 
            
        }) 
        
    }
    
    func showFirstImage() {
        
        self.btnOverlay.isHidden = false
        self.viewOverlay1.isHidden = false
        self.viewOverlay2.isHidden = true
        self.viewOverlay3.isHidden = true
        self.perform(#selector(showSecondImage), with: self, afterDelay: 3)
    }
    
    func showSecondImage() {
        overlyImagCounter = 2
//        self.imgOverlay.image = #imageLiteral(resourceName: "overlay-screen2")
        self.viewOverlay1.isHidden = true
        self.viewOverlay2.isHidden = false
        self.viewOverlay3.isHidden = true
        self.perform(#selector(showThirdImage), with: self, afterDelay: 3)
    }
    
    func hideThirdImage() {
        UIView.animate(withDuration: 0.5, animations: {
            self.viewOverlay3.alpha = 0
        }) { (completed) in
            //self.imgOverlay.isHidden = true
            self.viewOverlay1.isHidden = true
            self.viewOverlay2.isHidden = true
            self.viewOverlay3.isHidden = true
            self.btnOverlay.isHidden = true
        }
    }
    
    func showThirdImage() {
        overlyImagCounter = 3
        //self.imgOverlay.image = #imageLiteral(resourceName: "overlay-screen3")
        self.viewOverlay1.isHidden = true
        self.viewOverlay2.isHidden = true
        self.viewOverlay3.isHidden = false
        self.perform(#selector(hideThirdImage), with: self, afterDelay: 3)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.tabBarController?.tabBar.hidden = true
        
        self.viewAd.isHidden = true
        
        
        if AppDelegate.returnAppDelegate().deepMessageId != nil {
            self.getMessage()
        }
        else if AppDelegate.returnAppDelegate().deepSAKey != nil {
            self.getUserKeyWithNotificatoin()
        }
        
        if AppDelegate.returnAppDelegate().selectedProperty != nil {
            AppDelegate.returnAppDelegate().isNewProperty = nil
            
            self.detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pDetailVC") as? PropertyDetailViewController
            
            detailController!.propertyID = String(AppDelegate.returnAppDelegate().selectedProperty!["id"] as! Int)
            detailController?.dictProperty = AppDelegate.returnAppDelegate().selectedProperty
            detailController?.isFromMainView = true
            self.visitedProperties.append((detailController?.propertyID)!)
            AppDelegate.returnAppDelegate().selectedProperty = nil
            self.navigationController?.pushViewController(self.detailController!, animated: false)
        }
        
    }
    
    func refresh(_ sender:AnyObject) {
        // Code to refresh table view
        //        self.properties = NSMutableArray()
        self.doSearch()
        
    }
    
   
    
    func loadPropertiesOnLaunch() -> Void {
        if UserDefaults.standard.integer(forKey: "searchType") == 0 {
            self.getProperties(self.originalURL)
        }
        else if UserDefaults.standard.integer(forKey: "searchType") == 1 {
            let arrCriteria = Utils.unarchiveSearch("propertySearch")
            if arrCriteria == nil  {
                AppDelegate.returnAppDelegate().arrSearchCriteria = NSMutableArray()
            }
            else {
                AppDelegate.returnAppDelegate().arrSearchCriteria = arrCriteria!.mutableCopy() as! NSMutableArray
            }
            self.createUserSearch()
        }
        else if UserDefaults.standard.integer(forKey: "searchType") == 2 {
            let arrCriteria = Utils.unarchiveSearch("propertySearch")
            if arrCriteria == nil  {
                AppDelegate.returnAppDelegate().arrSearchCriteria = NSMutableArray()
            }
            else {
                AppDelegate.returnAppDelegate().arrSearchCriteria = arrCriteria!.mutableCopy() as! NSMutableArray
            }
            self.createAgentSearch()
        }
        
    }
    
    func doSearch() -> Void {
        //KVNProgress.show()
        
        if UserDefaults.standard.integer(forKey: "searchType") == 0 {
            self.getPropertiesForRefresh(originalURL)
        }
        else if UserDefaults.standard.integer(forKey: "searchType") == 1 {
            let arrCriteria = Utils.unarchiveSearch("propertySearch")
            if arrCriteria == nil  {
                AppDelegate.returnAppDelegate().arrSearchCriteria = NSMutableArray()
            }
            else {
                AppDelegate.returnAppDelegate().arrSearchCriteria = arrCriteria!.mutableCopy() as! NSMutableArray
            }
            self.createUserSearch()
        }
        else if UserDefaults.standard.integer(forKey: "searchType") == 2 {
            let arrCriteria = Utils.unarchiveSearch("propertySearch")
            if arrCriteria == nil  {
                AppDelegate.returnAppDelegate().arrSearchCriteria = NSMutableArray()
            }
            else {
                AppDelegate.returnAppDelegate().arrSearchCriteria = arrCriteria!.mutableCopy() as! NSMutableArray
            }
            self.createAgentSearch()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        //self.viewSearcBar.bringSubview(toFront: self.view)
        showHideBottomBar()
        self.tblProperties.reloadData()
       
        
    }
    @IBAction func headerNearMeButtonTapped(_ sender: AnyObject) {
        self.getProperties(self.originalURL)
    }
    
    @IBAction func btnCreateListing_Tapped(_ sender: AnyObject) {
        AppDelegate.returnAppDelegate().userProperty = NSMutableDictionary()
        AppDelegate.returnAppDelegate().newlyCreatedPropertyId = 0
        AppDelegate.returnAppDelegate().isNewProperty = true
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "uclclassVC") as! UCLClassViewController
        controller.listType = "class"
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleSegment(_ sender: AnyObject) {
        let segment = sender as! UISegmentedControl
        if segment.selectedSegmentIndex == 0 {
            listingCategory = "rent"
        }
        else {
            listingCategory = "purchase"
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
        
        var strURL = "\(APIConstants.BasePath)/api/createusersearch?token=\(DTSConstants.Constants.guestToken)&create_search_agent=0"
        
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/createusersearch?token=\(token)&create_search_agent=0")
        }
        
        let body: NSDictionary = [
            "criteria": AppDelegate.returnAppDelegate().arrSearchCriteria
        ]
    
        print(body)
        
        do {
            let jsonParamsData = try JSONSerialization.data(withJSONObject: body, options: [])
            
            let url = URL(string: strURL)
            var request = URLRequest(url: url!)
            //var request = URLRequest(url: url!)
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            request.httpBody = jsonParamsData
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil {
                    do {
                        /*dispatch_async(dispatch_get_main_queue(), {
                            KVNProgress.dismiss()
                        })*/
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
                                //KVNProgress.dismiss()
                                KVNProgress.dismiss()
                            })
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                            return
                        }
                        
                        self.properties = NSMutableArray()
                        self.getAd()
                        self.getUserSearchByData(tempData!["data"] as! String)
                    }
                    catch {
                        
                    }
                }
                else {
                    
                    DispatchQueue.main.async(execute: {
                        //KVNProgress.dismiss()
                        KVNProgress.dismiss()
                    })
                    Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                    
                }
            }.resume()
            
        }
        catch {
            
        }
        
        
        
        
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
        
        var strURL = "\(APIConstants.BasePath)/api/createusersearch?token=\(DTSConstants.Constants.guestToken)&create_search_agent=1"
        
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/createusersearch?token=\(token)&create_search_agent=1")
        }
        
        let dictShedule = UserDefaults.standard.object(forKey: "agentOptions") as! NSDictionary
        
        let body: NSDictionary = [
            "schedule": dictShedule,
            "criteria": AppDelegate.returnAppDelegate().arrSearchCriteria
        ]
        
        //KVNProgress.show()
//        KVNProgress.show()
        
        
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
//                        DispatchQueue.main.async(execute: {
//                            //KVNProgress.dismiss()
//                            KVNProgress.dismiss()
//                        })
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
                                //KVNProgress.dismiss()
                                KVNProgress.dismiss()
                            })
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
                        //KVNProgress.dismiss()
                        KVNProgress.dismiss()
                        //self.refreshControl.endRefreshing()
                        self.tblProperties.pullToRefreshView.stopAnimating()
                    })
                    Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                    
                }
            }.resume()
        }
        catch {
        
        }
        
    }
    
    func getUserSearchByData(_ data: String) -> Void {
        var strURL = "\(APIConstants.BasePath)/api/getsearchresults?token=\(DTSConstants.Constants.guestToken)&type=user_searches&search_agent=0&key=\(data)"
        
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getsearchresults?token=\(token)&type=user_searches&search_agent=0&key=\(data)")
        }
        
        print("search url: \(strURL)")
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
//                    DispatchQueue.main.async(execute: {
//                        //KVNProgress.dismiss()
//                        KVNProgress.dismiss()
//                    })
                    
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
                            //KVNProgress.dismiss()
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        
                        return
                    }
                    
                    self.mainData = tempData!["data"] as? NSDictionary
                    self.lastPage = self.mainData!["last_page"] as? Int
                    
                    if let userSearches = self.mainData!["user_searches"] as? NSArray {
                        if userSearches.count > 0{
                            if let dictSearch = userSearches[0] as? NSDictionary {
                                if let results = dictSearch["results"] as? NSArray {
                                    if let dictSearchFields = results[0] as? NSDictionary {
                                        if let details = dictSearchFields["details"] as? NSArray {
                                            for dictProperty in details {
                                                if let dictPropertyFields = (dictProperty as! NSDictionary)["propertyFields"] as? NSDictionary {
                                                    if dictPropertyFields["latitude"] as? String != nil {
                                                        self.properties.add(dictPropertyFields)
                                                    }
                                                    else if dictPropertyFields["id"] as! Int == 0 {
                                                        self.properties.add(dictPropertyFields)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                        }
                    }
                    
                    //var i = 0
                    
                    AppDelegate.returnAppDelegate().properties = self.properties
//                    for dict in self.properties {
//                        let imagesTobeCached = (dict as! NSDictionary)["imgs"] as! NSArray
//                        if imagesTobeCached.count > 0 {
//                            let dictImg = imagesTobeCached[0] as! NSDictionary
//                            let strImgURL = (dictImg["img_url"] as! NSDictionary)["md"] as! String
//                            let imgURL = URL(string: strImgURL)
//                        }
//                        
//                    }
                    
                    DispatchQueue.main.async(execute: {
                        //self.refreshControl.endRefreshing()
                        self.tblProperties.pullToRefreshView.stopAnimating()
                        //KVNProgress.dismiss()
                        DispatchQueue.main.async(execute: {
                            self.lblListingCount.text = "\(self.properties.count) Listings"
                            if self.properties.count == 1 {
                                self.lblListingCount.text = "\(self.properties.count) Listings"
                            }
                            
                        })
                        KVNProgress.dismiss()
                        if self.properties.count == 0 {
                            self.tblProperties.isHidden = true
                            self.lblMessage.isHidden = false
                            self.viewNearMe.isHidden = false
                            self.viewListingCount.isHidden = true
                            self.viewListingCountBG.isHidden = true
                        }
                        else {
                            self.tblProperties.isHidden = false
                            self.lblMessage.isHidden = true
                            self.viewNearMe.isHidden = true
                            self.viewListingCount.isHidden = false
                            self.viewListingCountBG.isHidden = false
                        }
                        self.tblProperties.reloadData()
                        self.tblProperties.setContentOffset(CGPoint.zero, animated: false)
                    })
                
                }
                catch {
                    DispatchQueue.main.async(execute: {
                        //KVNProgress.dismiss()
                        KVNProgress.dismiss()
                        
                    })
                }
                
            }
            else {
                DispatchQueue.main.async(execute: {
                    //KVNProgress.dismiss()
                    KVNProgress.dismiss()
                    Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                })
                
            }
        }.resume()
    }
    
    func getPropertiesForRefresh(_ strURL: String) -> Void {
        
        
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
                    
//                    if UserDefaults.standard.bool(forKey: "isAppLoadedFirstTime") == true {
//                        DispatchQueue.main.async(execute: {
//                            //KVNProgress.dismiss()
//                            KVNProgress.dismiss()
//                        })
//                    }
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let tempData = json as? NSDictionary
                    if tempData != nil {
                        if tempData!["error"] as? String != nil {
                            let error = tempData!["error"] as! String
                            if error == "user not found" {
                                UserDefaults.standard.set(nil, forKey: "token")
                                AppDelegate.returnAppDelegate().logOut()
                                return
                            }
                        }
                    }
                    let isSuccess = tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        
                        DispatchQueue.main.async(execute: {
                            ////self.hud.hid(true)
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        
                        return
                    }
                    
                    self.mainData = tempData!["data"] as? NSDictionary
                    self.lastPage = self.mainData!["last_page"] as? Int
                    self.nextURL = self.mainData!["next_page_url"] as? String
                    DispatchQueue.main.async(execute: {
                        self.lblListingCount.text = "\(self.mainData!["total"] ?? "") Listings"
                        if self.properties.count == 1 {
                            self.lblListingCount.text = "\(self.mainData!["total"] ?? "") Listings"
                        }
                    })
                
                    self.properties = (self.mainData!["data"] as! NSArray).mutableCopy() as! NSMutableArray
                    AppDelegate.returnAppDelegate().properties = self.properties
                    
                    
                    if UserDefaults.standard.bool(forKey: "isAppLoadedFirstTime") == false {
                        if self.properties.count > 0 {
                            if self.properties.count >= 3 {
                                for index in 0..<3 {
                                    let dict = self.properties[index]
                                    let imagesTobeCached = (dict as! NSDictionary)["imgs"] as! NSArray
                                    if imagesTobeCached.count > 0 {
                                        let dictImg = imagesTobeCached[0] as! NSDictionary
                                        let strImgURL = (dictImg["img_url"] as! NSDictionary)["md"] as! String
                                        
                                        if let imgURL = URL(string: strImgURL) {
                                            
                                            do {
                                                let imgData = try Data.init(contentsOf: imgURL)
                                                if let img = UIImage(data: imgData) {
                                                    SDWebImageManager.shared().saveImage(toCache: img, for: imgURL)
                                                }
                                            }
                                            catch let ex {
                                                print(ex.localizedDescription)
                                            }
                                        }
                                    }
                                    if index == 2 {
                                        DispatchQueue.main.async(execute: {
                                            //KVNProgress.dismiss()
                                            KVNProgress.dismiss()
                                        })
                                    }
                                    
                                }
                            }
                            else {
                                for index in 0..<self.properties.count {
                                    let dict = self.properties[index]
                                    let imagesTobeCached = (dict as! NSDictionary)["imgs"] as! NSArray
                                    if imagesTobeCached.count > 0 {
                                        let dictImg = imagesTobeCached[0] as! NSDictionary
                                        let strImgURL = (dictImg["img_url"] as! NSDictionary)["md"] as! String
                                        
                                        if let imgURL = URL(string: strImgURL) {
                                            
                                            do {
                                                let imgData = try Data.init(contentsOf: imgURL)
                                                if let img = UIImage(data: imgData) {
                                                    SDWebImageManager.shared().saveImage(toCache: img, for: imgURL)
                                                }
                                            }
                                            catch let ex {
                                                print(ex.localizedDescription)
                                            }
                                        }
                                    }
                                    if index == self.properties.count - 1 {
                                        DispatchQueue.main.async(execute: {
                                            //KVNProgress.dismiss()
                                            KVNProgress.dismiss()
                                        })
                                    }
                                    
                                }
                                
                            }
                        }
                        else {
                            DispatchQueue.main.async(execute: {
                                //KVNProgress.dismiss()
                                KVNProgress.dismiss()
                            })
                        }
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            //KVNProgress.dismiss()
                            KVNProgress.dismiss()
                        })
                    }
                    
                    
                    
                    DispatchQueue.main.async(execute: {
                        
                        self.tblProperties.pullToRefreshView.stopAnimating()
                        if self.properties.count == 0 {
                            self.tblProperties.isHidden = true
                            self.lblMessage.isHidden = false
                            self.viewNearMe.isHidden = false
                            self.viewListingCount.isHidden = true
                            self.viewListingCountBG.isHidden = true
                        }
                        else {
                            self.tblProperties.isHidden = false
                            self.lblMessage.isHidden = true
                            self.viewNearMe.isHidden = true
                            self.tblProperties.reloadData()
                            self.viewListingCount.isHidden = false
                            self.viewListingCountBG.isHidden = false
                            if UserDefaults.standard.bool(forKey: "isAppLoadedFirstTime") == false {
                                
                                UserDefaults.standard.set(true, forKey: "isAppLoadedFirstTime")
                                UserDefaults.standard.synchronize()
                                
                                self.showFirstImage()
                            }
                        }
                    })
                    
                }
                catch {
                    
                }
                
            }
            else {
                KVNProgress.dismiss()
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                
            }
        }.resume()
    }
    
    func getPropertiesAvailableState(_ strURL: String) -> Void {
        
        self.isFromSearch = false
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
                        //self.hud.hid(true)
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
                    let isSuccess = tempData!["success"] as! Bool//tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        
                        return
                    }
                    
                    self.mainData = tempData!["data"] as? NSDictionary
                    self.nextURL = self.mainData!["next_page_url"] as? String
                    DispatchQueue.main.async(execute: {
                        self.lblListingCount.text = "\(self.mainData!["total"] ?? "") Listings"
                        if self.properties.count == 1 {
                            self.lblListingCount.text = "\(self.mainData!["total"] ?? "") Listings"
                        }
                    })
                    self.properties.addObjects(from: self.mainData!["data"] as! NSArray as [AnyObject])
                    
                    if UserDefaults.standard.bool(forKey: "isAppLoadedFirstTime") == false {
                        if self.properties.count > 0 {
                            if self.properties.count >= 3 {
                                for index in 0..<3 {
                                    let dict = self.properties[index]
                                    let imagesTobeCached = (dict as! NSDictionary)["imgs"] as! NSArray
                                    if imagesTobeCached.count > 0 {
                                        let dictImg = imagesTobeCached[0] as! NSDictionary
                                        let strImgURL = (dictImg["img_url"] as! NSDictionary)["md"] as! String
                                        
                                        if let imgURL = URL(string: strImgURL) {
                                            
                                            do {
                                                let imgData = try Data.init(contentsOf: imgURL)
                                                if let img = UIImage(data: imgData) {
                                                    SDWebImageManager.shared().saveImage(toCache: img, for: imgURL)
                                                }
                                            }
                                            catch let ex {
                                                print(ex.localizedDescription)
                                            }
                                        }
                                    }
                                    if index == 2 {
                                        DispatchQueue.main.async(execute: {
                                            //KVNProgress.dismiss()
                                            KVNProgress.dismiss()
                                        })
                                    }
                                    
                                }
                            }
                            else {
                                for index in 0..<self.properties.count {
                                    let dict = self.properties[index]
                                    let imagesTobeCached = (dict as! NSDictionary)["imgs"] as! NSArray
                                    if imagesTobeCached.count > 0 {
                                        let dictImg = imagesTobeCached[0] as! NSDictionary
                                        let strImgURL = (dictImg["img_url"] as! NSDictionary)["md"] as! String
                                        
                                        if let imgURL = URL(string: strImgURL) {
                                            
                                            do {
                                                let imgData = try Data.init(contentsOf: imgURL)
                                                if let img = UIImage(data: imgData) {
                                                    SDWebImageManager.shared().saveImage(toCache: img, for: imgURL)
                                                }
                                            }
                                            catch let ex {
                                                print(ex.localizedDescription)
                                            }
                                        }
                                    }
                                    if index == self.properties.count - 1 {
                                        DispatchQueue.main.async(execute: {
                                            //KVNProgress.dismiss()
                                            KVNProgress.dismiss()
                                        })
                                    }
                                    
                                }
                                
                            }
                        }
                        else {
                            DispatchQueue.main.async(execute: {
                                //KVNProgress.dismiss()
                                KVNProgress.dismiss()
                            })
                        }
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            //KVNProgress.dismiss()
                            KVNProgress.dismiss()
                        })
                    }

                    
                    DispatchQueue.main.async(execute: {
                        if self.properties.count == 0 {
                            self.tblProperties.isHidden = true
                            self.lblMessage.isHidden = false
                            self.viewNearMe.isHidden = false
                            self.viewListingCount.isHidden = true
                            self.viewListingCountBG.isHidden = true
                            
                        }
                        else {
                            self.tblProperties.isHidden = false
                            self.lblMessage.isHidden = true
                            self.viewNearMe.isHidden = true
                            self.tblProperties.reloadData()
                            self.tblProperties.setContentOffset(CGPoint.zero, animated: false)
                            self.viewListingCount.isHidden = false
                            self.viewListingCountBG.isHidden = false
                            if UserDefaults.standard.bool(forKey: "isAppLoadedFirstTime") == false {
                                
                                UserDefaults.standard.set(true, forKey: "isAppLoadedFirstTime")
                                UserDefaults.standard.synchronize()
                                
                                self.showFirstImage()
                            }
                        }
                    })
                    AppDelegate.returnAppDelegate().properties = self.properties
                
                    
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
    
    func getProperties(_ strURL: String) -> Void {
        
        self.isFromSearch = false
        //KVNProgress.show()
        //KVNProgress.dismiss()
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
                    let isSuccess = tempData!["success"] as! Bool//tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        
                        return
                    }
                    
                    self.mainData = tempData!["data"] as? NSDictionary
                    self.nextURL = self.mainData!["next_page_url"] as? String
                    DispatchQueue.main.async(execute: {
                        self.lblListingCount.text = "\(self.mainData!["total"] ?? "") Listings"
                        if self.properties.count == 1 {
                            self.lblListingCount.text = "\(self.mainData!["total"] ?? "") Listings"
                        }
                    })
                    self.properties.addObjects(from: self.mainData!["data"] as! NSArray as [AnyObject])
                    
                    if UserDefaults.standard.bool(forKey: "isAppLoadedFirstTime") == false {
                        if self.properties.count > 0 {
                            if self.properties.count >= 3 {
                                for index in 0..<3 {
                                    let dict = self.properties[index]
                                    let imagesTobeCached = (dict as! NSDictionary)["imgs"] as! NSArray
                                    if imagesTobeCached.count > 0 {
                                        let dictImg = imagesTobeCached[0] as! NSDictionary
                                        let strImgURL = (dictImg["img_url"] as! NSDictionary)["md"] as! String
                                        
                                        if let imgURL = URL(string: strImgURL) {
                                            
                                            do {
                                                let imgData = try Data.init(contentsOf: imgURL)
                                                if let img = UIImage(data: imgData) {
                                                    SDWebImageManager.shared().saveImage(toCache: img, for: imgURL)
                                                }
                                            }
                                            catch let ex {
                                                print(ex.localizedDescription)
                                            }
                                        }
                                    }
                                    if index == 2 {
                                        DispatchQueue.main.async(execute: {
                                            //KVNProgress.dismiss()
                                            KVNProgress.dismiss()
                                        })
                                    }
                                    
                                }
                            }
                            else {
                                for index in 0..<self.properties.count {
                                    let dict = self.properties[index]
                                    let imagesTobeCached = (dict as! NSDictionary)["imgs"] as! NSArray
                                    if imagesTobeCached.count > 0 {
                                        let dictImg = imagesTobeCached[0] as! NSDictionary
                                        let strImgURL = (dictImg["img_url"] as! NSDictionary)["md"] as! String
                                        
                                        if let imgURL = URL(string: strImgURL) {
                                            
                                            do {
                                                let imgData = try Data.init(contentsOf: imgURL)
                                                if let img = UIImage(data: imgData) {
                                                    SDWebImageManager.shared().saveImage(toCache: img, for: imgURL)
                                                }
                                            }
                                            catch let ex {
                                                print(ex.localizedDescription)
                                            }
                                        }
                                    }
                                    if index == self.properties.count - 1 {
                                        DispatchQueue.main.async(execute: {
                                            //KVNProgress.dismiss()
                                            KVNProgress.dismiss()
                                        })
                                    }
                                    
                                }

                            }
                        }
                        else {
                            DispatchQueue.main.async(execute: {
                                //KVNProgress.dismiss()
                                KVNProgress.dismiss()
                            })
                        }
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            //KVNProgress.dismiss()
                            KVNProgress.dismiss()
                        })
                    }

                    
                    DispatchQueue.main.async(execute: {
                        if self.properties.count == 0 {
                            self.tblProperties.isHidden = true
                            self.lblMessage.isHidden = false
                            self.viewNearMe.isHidden = false
                            self.tblProperties.finishInfiniteScroll()
                            self.viewListingCount.isHidden = true
                            self.viewListingCountBG.isHidden = true
                        }
                        else {
                            self.tblProperties.isHidden = false
                            self.lblMessage.isHidden = true
                            self.viewNearMe.isHidden = true
                            self.tblProperties.reloadData()
                            self.tblProperties.finishInfiniteScroll()
                            self.viewListingCount.isHidden = false
                            self.viewListingCountBG.isHidden = false
                            if UserDefaults.standard.bool(forKey: "isAppLoadedFirstTime") == false {
                                
                                UserDefaults.standard.set(true, forKey: "isAppLoadedFirstTime")
                                UserDefaults.standard.synchronize()
                                
                                self.showFirstImage()
                            }

                        }
                    })
                    AppDelegate.returnAppDelegate().properties = self.properties

                    
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
    
    
    
    /*func getProperties(strURL: String) -> Void {
     
     self.isFromSearch = false
     KVNProgress.show()
     var strURL = "\(strURL)&token=\(DTSConstants.Constants.guestToken)&show_owned_only=0&show_active_only=1&latitude=\(AppDelegate.returnAppDelegate().selectedCoordinates!.latitude)&longitude=\(AppDelegate.returnAppDelegate().selectedCoordinates!.longitude)"
     
     
     
     if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
     let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
     strURL = ("\(strURL)&token=\(token)&show_owned_only=0&show_active_only=1&latitude=\(AppDelegate.returnAppDelegate().selectedCoordinates!.latitude)&longitude=\(AppDelegate.returnAppDelegate().selectedCoordinates!.longitude)")
     }
     
     
     let url = NSURL(string: <#T##String#>)
     let request = NSURLRequest(URL: <#T##NSURL#>)
     
     self.alamoFireManager!.request(.GET, strURL).responseJSON { (Response) in
     KVNProgress.dismiss()
     print("Request: \n \(Response.request!)")
     if Response.result.isSuccess {
     print("\n Response: \n \(Response.response!)")
     let tempData = Response.result.value as? NSDictionary
     if tempData != nil {
     if tempData!["error"] as? String != nil {
     let error = tempData!["error"] as! String
     if error == "user_not_found" {
     NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "token")
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
     self.properties.addObjectsFromArray(self.mainData!["data"] as! NSArray as [AnyObject])
     if self.properties.count == 0 {
     self.tblProperties.hidden = true
     self.lblMessage.hidden = false
     self.btnNearMe.hidden = false
     }
     var i = 0
     for dict in self.properties {
     let imagesTobeCached = dict["imgs"] as! NSArray
     
     let dictImg = imagesTobeCached[0] as! NSDictionary
     let strImgURL = dictImg["img_url"] as! NSDictionary)["md"] as! String
     let imgURL = NSURL(string: strImgURL)
     
     SDWebImageManager.sharedManager().downloadImageWithURL(imgURL, options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: NSURL!) in
     if error == nil {
     AppDelegate.returnAppDelegate().cachedImages.setObject(image, forKey: strImgURL)
     i += 1
     if i > 2 {
     if self.properties.count == 0 {
     self.tblProperties.hidden = true
     self.lblMessage.hidden = false
     self.btnNearMe.hidden = false
     }
     else {
     self.tblProperties.hidden = false
     self.lblMessage.hidden = true
     self.btnNearMe.hidden = true
     }
     self.tblProperties.reloadData()
     self.tblProperties.hidden = false
     //self.refreshControl.endRefreshing()
     }
     if i == self.properties.count {
     if self.properties.count == 0 {
     self.tblProperties.hidden = true
     self.lblMessage.hidden = false
     self.btnNearMe.hidden = false
     }
     else {
     self.tblProperties.hidden = false
     self.lblMessage.hidden = true
     self.btnNearMe.hidden = true
     }
     self.tblProperties.reloadData()
     self.tblProperties.hidden = false
     //self.refreshControl.endRefreshing()
     }
     }
     })
     
     AppDelegate.returnAppDelegate().properties = self.properties
     
     self.performSelector(#selector(ViewController.cacheImages(_:)), withObject: imagesTobeCached, afterDelay: 0.1)
     
     }
     
     }
     else {
     print("\n Response: \n \(Response)")
     let tempData = Response.result.value as? NSDictionary
     if tempData != nil {
     if tempData!["error"] as? String != nil {
     let error = tempData!["error"] as! String
     if error == "user_not_found" {
     NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "token")
     AppDelegate.returnAppDelegate().logOut()
     return
     }
     }
     }
     let _utils = Utils()
     KVNProgress.dismiss()
     
     _utils.showOKAlert("Error", message: (Response.result.error?.localizedDescription)!, controller: self, isActionRequired: false)
     return
     
     }
     }
     }*/
    
    func getPropertiesInBackground(_ strURL: String) -> Void {
        //KVNProgress.show()
        self.isFromSearch = false
        
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
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let tempData = json as? NSDictionary
                    self.nextURL = tempData!["next_page_url"] as? String
                    DispatchQueue.main.async(execute: {
                        self.lblListingCount.text = "\(self.mainData!["total"] ?? "") Listings"
                        if self.properties.count == 1 {
                            self.lblListingCount.text = "\(self.mainData!["total"] ?? "") Listings"
                        }
                    })
                    self.mainData = tempData!["data"] as? NSDictionary
                    self.properties.addObjects(from: self.mainData!["data"] as! NSArray as [AnyObject])
                    
                    AppDelegate.returnAppDelegate().properties = self.properties
                    
                    for dict in self.properties {
                        let imagesTobeCached = (dict as! NSDictionary)["imgs"] as! NSArray
                        
                        self.perform(#selector(PropertiesViewController.cacheImages(_:)), with: imagesTobeCached, afterDelay: 0.1)
                        
                    }
                }
                catch {
                    
                }
            }
            else {
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
            }
        }.resume()
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
                        
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        
                        return
                    }
                    
                    let properties = (tempData!["data"] as! NSDictionary)["data"] as! NSArray
                    if properties.count > 0 {
                        let dictProperty = properties[0] as! NSDictionary
                        self.properties.replaceObject(at: selectedIndex, with: dictProperty)
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
    
    func cacheImages(_ images: NSArray) -> Void {
        for dictImgTmp in images {
            let dictImg = dictImgTmp as! NSDictionary
            let strImgURL = (dictImg["img_url"] as! NSDictionary)["md"] as! String
            let imgURL = URL(string: strImgURL)
            
//            SDWebImageManager.shared().downloadImage(with: imgURL, options: SDWebImageOptions(rawValue: UInt(0)), progress: nil, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, completed: Bool, url: URL!) in
//                if error == nil {
//                    AppDelegate.returnAppDelegate().cachedImages.setObject(image, forKey: strImgURL as NSCopying)
//                }
//            } as! SDWebImageCompletionWithFinishedBlock)
        }
        
    }
    
    // Mark: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.properties.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //cell.hidden = false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dictProperty = self.properties[indexPath.row] as! NSDictionary
        
        if indexPath.row == 0 {
            AppDelegate.returnAppDelegate().hardcodedProperty = dictProperty as! [String: AnyObject]
        }
        
        let propertyId = dictProperty["id"] as! Int
        
        //print("property id: \(propertyId)")
        
        if propertyId == 0 {
            let adCell = tableView.dequeueReusableCell(withIdentifier: "adCell", for: indexPath) as! AdTableViewCell
            if let images = dictProperty["imgs"] as? NSArray {
                if (images.count > 0) {
                    let dictImage = images[0] as! NSDictionary
                    let imgURL = (dictImage["img_url"] as! NSDictionary)["md"] as! String
                    adCell.imgView.sd_setImage(with: URL(string: imgURL))
                }
            }
            adCell.selectionStyle = .none
            return adCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "propertyCell", for: indexPath) as! PropertyTableViewCell
        
        
        cell.delegate = self
        
        self.bgImages = dictProperty["imgs"] as! NSArray
        
        cell.tag = indexPath.row
        cell.loadImages(self.bgImages)
        
        cell.imgViewNewTop.isHidden = true
            
        let x = cell.cvBG.contentOffset.x
        let w = cell.cvBG.bounds.size.width
        let currentPage = Int(ceil(x/w))
        cell.lblCounter.text = ("\(currentPage + 1)/\(cell.bgImages.count)")
        
        
        let strCreatedDate = dictProperty["created_at"] as! String
        let daysBetween = Utils.calculateDaysBetweenDates("", createdDate: strCreatedDate)
    
        
        if daysBetween < 2 {
            cell.imgViewNewTop.isHidden = false
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
        
        cell.lblPrice.attributedText = priceAttributeString//("$\(price)/\(dictProperty["term"]!)")
        cell.lblPrice.textColor = UIColor(hexString: "42ff00")
        cell.lblAddress.text = (dictProperty["address1"] as? String)?.capitalized
        cell.viewCounter.layer.cornerRadius = 6
        cell.viewCounter.clipsToBounds = true
        
        
        
        cell.ivStamp.isHidden = true
        cell.ivStamp.contentMode = .scaleToFill
        

        if dictProperty["inquired"] as! Bool == true {
            cell.ivStamp.isHidden = false
        }
        else {
            if let lInquired = UserDefaults.standard.object(forKey: "\(propertyId)") as? String {
                if lInquired == "yes" {
                    cell.ivStamp.isHidden = false
                }
            }
        }
        
        let sqFtString = "\(dictProperty["lot_size"] ?? 0)"
        

        
        if sqFtString.count > 4 {
            let sqFtNumber = NSNumber.init(value: dictProperty["lot_size"] as? Int ?? 0)
            let sqFt = Utils.suffixNumber(sqFtNumber)
            cell.lblSQFt.text = ("\(sqFt)")
        }
        else {
            cell.lblSQFt.text = ("\(sqFtString)")
        }
        
        
        let bath = String(dictProperty["bath"] as! Int)
        let bed = String(dictProperty["bed"] as! Int)
        
        cell.lblBathrooms.text = bath
        cell.lblBedrooms.text = bed
        
        cell.btnLike.addTarget(self, action: #selector(PropertiesViewController.btnLike_Tapped(_:)), for: .touchUpInside)
        cell.btnLike.isSelected = false
        let isLiked = dictProperty["liked"] as! Bool
        if isLiked == true {
            cell.btnLike.isSelected = true
        }
        
        
//        cell.contentView.clipsToBounds = false
//        cell.clipsToBounds = false
//        
//        cell.superview?.superview?.clipsToBounds = false
//        cell.superview?.clipsToBounds = false
//        cell.backgroundView?.clipsToBounds = false
        cell.btnLike.tag = indexPath.row
        
        cell.viewGCIcons.isHidden = true
        
        cell.btnBook.isHidden = true
        
        if UserDefaults.standard.object(forKey: "token") != nil {

            let leaseTerm = dictProperty["lease_term"] as? String ?? ""
            if let userInfo = dictProperty["author_user_info"] as? [String: AnyObject] {
                if let userCID = UserDefaults.standard.object(forKey: "cid") as? String {
                    if leaseTerm == "short" && userInfo["cid"] as? String ?? "" != userCID {
                        cell.btnBook.isHidden = false;
                    }
                }
            }
        }
        else {
            let leaseTerm = dictProperty["lease_term"] as? String ?? ""
            if leaseTerm == "short" {
                cell.btnBook.isHidden = false;
            }
        }
        cell.btnBook.tag = indexPath.row
        cell.btnBook.addTarget(self, action: #selector(sendToBooking(_sender:)), for: .touchUpInside)   
        
        if let incentives = dictProperty["incentives"] as? [String: AnyObject] {
            if let giftCards = incentives["gift_card"] as? [AnyObject] {
                if giftCards.count > 0 {
                    cell.viewGCIcons.isHidden = false
                    for i in 0..<giftCards.count {
                        if i == 0 {
                            if let dictGC1 = giftCards[i] as? [String: AnyObject] {
                                let gc1ImageURL = dictGC1["image_url"] as! String
                                cell.imgGC1.sd_setImage(with: URL(string: gc1ImageURL))
                            }
                        }
                        else if i == 1 {
                            if let dictGC2 = giftCards[i] as? [String: AnyObject] {
                                let gc2ImageURL = dictGC2["image_url"] as! String
                                cell.imgGC2.sd_setImage(with: URL(string: gc2ImageURL))
                            }
                        }
                        else if i == 2 {
                            if let dictGC3 = giftCards[i] as? [String: AnyObject] {
                                let gc3ImageURL = dictGC3["image_url"] as! String
                                cell.imgGC3.sd_setImage(with: URL(string: gc3ImageURL))
                            }
                        }
                    }
                }
            }
        }

        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dictProperty = self.properties[indexPath.row] as! NSDictionary
        let propertyId = dictProperty["id"] as! Int
        if propertyId == 0 {
            if let linkURLString = dictProperty["link_url"] as? String {
                if let linkURL = URL(string: linkURLString) {
                    UIApplication.shared.openURL(linkURL)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listingToDetail" {
            let controller = segue.destination as! PropertyDetailViewController
            controller.propertyID = String(self.dictProperty["id"] as! Int)
            controller.dictProperty = self.dictProperty
            controller.isFromMainView = true
        }
        else if (segue.identifier == "listingToMap") {
            let controller = segue.destination as! PropertiesMapViewController
            controller.properties = self.properties
        }
        else if segue.identifier == "propertiesToSignup" {
            let controller = segue.destination as! SignUpViewController
            if AppDelegate.returnAppDelegate().deepMessageId == nil {
                if reqType != nil {
                    controller.propertyId = String(dictProperty["id"] as! Int)
                }
                controller.reqType = reqType
            }
            controller.delegate = self
        }
        else if segue.identifier == "propertiesVCToSearchProperties" {
            let controller = segue.destination as! SearchPropertiesViewController
            controller.delegate = self
        }
    }
    
    
    func didSelected(_ tag: NSInteger) {
        
        let _state = UInt(exactly: SVPullToRefreshStateStopped)!
        if self.tblProperties.pullToRefreshView.state != _state {
            return
        }
        
//        if self.tblProperties.pullToRefreshView.isHidden == false {
//            return
//        }
        
        self.dictProperty = self.properties[tag] as! NSDictionary
        
        
        //pDetailVC
        
        /*if self.detailController == nil {
         self.detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("pDetailVC") as? PropertyDetailViewController
         
         detailController!.propertyID = String(self.dictProperty["id"] as! Int)
         detailController?.dictProperty = self.dictProperty
         detailController?.isFromMainView = true
         self.visitedProperties.append((detailController?.propertyID)!)
         }
         else {
         let propertyID = String(self.dictProperty["id"] as! Int)
         detailController!.propertyID = propertyID
         if !self.visitedProperties.contains(propertyID) {
         self.detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("pDetailVC") as? PropertyDetailViewController
         detailController?.dictProperty = self.dictProperty
         detailController?.isFromMainView = true
         detailController!.propertyID = String(self.dictProperty["id"] as! Int)
         self.visitedProperties.append((detailController?.propertyID)!)
         }
         }*/
        
        AppDelegate.returnAppDelegate().isNewProperty = nil
        
        self.detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pDetailVC") as? PropertyDetailViewController
        
        detailController!.propertyID = String(self.dictProperty["id"] as! Int)
        detailController?.dictProperty = self.dictProperty
        detailController?.isFromMainView = true
        self.visitedProperties.append((detailController?.propertyID)!)
        
        self.navigationController?.pushViewController(self.detailController!, animated: true)
        
    }
    
    
    @IBAction func btnViewMap_Tapped(_ sender: AnyObject) {
        /**if mapController == nil {
            mapController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mapVC") as! PropertiesMapViewController
            mapController.properties = self.properties
            mapController.delegate = self
        }**/
        
        mapController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mapVC") as! PropertiesMapViewController
        mapController.properties = self.properties
        mapController.delegate = self
        
        UIView.transition(with: (self.navigationController?.view)!, duration: 0.5, options: .transitionFlipFromRight, animations: {
            self.navigationController?.pushViewController(self.mapController, animated: false)
        }) { (completed: Bool) in
            
        }
        
    }
    
    @IBAction func btnLike_Tapped(_ sender: AnyObject) {
        let btn = sender as! UIButton
        self.dictProperty = self.properties[btn.tag] as! NSDictionary
        self.selectedRow = btn.tag
        if UserDefaults.standard.object(forKey: "token") == nil {
            reqType = 2
            self.performSegue(withIdentifier: "propertiesToSignup", sender: self)
        }
        else {
            let propertyCell = self.tblProperties.cellForRow(at: IndexPath(row: self.selectedRow!, section: 0)) as! PropertyTableViewCell
            
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
                        let propertyCell = self.tblProperties.cellForRow(at: IndexPath(row: self.selectedRow!, section: 0)) as! PropertyTableViewCell
                        propertyCell.btnLike.isSelected = false
                        let _utils = Utils()
                        _utils.showOKAlert("Error:", message: dict!["message"] as! String, controller: self, isActionRequired: false)
                    }
                    
    
                }
                catch {
                    
                }
            }
            else {
                
                
                let propertyCell = self.tblProperties.cellForRow(at: IndexPath(row: self.selectedRow!, section: 0)) as! PropertyTableViewCell
                propertyCell.btnLike.isSelected = false
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                })
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
            }
        }.resume()
    }
    
    func didSignedUpSuccessfully() {
        showHideBottomBar()
        let propertyCell = self.tblProperties.cellForRow(at: IndexPath(row: self.selectedRow!, section: 0)) as! PropertyTableViewCell
        propertyCell.btnLike.isSelected = true
        self.properties = NSMutableArray()
        self.getProperties(self.originalURL)
        
    }
    
    func showHideBottomBar() -> Void {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
}

extension PropertiesViewController {
    func setUpInfiniteScroll() {
        self.tblProperties.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        
        // Set custom indicator margin
        self.tblProperties.infiniteScrollIndicatorMargin = 12
        
        self.tblProperties.setShouldShowInfiniteScrollHandler { (tableView) -> Bool in

            if self.lastPage != nil {
                if self.pageNumber <= self.lastPage! {
                    return true
                }
            }
            return false
        }
        
        // Add infinite scroll handler
        self.tblProperties.addInfiniteScroll { (tableView) in
            self.pageNumber = self.pageNumber + 1
            self.originalURL = "\(APIConstants.BasePath)/api/getproperty?page=\(self.pageNumber)"
            self.getProperties(self.originalURL)
        }

    }
}

//extension ViewController: UIScrollViewDelegate {
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let endScrolling = (scrollView.contentOffset.y + scrollView.frame.size.height)
//        if endScrolling >= scrollView.contentSize.height {
//            pageNumber = pageNumber + 1
//            if self.lastPage != nil {
//                if self.pageNumber <= self.lastPage! {
//                    originalURL = "\(APIConstants.BasePath)/api/getproperty?page=\(pageNumber)"
//                    self.getProperties(originalURL)
//                }
//
//            }
////            if nextURL != nil {
////                KVNProgress.show()
////
////                self.getProperties(nextURL!)
////            }
//        }
//    }
//}


extension PropertiesViewController: SearchPropertiesDelegate {
    func didPressedDoneButton(_ isAgent: Bool) {
        if isAgent == false {
            //KVNProgress.show()
            KVNProgress.show(withStatus: "Searching Properties")
            UserDefaults.standard.set(1, forKey: "searchType")
            self.createUserSearch()
            
        }
        else {
            UserDefaults.standard.set(2, forKey: "searchType")
            KVNProgress.show(withStatus: "Searching Properties")
            self.createAgentSearch()
        }
    }
}

extension PropertiesViewController: MapPropertiesDelegate {
    func didListingButtonTappe(_ properties: NSMutableArray) {
        
        if let selectedRegion = AppDelegate.returnAppDelegate().selectedSearchRegion {
            if selectedRegion.characters.count > 0 {
                let selectedRegionWithAbb = selectedRegion.replacingOccurrences(of: ", United States", with: "")
                self.lblHeaderTitle.text = selectedRegionWithAbb
            }
        }
        self.properties = properties
        DispatchQueue.main.async(execute: {
            if self.properties.count == 0 {
                self.tblProperties.isHidden = true
                self.lblMessage.isHidden = false
                self.viewNearMe.isHidden = false
                self.viewListingCount.isHidden = true
                self.viewListingCountBG.isHidden = true
            }
            else {
                self.tblProperties.isHidden = false
                self.lblMessage.isHidden = true
                self.viewNearMe.isHidden = true
                self.viewListingCount.isHidden = false
                self.viewListingCountBG.isHidden = false
            }
            self.tblProperties.reloadData()
        })
    }
}

extension PropertiesViewController {
    func getUserGeneralInfo() -> Void {
        
        
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getusergeneral?token=\(token)&source=dts")
        }
        
        if strURL.characters.count == 0 {
            return
        }
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
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
                            
                    let dictUserGeneral = tempData!["data"] as! NSDictionary
                    let dwollaCustomerStatus = dictUserGeneral["dwolla_customer_status"] as? String
                    if dwollaCustomerStatus != nil {
                        AppDelegate.returnAppDelegate().dwollaCustomerStatus = dwollaCustomerStatus
                        self.getPaymentMethods()
                    }
                    
                }
                catch {
                    
                }
            }
            else {
//                dispatch_async(dispatch_get_main_queue(), {
//                    KVNProgress.dismiss()
//                })
//                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                
            }
        }.resume()
    }
    
    func getPaymentMethods() {
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getuserpayment?token=\(token)")
        }
        
        
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)

        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let result = json as? NSDictionary
                    
                    let isSuccess = result!["success"] as! Bool
                    
                    if isSuccess == false {
                        
                        DispatchQueue.main.async(execute: {
//                            KVNProgress.dismiss()
//                            let _utils = Utils()
//                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        
                        return
                    }
                    
                    
                    let paymentMethods = (result!["data"] as! NSDictionary)["ach"] as! [AnyObject]
                    
                    AppDelegate.returnAppDelegate().paymentMethods = []
                    
                    
                    for dictPaymentMethod in paymentMethods {
                        if let accountVerified = (dictPaymentMethod as! NSDictionary)["status"] as? String {
                            if accountVerified == "verified" {
                                AppDelegate.returnAppDelegate().paymentMethods.append(dictPaymentMethod)
                            }
                        }
                    }
                    
                    
                }
                catch {
                    
                }
            }
//            else {
//                dispatch_async(dispatch_get_main_queue(), {
//                    KVNProgress.dismiss()
//                })
//                
//            }
        }.resume()
    }
}

extension PropertiesViewController {
    func getAd() -> Void {
        
        self.isFromSearch = false
        
        countDown = 3
        
        DispatchQueue.main.async(execute: {
            self.constraintViewAdTop.constant -= self.view.frame.height
            self.viewAd.isHidden = true
            self.btnSkip.alpha = 0
            
            self.btnSkip.setTitle("SKIP 3", for: .normal)
        })
        
        //KVNProgress.show()
        var strURL = "\(APIConstants.BasePath)/api/getad?&token=\(DTSConstants.Constants.guestToken)&type=interstitial&state=NY"
        if let zipCode = UserDefaults.standard.value(forKey: "adZip") as? String {
            strURL = "\(APIConstants.BasePath)/api/getad?&token=\(DTSConstants.Constants.guestToken)&type=interstitial&zip=\(zipCode)"
        }
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = "\(APIConstants.BasePath)/api/getad?&token=\(token)&type=interstitial&state=NY"
            if let zipCode1 = UserDefaults.standard.value(forKey: "adZip") as? String {
                strURL = "\(APIConstants.BasePath)/api/getad?&token=\(token)&type=interstitial&zip=\(zipCode1)"
            }
        }
        
        print("ad url: \(strURL)")
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
//                    DispatchQueue.main.async(execute: {
//                        KVNProgress.dismiss()
//                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let tempData = json as? NSDictionary
                    if tempData != nil {
                        if tempData!["error"] as? String != nil {
                            let error = tempData!["error"] as! String
                            if error == "user not found" {
                                UserDefaults.standard.set(nil, forKey: "token")
                                AppDelegate.returnAppDelegate().logOut()
                                return
                            }
                        }
                    }
                    let isSuccess = tempData!["success"] as! Bool//tempData!["success"] as! Bool
                    
                    if isSuccess == false {
                        
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        
                        return
                    }
                    
                    if let mainData = tempData!["data"] as? NSDictionary {
                        self.adURL = mainData["url"] as? String
                        let dictImg = mainData["img_url"] as? NSDictionary
                        
                        let strImageURL = dictImg?["raw"] as! String
                        let imgURL = URL(string: strImageURL)
                        
                        self.img.sd_setImage(with: imgURL!, completed: { (recImage, error, cacheType, url) in
                            
                            DispatchQueue.main.async(execute: {
                                KVNProgress.dismiss()
                            })
                            self.viewAd.isHidden = false
                            
                            
                            UIView.animate(withDuration: 1, animations: {
                                if UserDefaults.standard.object(forKey: "token") != nil {
                                    //self.viewAd.center = CGPoint(x: self.view.frame.width/2, y: (self.view.frame.height/2) - 29)
                                    self.constraintViewAdTop.constant = 0
                                    self.view.layoutIfNeeded()
                                }
                                else {
                                    //self.viewAd.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
                                    self.constraintViewAdTop.constant = 0
                                    self.view.layoutIfNeeded()
                                }
                                
                            }, completion: { (completed) in
                                UIView.animate(withDuration: 0.5, animations: {
                                    self.btnSkip.alpha = 1
                                    
                                }, completion: { (completed) in
                                    self.timer = Timer.scheduledTimer(timeInterval: 1.2, target: self, selector: #selector(self.countDown(timer:)), userInfo: nil, repeats: true)
                                })
                            })
                            
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

extension PropertiesViewController {
    
    func presentSignup() {
        
    }
    
    func getMessage() -> Void {
        
        self.tabBarController?.selectedIndex = 0
        
        if AppDelegate.returnAppDelegate().deepMessageId == nil {
            return
        }
        
        if UserDefaults.standard.object(forKey: "token") == nil {
            self.performSegue(withIdentifier: "propertiesToSignup", sender: self)
            return
        }
        
        //KVNProgress.show()
        var strURL = "\(APIConstants.BasePath)/api/getmsg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjI2MTc5LCJpc3MiOiJodHRwczpcL1wvYXBpLmRpdGNodGhlLnNwYWNlXC9hcGlcL3JlZ2lzdGVydXNlciIsImlhdCI6MTQ5NzU0Nzk1NywiZXhwIjoxNTkwODU5OTU3LCJuYmYiOjE0OTc1NDc5NTcsImp0aSI6Ijk4ZmE5MTNlM2Y3MzgyZmQ3MTYyM2U2YzY3YWIzNmU4In0.J9nVYswZSXq5mQ7FbmP6z6pm1yUil-osp-q27J1AXrY&msg_id=\(AppDelegate.returnAppDelegate().deepMessageId!)&type=thread&paginated=0&page=1"
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getmsg?token=\(token)&msg_id=\(AppDelegate.returnAppDelegate().deepMessageId!)&type=thread&paginated=0&page=1")
        }
        
        AppDelegate.returnAppDelegate().deepMessageId = nil
        
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
                    
                    let parentMessages =  (tempData!["data"] as! NSDictionary)["thread"] as! NSArray
                    let dictProperty = parentMessages[0] as! NSDictionary
                    let messages = dictProperty["msgs"] as! NSArray
                    let dictMessage = messages[0] as! NSDictionary
                    
                    DispatchQueue.main.async(execute: {
                        
                        if dictMessage["type"] as! String == "doc_sign" {
                            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "docMessageVC") as! DocMessageViewController
                            controller.dictSelectedMessage = dictMessage
                            controller.isFromSignature = false
                            controller.dictProperty = dictProperty
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                        else if dictMessage["type"] as! String == "demo" {
                            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "demoVC") as! DemoMessageViewController
                            controller.dictSelectedMessage = dictMessage
                            controller.dictProperty = dictProperty
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                        else if dictMessage["type"] as! String == "inquire" {
                            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "followupVC") as! FollowUpViewController
                            controller.dictSelectedMessage = dictMessage
                            controller.dictProperty = dictProperty
                            controller.isInquired = true
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                        else {
                            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "followupVC") as! FollowUpViewController
                            controller.dictSelectedMessage = dictMessage
                            controller.dictProperty = dictProperty
                            controller.isInquired = false
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
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
    
    func getUserKeyWithNotificatoin() -> Void {
        DispatchQueue.main.async(execute: {
            let searchTitle = "\(self.lblHeaderTitle.text!)\nSearch Results"
            self.lblHeaderTitle.text = nil
            self.lblHeaderTitle.font = UIFont(name: "HelveticaNeue", size: 19)
            let zipFont = UIFont(name: "HelveticaNeue", size: 14)
            let title = NSMutableAttributedString(string: searchTitle)
            title.setFontForText("Search Results", with: zipFont)
            self.lblHeaderTitle.attributedText = title
        })
        
        self.getAd()
            //KVNProgress.show()
        getUserSearchByKey()
    }
    
    func getUserSearchByKey() -> Void {
        
//    KVNProgress.show()
        
        var strURL = "\(APIConstants.BasePath)/api/getsearchresults?token=\(DTSConstants.Constants.guestToken)&type=user_searches&search_agent=0&key=\(AppDelegate.returnAppDelegate().deepSAKey!)"
        
        
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getsearchresults?token=\(token)&type=user_searches&search_agent=0&key=\(AppDelegate.returnAppDelegate().deepSAKey!)")
        }

        AppDelegate.returnAppDelegate().deepSAKey = nil
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                        //self.refreshControl.endRefreshing()
                        self.tblProperties.pullToRefreshView.stopAnimating()
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
                                                else if dictPropertyFields["id"] as! Int == 0 {
                                                    self.properties.add(dictPropertyFields)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    //var i = 0
                    
                    
                    
                    
                    DispatchQueue.main.async(execute: {
                        //self.refreshControl.endRefreshing()
                        self.tblProperties.pullToRefreshView.stopAnimating()
                        KVNProgress.dismiss()
                        if self.properties.count == 0 {
                            self.tblProperties.isHidden = true
                            self.lblMessage.isHidden = false
                            self.viewNearMe.isHidden = false
                            self.viewListingCount.isHidden = true
                            self.viewListingCountBG.isHidden = true
                        }
                        else {
                            self.tblProperties.isHidden = false
                            self.lblMessage.isHidden = true
                            self.viewNearMe.isHidden = true
                            self.viewListingCount.isHidden = false
                            self.viewListingCountBG.isHidden = false
                        }
                        self.tblProperties.reloadData()
                        self.tblProperties.setContentOffset(CGPoint.zero, animated: false)
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
            }.resume()
    }
}

extension PropertiesViewController: StatesViewControllerDelegate {
    func didStateSelected() {
        self.getPropertiesForSelectedState()
    }
}

extension PropertiesViewController {
    func sendToBooking(_sender: UIButton) {
        if UserDefaults.standard.object(forKey: "token") != nil {
            self.dictProperty = self.properties[_sender.tag] as! NSDictionary
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "bookingVC") as! BookingViewController
            controller.dictProperty = self.dictProperty as! [String : AnyObject]!
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else {
            reqType = nil
            self.performSegue(withIdentifier: "propertiesToSignup", sender: self)
        }
        
    }
}

extension PropertiesViewController: QRReaderDelegate {
    func didCancelTappedForQRReader() {
        
    }
    
    func didFoundQRCode(_ qrCode: String) {
        AppDelegate.returnAppDelegate().isNewProperty = nil
        
        self.detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pDetailVC") as? PropertyDetailViewController
        detailController!.propertyID = qrCode
        detailController?.isFromMainView = nil
        self.navigationController?.popToRootViewController(animated: false)
        self.navigationController?.pushViewController(self.detailController!, animated:false)
    }
}






