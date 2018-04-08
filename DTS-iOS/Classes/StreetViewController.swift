//
//  StreetViewController.swift
//  DTS-iOS
//
//  Created by mac on 11/8/16.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreMotion

class StreetViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var streetView: GMSPanoramaView!
    @IBOutlet weak var flickButton: UIButton!
    @IBOutlet weak var mapChangeButton: UIButton!
    
    
    var lat = 0.0
    var long = 0.0
    var isStreetView = false
    var isFlick = false
    
    var orientation : GMSOrientation!
    var motionManager = CMMotionManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        showStreeView()
        startGryo()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showStreeView() {
        self.mapView.isHidden = true
        self.streetView.isHidden = false
        self.streetView.moveNearCoordinate(CLLocationCoordinate2D(latitude: lat, longitude: long))
        
        self.mapChangeButton.setBackgroundImage(UIImage(named: "ico-streetview-flatmap"), for: UIControlState())
        
    }
    
    func showMapView() {
        self.mapView.isHidden = false
        self.streetView.isHidden = true
        let camera = GMSCameraPosition.camera(withLatitude: lat,
                                                          longitude: long, zoom: 16)
        self.mapView.camera = camera
        let position = CLLocationCoordinate2DMake(lat, long)
        let marker = GMSMarker(position: position)
        marker.map = self.mapView
        
        self.mapChangeButton.setBackgroundImage(UIImage(named: "ico-streetview-streetmap"), for: UIControlState())
    }
    
    @IBAction func changeMap(_ sender: AnyObject) {
        if isStreetView {
            showStreeView()
        } else{
            showMapView()
        }
        
        isStreetView = !isStreetView
        
    }
    
    @IBAction func changeFlick(_ sender: AnyObject) {
        
        if isFlick {
            self.flickButton.setBackgroundImage(UIImage(named: "ico-streetview-flickpan-on"), for: UIControlState())
            self.streetView.setAllGesturesEnabled(true)
            self.mapView.isUserInteractionEnabled = true
            
        } else{
            self.flickButton.setBackgroundImage(UIImage(named: "ico-streetview-flickpan"), for: UIControlState())
            self.streetView.setAllGesturesEnabled(false)
            self.mapView.isUserInteractionEnabled = false
            if orientation != nil {
                self.streetView.animate(to: GMSPanoramaCamera(orientation: orientation, zoom: 1.0), animationDuration: 0)
            }
            
        }
        
        isFlick = !isFlick
    }
    
    func startGryo()  {
        
        var delta = 0.0
        var y = 0.0
        
        if self.motionManager.isGyroAvailable {
            
            if !self.motionManager.isGyroActive {
                
                self.motionManager.startGyroUpdates(to: OperationQueue.main, withHandler: { (data, error) in
                    
                    let currentY = (data?.rotationRate.y)!
                    
                    delta = currentY - y
                    
                    if fabs(delta) >= 0.01{
                        let updatedCamera = GMSPanoramaCameraUpdate.rotate(by: -CGFloat(currentY))
                        self.orientation = GMSOrientation(heading: CLLocationDirection(currentY), pitch: 0)
                        
                        if self.isFlick {
                            self.streetView.updateCamera(updatedCamera, animationDuration: 0)
                            
                        }
                        
                        y = currentY
                    }
                    
                })
            }
        }
    }
    
    
    @IBAction func changeFullScreen(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
