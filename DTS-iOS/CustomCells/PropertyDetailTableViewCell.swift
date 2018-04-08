//
//  PropertyDetailTableViewCell.swift
//  DTS-iOS
//
//  Created by Viktor on 27/10/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit

class PropertyDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ivBG: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 5
        self.scrollView.delegate = self
        self.scrollView.isUserInteractionEnabled = true
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(PropertyDetailTableViewCell.zoom(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTap)
        
    }
    
    func zoom(_ tapGesture: UITapGestureRecognizer) {
        if (self.scrollView!.zoomScale == self.scrollView!.minimumZoomScale) {
            let center = tapGesture.location(in: self.scrollView!)
            let size = self.ivBG!.image!.size
            let zoomRect = CGRect(x: center.x, y: center.y, width: (size.width / 3), height: (size.height / 3))
            self.scrollView!.zoom(to: zoomRect, animated: true)
        } else {
            self.scrollView!.setZoomScale(self.scrollView!.minimumZoomScale, animated: true)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension PropertyDetailTableViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.ivBG
    }
}
