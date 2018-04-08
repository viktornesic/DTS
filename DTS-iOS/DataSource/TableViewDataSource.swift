//
//  TableViewDataSource.swift
//  DTS-iOS
//
//  Created by Viktor on 03/11/2016.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

typealias  ListCellConfigureBlock = (cell : AnyObject , item : AnyObject? , indexPath : NSIndexPath?) -> ()
typealias  DidSelectedRow = (indexPath : NSIndexPath) -> ()

class TableViewDataSource: NSObject {
    
    
    var items : Array<AnyObject>?
    var cellIdentifier : String?
    var tableView  : UITableView?
    var tableViewRowHeight : CGFloat = 44.0
    var configureCellBlock : ListCellConfigureBlock?
    var aRowSelectedListener : DidSelectedRow?
    
    init (items : Array<AnyObject>? , height : CGFloat , tableView : UITableView? , cellIdentifier : String?  , configureCellBlock : ListCellConfigureBlock? , aRowSelectedListener : DidSelectedRow) {
        
        self.tableView = tableView
        
        self.items = items
        
        self.cellIdentifier = cellIdentifier
        
        self.tableViewRowHeight = height
        
        self.configureCellBlock = configureCellBlock
        
        self.aRowSelectedListener = aRowSelectedListener
        
    }
    
    
    override init() {
        
        super.init()
        
    }
    
}



extension TableViewDataSource : UITableViewDelegate , UITableViewDataSource{
    
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let identifier = cellIdentifier else{
            
            fatalError("Cell identifier not provided")
            
        }
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as UITableViewCell
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(red: 255.0/255, green: 255.0/255, blue:     255.0/255.0, alpha: 0.0)
        cell.selectedBackgroundView = selectedView
        
        //   cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if let block = self.configureCellBlock , let item: AnyObject = self.items?[indexPath.row]{
            block(cell: cell , item: item ,indexPath: indexPath as NSIndexPath?)
            
        }
        
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let block = self.aRowSelectedListener{
            block(indexPath: indexPath as NSIndexPath)
        }
    }
    
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    
    
    
    func tableView(tableView: UITableView, heightForRowAt indexPath: NSIndexPath) -> CGFloat {
        
        return self.tableViewRowHeight
        
    }    
    
}
