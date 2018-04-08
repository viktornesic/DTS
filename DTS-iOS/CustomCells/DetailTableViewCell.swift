//
//  DetailTableViewCell.swift
//  DTS-iOS
//
//  Created by Viktor on 04/04/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreMotion
import SDWebImage

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var imgGC3: UIImageView!
    @IBOutlet weak var viewGCIcons: UIView!
    @IBOutlet weak var imgGC2: UIImageView!
    @IBOutlet weak var imgGC1: UIImageView!
    @IBOutlet weak var lblCaptionMoveInCost: UILabel!
    @IBOutlet weak var lblCaptionSecDeposit: UILabel!
    @IBOutlet weak var lblMoveInCost: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblSecurityDeposit: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var lblSqrFeetCaption: UILabel!
    @IBOutlet weak var lblBathCaption: UILabel!
    @IBOutlet weak var lblBedCaption: UILabel!
    @IBOutlet weak var lblAddressLine2: UILabel!
    @IBOutlet weak var viewDetail: UIView!
    @IBOutlet weak var lblprice: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblBeds: UILabel!
    @IBOutlet weak var lblBaths: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var cvBG: UICollectionView!
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var viewCounter: UIView!
    
    var isUCLPreview: Bool?
    var bgImages: [AnyObject] = []
    var lat = 0.0
    var long = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    func showMap() -> Void {
        let camera = GMSCameraPosition.camera(withLatitude: lat,
                                                          longitude: long, zoom:16)
        self.mapView.camera = camera
        let position = CLLocationCoordinate2DMake(lat, long)
        let marker = GMSMarker(position: position)
        marker.map = self.mapView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension DetailTableViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bgImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bgCell", for: indexPath) as! DetailBGCollectionViewCell
        
        cell.setUp()
        
        if isUCLPreview == nil {
            let dictImage = self.bgImages[indexPath.row] as! NSDictionary
            let dictImages = dictImage["img_url"] as! [String: AnyObject]
            let imgURL = dictImages["md"] as! String
            cell.imgView.sd_setImage(with: URL(string: imgURL))
        }
        else {
            cell.imgView.image = self.bgImages[indexPath.row] as? UIImage
        }

        
        cell.imgView.setNeedsDisplay()
        cell.imgView.clipsToBounds = true
        //        self.lblCounter.text = ("\(indexPath.item + 1)/\(self.bgImages.count)")
        
        
        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = self.cvBG.contentOffset.x
        let w = self.cvBG.bounds.size.width
        let currentPage = Int(ceil(x/w))
        print("Current Page: \(currentPage)")
        self.lblCounter.text = ("\(currentPage + 1)/\(self.bgImages.count)")

    }
}

extension DetailTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
}


