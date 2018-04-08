//
//  CollectionViewDataSource.swift
//  DTS-iOS
//
//  Created by Viktor on 03/11/2016.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

typealias ScrollViewScrolled = (UIScrollView) -> ()

class CollectionViewDataSource: NSObject {
    
    var items : Array<AnyObject>?
    var cellIdentifier : String?
    var collectionView  : UICollectionView?
    var cellHeight : CGFloat = 0.0
    var cellWidth : CGFloat = 0.0
    var scrollViewListener : ScrollViewScrolled?
    var configureCellBlock : ListCellConfigureBlock?
    var aRowSelectedListener : DidSelectedRow?
    
    init (items : Array<AnyObject>?  , collectionView : UICollectionView? , cellIdentifier : String? , cellHeight : CGFloat , cellWidth : CGFloat  , configureCellBlock : ListCellConfigureBlock  , aRowSelectedListener :  DidSelectedRow , scrollViewListener : ScrollViewScrolled)  {
        super.init()
        self.collectionView = collectionView
        self.items = items
        self.cellIdentifier = cellIdentifier
        self.cellWidth = cellWidth
        self.cellHeight = cellHeight
        self.configureCellBlock = configureCellBlock
        self.aRowSelectedListener = aRowSelectedListener
        self.scrollViewListener = scrollViewListener
    }
    
    override init() {
        super.init()
    }
    
}

extension CollectionViewDataSource : UICollectionViewDelegate , UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let identifier = cellIdentifier else{
            fatalError("Cell identifier not provided")
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as UICollectionViewCell
        
        
        if let block = self.configureCellBlock , let item: AnyObject = self.items?[indexPath.row]{
            block(cell: cell , item: item , indexPath: indexPath as NSIndexPath?)
        }
        return cell
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAt indexPath: NSIndexPath) {
        if let block = self.aRowSelectedListener{
            block(indexPath: indexPath as NSIndexPath)
        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let block = scrollViewListener {
            block(scrollView)
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: NSIndexPath) -> CGSize{
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.frame.size.width - cellWidth * (items?.count.toCGFloat)!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        print(collectionView.frame.size.width , cellWidth)
        let size = collectionView.frame.size.width - cellWidth * (items?.count.toCGFloat)!
        return size/((items?.count.toCGFloat)! - 1.0)
    }*/
    
    
}

