//
//  DetailBGCollectionViewCell.swift
//  DTS-iOS
//
//  Created by Viktor on 27/10/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

var MAXIMUM_SCALE: CGFloat = 3.0
var MINIMUM_SCALE: CGFloat = 1.0

class DetailBGCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgView: UIImageView!
    
    func setUp() -> Void {
//        let pinchGestureReconizer = UIPinchGestureRecognizer(target: self, action: #selector(self.zoomImage(_:)))
//        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.zoomOutImage))
//        doubleTapGesture.numberOfTapsRequired = 2
//        self.imgView.gestureRecognizers = [pinchGestureReconizer, doubleTapGesture]
        //self.scrollView.scrollEnabled = true
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 5
        self.scrollView.delegate = self
        
        self.scrollView.isUserInteractionEnabled = true
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(PropertyDetailTableViewCell.zoom(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTap)
    
        
    }
}

extension DetailBGCollectionViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
}

extension DetailBGCollectionViewCell {
    func zoom(_ tapGesture: UITapGestureRecognizer) {
        if (self.scrollView!.zoomScale == self.scrollView!.minimumZoomScale) {
            let center = tapGesture.location(in: self.scrollView!)
            let size = self.imgView!.image!.size
            let zoomRect = CGRect(x: center.x, y: center.y, width: (size.width / 3), height: (size.height / 3))
            self.scrollView!.zoom(to: zoomRect, animated: true)
        } else {
            self.scrollView!.setZoomScale(self.scrollView!.minimumZoomScale, animated: true)
        }
    }
    
    
}
