//
//  BidViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 02/07/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit

class BidViewController: UIViewController {

    @IBOutlet weak var cvBG: UICollectionView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblAddress1: UILabel!
    @IBOutlet weak var lblAddress2: UILabel!
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var btnSideMenu: UIButton!
    
    var property: [String: AnyObject]!
    var bgImages: [AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let revealController = revealViewController()
        revealController?.panGestureRecognizer().isEnabled = false
        revealController?.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        
        self.bgImages = AppDelegate.returnAppDelegate().hardcodedProperty["imgs"] as! [AnyObject]
        
        let x = self.cvBG.contentOffset.x
        let w = self.cvBG.bounds.size.width
        let currentPage = Int(ceil(x/w))
        self.lblCounter.text = ("\(currentPage + 1)/\(self.bgImages.count)")
        
        let price = String(AppDelegate.returnAppDelegate().hardcodedProperty["price"] as! Int)
        
        if price.characters.count > 4 {
            let priceNumber = NSNumber.init(value: AppDelegate.returnAppDelegate().hardcodedProperty["price"] as! Int)
            let price = Utils.suffixNumber(priceNumber)//String(dictProperty["price"] as! Int)
            self.lblPrice.text = ("$\(price)/\(AppDelegate.returnAppDelegate().hardcodedProperty["term"]!)")
        }
        else {
            self.lblPrice.text = ("$\(price)/\(AppDelegate.returnAppDelegate().hardcodedProperty["term"]!)")
        }
        
        self.lblAddress1.text = "\((AppDelegate.returnAppDelegate().hardcodedProperty["address1"] as! String).capitalized)"
        self.lblAddress2.text = "\((AppDelegate.returnAppDelegate().hardcodedProperty["city"] as! String).capitalized), \((AppDelegate.returnAppDelegate().hardcodedProperty["state_or_province"] as! String).uppercased()), \((AppDelegate.returnAppDelegate().hardcodedProperty["zip"] as! String).capitalized)"
    }

    @IBAction func placeBidButtonTapped(_ sender: Any) {
        let confirmBidVC = UIStoryboard(name: "Auction", bundle: nil).instantiateViewController(withIdentifier: "confirmBidVC") as! ConfirmBidViewController
        confirmBidVC.originalPrice = String(AppDelegate.returnAppDelegate().hardcodedProperty["price"] as! Int)
        self.navigationController?.pushViewController(confirmBidVC, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension BidViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bgImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bgCell", for: indexPath) as! DetailBGCollectionViewCell
        
        let dictImage = self.bgImages[indexPath.row] as! NSDictionary
        let dictImages = dictImage["img_url"] as! [String: AnyObject]
        let imgURL = dictImages["md"] as! String
        cell.imgView.sd_setImage(with: URL(string: imgURL))
        
        
        cell.imgView.setNeedsDisplay()
        cell.imgView.clipsToBounds = true
        
        
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

extension BidViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
}
