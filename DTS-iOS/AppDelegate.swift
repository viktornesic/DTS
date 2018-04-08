//
//  AppDelegate.swift
//  DTS-iOS
//
//  Created by Viktor on 03/04/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    //AIzaSyBwvGipc4kG7ooW34tGyZUsriVLtHxRknI
//    let GOOGLE_MAP_KEY = "AIzaSyCtUEVMmGY37NtZYafPkgFrvXa3fkxAuLY"
    let GOOGLE_MAP_KEY = "AIzaSyAsBowuQdO6hrk6pAtsshgvTcIBwMWWCv4"
//    let GOOGLE_MAP_KEY = "AIzaSyBwvGipc4kG7ooW34tGyZUsriVLtHxRknI"
    
    var btnSkip: UIButton!
    var window: UIWindow?
    var cachedImages: NSMutableDictionary!
    var likedProperies: NSMutableDictionary!
    var showAnimation: Bool!
    var isFromSignUp: Bool!
    var player: AVPlayer?
    var playerController: AVPlayerViewController?
    var totalRows: NSInteger!
    var isBack: Bool!
    var selectedParent = -1
    var selectedIndex = -1
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var userProperty: NSMutableDictionary!
    var uclTitle: String!
    var isNewProperty: Bool?
    var newlyCreatedPropertyId: Int!
    var propertyPhotos: NSArray?
    var arrSearchCriteria: NSMutableArray!
    var presentedRow = -1
    var selectedSearchRegion: String?
    var selectedCoordinates: CLLocationCoordinate2D?
    var selectedZip: String?
    var isAppLoading = true
    var properties = NSMutableArray()
    var isSearchPull = false
    var currentAddress: String?
    var dwollaCustomerStatus: String?
    var paymentMethods: [AnyObject] = []
    var deepMessageId: String?
    var universalLinkType: String?
    var deepSAKey: String?
    var adZip: String?
    var hardcodedProperty: [String: AnyObject]!
    var defaultRegion: String?
    var selectedProperty: NSDictionary?
//    var updateLocatoinFired = false
    var inquiredProperty: NSMutableDictionary!
    var dlPropertyId: String!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        isBack = false
        self.selectedSearchRegion = ""
        
        self.defaultRegion = "New York, NY"
        self.selectedCoordinates = CLLocationCoordinate2DMake(40.774777, -73.956332)
        
        self.currentLocation = CLLocation(latitude: (self.selectedCoordinates?.latitude)!, longitude: (self.selectedCoordinates?.longitude)!)
        
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.distanceFilter = 100.0
        
        if self.locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) == true {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        self.locationManager.startUpdatingLocation()
        
        self.totalRows = 0
        self.cachedImages = NSMutableDictionary()
        self.likedProperies = NSMutableDictionary()
        self.showAnimation = true
        self.isFromSignUp = false
        if UserDefaults.standard.object(forKey: "token") != nil {
            self.UpdateRootVC()
        }
//        else {
//            let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainChildNav") as! UINavigationController
//            AppDelegate.returnAppDelegate().window?.rootViewController = navVC
//        }
        
        UIApplication.shared.keyWindow?.backgroundColor = UIColor.green
        

        GMSServices.provideAPIKey(GOOGLE_MAP_KEY)
        GMSPlacesClient.provideAPIKey(GOOGLE_MAP_KEY)
        
        Fabric.with([Crashlytics.self])
        
        return true
    }
    
    
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let uninversalLink = userActivity.webpageURL?.absoluteString {
            if uninversalLink.contains("msg_id") {
                let universalLinkParts = uninversalLink.components(separatedBy: "=")
                self.deepMessageId = universalLinkParts.last
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "universalLInk"), object: nil)
            }
            else if uninversalLink.contains("key") {
                let universalLinkParts = uninversalLink.components(separatedBy: "=")
                self.deepSAKey = universalLinkParts.last
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "universalLinkSA"), object: nil)
            }
            else if uninversalLink.contains("myparam") {
                let landingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ctaNavigator") as! UINavigationController
                AppDelegate.returnAppDelegate().window?.rootViewController = landingVC
            }
            else if uninversalLink.lowercased().contains("propertyid") {
                let universalLinkParts = uninversalLink.components(separatedBy: "=")
                self.dlPropertyId = universalLinkParts.last
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "universalLinkPD"), object: nil)
            }

        }
        return true
    }
    
    
    func logOut() -> Void {
        //navVC
        let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainChildNav") as! UINavigationController
        AppDelegate.returnAppDelegate().window?.rootViewController = navVC
    }
    
    func UpdateRootVC() -> Void {
        //revealVC
        let tabbarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabbarVC") as! UITabBarController
        AppDelegate.returnAppDelegate().window?.rootViewController = tabbarVC

    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    class func returnAppDelegate() ->AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations[0]
    
        
        if UserDefaults.standard.bool(forKey: "updateLocatoinFired") == false {
            UserDefaults.standard.set(true, forKey: "updateLocatoinFired")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateLocationFired"), object: self.currentLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "defaultLocationFired"), object: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "defaultLocationFired"), object: nil)
    }

}

