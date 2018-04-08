//
//  StatesViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 19/09/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import CoreLocation

protocol StatesViewControllerDelegate {
    func didStateSelected()
}

class StatesViewController: UIViewController {
    
    var delegate: StatesViewControllerDelegate?

    @IBAction func stateButtonTapped(_ sender: Any) {
        switch (sender as! UIButton).tag {
        case 10:
            AppDelegate.returnAppDelegate().selectedCoordinates = CLLocationCoordinate2DMake(40.774777, -73.956332)
            AppDelegate.returnAppDelegate().defaultRegion = "New York, NY"
        case 11:
            AppDelegate.returnAppDelegate().selectedCoordinates = CLLocationCoordinate2DMake(27.678074, -81.532440)
            AppDelegate.returnAppDelegate().defaultRegion = "Miami, FL"
        case 12:
            AppDelegate.returnAppDelegate().selectedCoordinates = CLLocationCoordinate2DMake(34.054124, -118.243362)
            AppDelegate.returnAppDelegate().defaultRegion = "Los Angeles, CA"
        case 13:
            AppDelegate.returnAppDelegate().selectedCoordinates = CLLocationCoordinate2DMake(33.748547, -84.391502)
            AppDelegate.returnAppDelegate().defaultRegion = "Atlanta, GA"
        case 14:
            AppDelegate.returnAppDelegate().selectedCoordinates = CLLocationCoordinate2DMake(29.760395, -95.369871)
            AppDelegate.returnAppDelegate().defaultRegion = "Houston, TX"
        default:
            AppDelegate.returnAppDelegate().selectedCoordinates = CLLocationCoordinate2DMake(39.951060, -75.165620)
            AppDelegate.returnAppDelegate().defaultRegion = "Philadelphia, PA"
        }
        if self.delegate != nil {
            self.delegate?.didStateSelected()
            self.navigationController?.popViewController(animated: false)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
