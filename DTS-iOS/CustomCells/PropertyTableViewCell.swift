    //
//  PropertyTableViewCell.swift
//  DTS-iOS
//
//  Created by Viktor on 04/04/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import QuartzCore

protocol PropertyTableViewCellDelegate {
    func didSelected(_ tag: NSInteger)
}

class PropertyTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var btnBook: UIButton!
    @IBOutlet weak var imgGC3: UIImageView!
    @IBOutlet weak var viewGCIcons: UIView!
    @IBOutlet weak var imgGC2: UIImageView!
    @IBOutlet weak var imgGC1: UIImageView!
    @IBOutlet weak var lblSquarFeetCaption: UILabel!
    @IBOutlet weak var lblBathCaption: UILabel!
    @IBOutlet weak var lblBedCaptions: UILabel!
    @IBOutlet weak var lblSQFt: UILabel!
    @IBOutlet weak var imgViewNewTop: UIImageView!
    @IBOutlet weak var ivStamp: UIImageView!
    @IBOutlet weak var lblBathrooms: UILabel!
    @IBOutlet weak var lblBedrooms: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var cvBG: UICollectionView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var viewCounter: UIView!
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var ivBG: UIImageView!
    var delegate: PropertyTableViewCellDelegate?
    var bgImages: [AnyObject] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadImages(_ images: NSArray) -> Void {
        self.bgImages = images as [AnyObject]
        self.cvBG.reloadData()
    }
    
    func maskImage(_ image:UIImage, mask:(UIImage))->UIImage{
        
        let imageReference = image.cgImage
        let maskReference = mask.cgImage
        
        let imageMask = CGImage(maskWidth: maskReference!.width,
                                          height: maskReference!.height,
                                          bitsPerComponent: maskReference!.bitsPerComponent,
                                          bitsPerPixel: maskReference!.bitsPerPixel,
                                          bytesPerRow: maskReference!.bytesPerRow,
                                          provider: maskReference!.dataProvider!, decode: nil, shouldInterpolate: true)
        
        let maskedReference = imageReference!.masking(imageMask!)
        
        let maskedImage = UIImage(cgImage:maskedReference!)
        
        return maskedImage
    }
    
    // Mark: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 300)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bgImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bgCell", for: indexPath) as! BgCollectionViewCell
        let dictImage = self.bgImages[indexPath.row] as! NSDictionary
        let imgURL = (dictImage["img_url"] as! NSDictionary)["md"] as! String
        let imageURL = URL(string: imgURL)
        cell.imgView.contentMode = .scaleAspectFill
        cell.imgView.sd_setImageWithURLWithFade(url: imageURL, placeholderImage: UIImage(named: "temp_placeholder.jpg"))
        //cell.imgView.image = UIImage(named: "temp_placeholder.png")
        
        //cell.imgView.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage(named: "main_placeholder.png"))
        
        //cell.imgView.layoutIfNeeded()
        cell.imgView.backgroundColor = UIColor(hexString: "191919")
        //cell.imgView.setNeedsDisplay()
        
        
        
        cell.superview?.superview?.clipsToBounds = false
        cell.superview?.clipsToBounds = false
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = self.cvBG.contentOffset.x
        let w = self.cvBG.bounds.size.width
        let currentPage = Int(ceil(x/w))
        print("Current Page: \(currentPage)")
        self.lblCounter.text = ("\(currentPage + 1)/\(self.bgImages.count)")
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.delegate != nil {
            self.delegate?.didSelected(self.tag)
        }
    }
    

}
    

