//
//  MessagesViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 19/05/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit


import KVNProgress
import QuartzCore
import SDWebImage

class MessagesViewController: BaseViewController {
    
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var view9: UIView!
    @IBOutlet weak var view8: UIView!
    @IBOutlet weak var view7: UIView!
    @IBOutlet weak var view6: UIView!
    @IBOutlet weak var view5: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var tblMessages: UITableView!
    var messages: NSMutableArray = NSMutableArray()
    
    var dictSelectedMessage: NSDictionary!
    var dictSelectedProperty: NSDictionary!
    var dictMessageData: NSDictionary!
    var parents: NSArray!
    var total = 0
    var dataSource: [Parent]!
    var isInquired: Bool!
    /// Define wether can exist several cells expanded or not.
    let numberOfCellsExpanded: NumberOfCellExpanded = .one
    
    /// Constant to define the values for the tuple in case of not exist a cell expanded.
    let NoCellExpanded = (-1, -1)
    
    /// The index of the last cell expanded and its parent.
    var lastCellExpanded : (Int, Int)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Messages"
//        self.tblMessages.editing = true
        
        
        AppDelegate.returnAppDelegate().isBack = false
        
        self.view.backgroundColor = UIColor(hexString: "191919")
        self.tblMessages.backgroundColor = UIColor(hexString: "191919")
        
        
        
        
        self.btnAccount.isHidden = true
        if UserDefaults.standard.object(forKey: "token") != nil {
            self.btnAccount.isHidden = false
            
            let revealController = revealViewController()
            self.btnAccount.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.tblMessages.isHidden = true
        self.lblMessage.isHidden = true
        self.tblMessages.addPullToRefresh {
            self.getConditionalMessages()
        }
        KVNProgress.show(withStatus: "Loading Messages")
        self.getConditionalMessages()

    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.returnAppDelegate().isBack = true
    }
    
    func deletParentAndChildrenMessages(_ tableView: UITableView, withParent parent: Int, andIndexPath indexPath: IndexPath) -> Void {
        let dictMessage = self.dataSource[parent].dict as NSDictionary
        let msgID = String(dictMessage["id"] as! Int)
        //self.dataSource[parent].childs.removeObjectAtIndex(indexPath.row - actualPosition - 1)
        
        
        
        self.total = self.total - (1 + self.dataSource[parent].childs.count)
        var arrayIndexPaths = [IndexPath]()
        arrayIndexPaths.append(indexPath)
        for i in 1...self.dataSource[parent].childs.count {
            let childIndedPath = IndexPath(row: indexPath.row + i, section: 0)
            arrayIndexPaths.append(childIndedPath)
        }
        
        
        self.dataSource.remove(at: parent)
        if let tempParents = self.parents.mutableCopy() as? NSMutableArray {
            
            tempParents.removeObject(at: parent)
            self.parents = tempParents.copy() as! NSArray
        }
        
        Utils.archiveArray(self.parents, forKey: "savedParents")
        
        tableView.deleteRows(at: arrayIndexPaths, with: .automatic)
       // tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/updatemsg?token=\(token)&msg_id=\(msgID)&action=archive")
        }
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    _ = json as? NSDictionary
                    
                    
                }
                catch {
                    
                }
            }
            else {
            
            }
        }.resume()
        
    }
    
    func deleteSingleRowOfTable(_ tableView: UITableView, withParent parent: Int, andIndexPath indexPath: IndexPath) -> Void {
        let dictMessage = self.dataSource[parent].dict as NSDictionary
        let msgID = String(dictMessage["id"] as! Int)
        //self.dataSource[parent].childs.removeObjectAtIndex(indexPath.row - actualPosition - 1)
        
        self.dataSource.remove(at: parent)
        if let tempParents = self.parents.mutableCopy() as? NSMutableArray {
            tempParents.removeObject(at: parent)
            self.parents = tempParents.copy() as! NSArray
        }
        
        
        Utils.archiveArray(self.parents, forKey: "savedParents")
        self.total = self.total - 1
        tableView.deleteRows(at: [indexPath], with: .automatic)
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/updatemsg?token=\(token)&msg_id=\(msgID)&action=archive")
        }
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    _ = json as? NSDictionary
                    
                    
                }
                catch {
                    
                }
            }
            else {
                
            }
        }.resume()

    }
    
    func refresh(_ sender:AnyObject) {
//        self.getMessagesWhenBack()
        self.getMessages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func btnProperty_Tapped(_ sender: AnyObject) {
        AppDelegate.returnAppDelegate().isNewProperty = nil
        let btn = sender as! UIButton
        let (parent, _, _) = self.findParent(btn.tag)
        dictSelectedProperty = self.dataSource[parent].dictPorperty as NSDictionary
        self.performSegue(withIdentifier: "messagesToPD", sender: self)
    }
    @IBAction func btnAction_Tapped(_ sender: AnyObject) {
        let btn = sender as! UIButton
        if btn.tag > self.total {
            return
        }
        self.isInquired = false
        let (parent, _, _) = self.findParent(btn.tag)
        dictSelectedMessage = self.dataSource[parent].dict as NSDictionary
        dictSelectedProperty = self.dataSource[parent].dictPorperty as NSDictionary
        if dictSelectedMessage["type"] as! String == "doc_sign" {
            self.performSegue(withIdentifier: "messageToDoc", sender: self)
        }
        else if dictSelectedMessage["type"] as! String == "demo" {
            self.performSegue(withIdentifier: "messagesToDemo", sender: self)
        }
        else if dictSelectedMessage["type"] as! String == "inquire" {
            self.isInquired = true
            self.performSegue(withIdentifier: "messageToFollowUp", sender: self)
        }
        else {
            self.performSegue(withIdentifier: "messageToFollowUp", sender: self)
        }
    }
    
    
    func getMessagesWhenBack() -> Void {
        var strURL = "\(APIConstants.BasePath)/api/getmsg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIxLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzkxMSwiZXhwIjoxNTU3MjQ1OTExLCJuYmYiOjE0NjM5MzM5MTEsImp0aSI6IjdkMGYzNWFiNGM0MzBjNjQ0YWJiN2RlODU0YzAwNDA5In0.5COr5Q6H6FGeVVaTJPHHfZuFZg0A8caLI5ZYCM_x4T8&type=thread&paginated=0&page=1&archived=0"
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getmsg?token=\(token)&type=thread&paginated=0&page=1&archived=0")
        }
        
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let tempData = json as? NSDictionary
                
                let isSuccess = tempData!["success"] as! Bool
                
                if isSuccess == false {
                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                    return
                }
                
                self.parents =  (tempData!["data"] as! NSDictionary)["thread"] as! NSArray
                Utils.archiveArray(self.parents, forKey: "savedParents")
                self.setInitialDataSource(numberOfRowParents: self.parents.count, numberOfRowChildPerParent: 3)
                self.lastCellExpanded = self.NoCellExpanded
                    
                    DispatchQueue.main.async(execute: {
                        self.tblMessages.reloadData()
                        if (AppDelegate.returnAppDelegate().selectedParent > -1 && AppDelegate.returnAppDelegate().selectedIndex > -1) {
                            self.tblMessages.beginUpdates()
                            self.updateCells(AppDelegate.returnAppDelegate().selectedParent, index: AppDelegate.returnAppDelegate().selectedIndex)
                            self.tblMessages.endUpdates()
                        }
                        
                        if self.parents.count > 0 {
                            self.tblMessages.isHidden = false
                            self.lblMessage.isHidden = true
                        }
                        else {
                            self.tblMessages.isHidden = true
                            self.lblMessage.isHidden = false
                        }
                        //self.refreshControl.endRefreshing()
                        self.tblMessages.pullToRefreshView.stopAnimating()
                    })
                
                }
                catch {
                    
                }
            }
            else {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                })
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                
            }
        }.resume()
    }
    
    func getMessages() -> Void {
        var strURL = "\(APIConstants.BasePath)/api/getmsg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIxLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzkxMSwiZXhwIjoxNTU3MjQ1OTExLCJuYmYiOjE0NjM5MzM5MTEsImp0aSI6IjdkMGYzNWFiNGM0MzBjNjQ0YWJiN2RlODU0YzAwNDA5In0.5COr5Q6H6FGeVVaTJPHHfZuFZg0A8caLI5ZYCM_x4T8&type=thread&paginated=0&page=1&archived=0"
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getmsg?token=\(token)&type=thread&paginated=0&page=1&archived=0")
        }

        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let tempData = json as? NSDictionary
                
                let isSuccess = tempData!["success"] as! Bool
                
                if isSuccess == false {
                    let _utils = Utils()
                    _utils.showOKAlert("Error:", message: tempData!["message"] as! String, controller: self, isActionRequired: false)
                    return
                }
                
                self.parents =  (tempData!["data"] as! NSDictionary)["thread"] as! NSArray
                
                Utils.archiveArray(self.parents, forKey: "savedParents")
                
                self.setInitialDataSource(numberOfRowParents: self.parents.count, numberOfRowChildPerParent: 3)
                self.lastCellExpanded = self.NoCellExpanded

                    DispatchQueue.main.async(execute: {
                        if self.parents.count > 0 {
                            self.tblMessages.isHidden = false
                            self.lblMessage.isHidden = true
                        }
                        else {
                            self.tblMessages.isHidden = true
                            self.lblMessage.isHidden = false
                        }
                        self.tblMessages.reloadData()
                        
                        
                        //self.refreshControl.endRefreshing()
                        self.tblMessages.pullToRefreshView.stopAnimating()
                    })
                
                
                    
                }
                catch {
                    
                }
            }
            else {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                })
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                
            }
        }.resume()
    }
    
    func FadeOut() -> Void {
        UIView.animate(withDuration: 0.15, animations: {
            self.view1.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) in
            self.view1.isHidden = true
            
            UIView.animate(withDuration: 0.15, animations: {
                self.view2.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                self.view2.isHidden = true
                UIView.animate(withDuration: 0.15, animations: {
                    self.view3.alpha = 0
                    self.view.layoutIfNeeded()
                }, completion: { (finished: Bool) in
                    self.view3.isHidden = true
                    UIView.animate(withDuration: 0.15, animations: {
                        self.view4.alpha = 0
                        self.view.layoutIfNeeded()
                    }, completion: { (finished: Bool) in
                        self.view4.isHidden = true
                        UIView.animate(withDuration: 0.15, animations: {
                            self.view5.alpha = 0
                            self.view.layoutIfNeeded()
                        }, completion: { (finished: Bool) in
                            self.view5.isHidden = true
                            UIView.animate(withDuration: 0.15, animations: {
                                self.view6.alpha = 0
                                self.view.layoutIfNeeded()
                            }, completion: { (finished: Bool) in
                                self.view6.isHidden = true
                                UIView.animate(withDuration: 0.15, animations: {
                                    self.view7.alpha = 0
                                    self.view.layoutIfNeeded()
                                }, completion: { (finished: Bool) in
                                    self.view7.isHidden = true
                                    UIView.animate(withDuration: 0.15, animations: {
                                        self.view8.alpha = 0
                                        self.view.layoutIfNeeded()
                                    }, completion: { (finished: Bool) in
                                        self.view8.isHidden = true
                                        UIView.animate(withDuration: 0.15, animations: {
                                            self.view9.alpha = 0
                                            self.view.layoutIfNeeded()
                                        }, completion: { (finished: Bool) in
                                            self.view9.isHidden = true
                                        }) 
                                    }) 
                                }) 
                            }) 
                        }) 
                    }) 
                }) 
            }) 
            
        }) 

    }
    
    
    fileprivate func setInitialDataSource(numberOfRowParents parents: Int, numberOfRowChildPerParent childs: Int) {
        
        // Set the total of cells initially.
        self.total = parents
        
        
        let data = [Parent](repeating: Parent(state: .collapsed, childs: [], dict: nil, dictPorperty: nil), count: parents)
        
        dataSource = data.enumerated().map({ (index: Int, element: Parent) -> Parent in
            
            var newElement = element
            newElement.dictPorperty = self.parents[index] as! NSDictionary
            
            let tempArray = ((self.parents[index] as! NSDictionary) ["msgs"] as! NSArray)
            let msgs = NSMutableArray()
            
    
            //for i in tem...self.dataSource[parent].childs.count
            /*if tempArray.count > 0 {
                for i in (0...(tempArray.count-1)).reverse() {
//                    print(i)
                    if let dictMsg = tempArray[i] as? NSDictionary {
                        if dictMsg["type"] as? String != nil  {
                            msgs.addObject(dictMsg)
                        }
                    }
                }
            }*/
            
            
            
            for dictMsg in tempArray {
                if dictMsg as? NSDictionary != nil {
                    if (dictMsg  as! NSDictionary)["type"] as? String != nil  {
                        msgs.add(dictMsg)
                    }
                }

            }
            
            let dictFirstMessage = msgs.firstObject as! NSDictionary
            newElement.dict = dictFirstMessage
            
            newElement.childs = msgs
            
            return newElement
        })
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "messageToFollowUp" {
            let controller = segue.destination as! FollowUpViewController
            controller.dictSelectedMessage = self.dictSelectedMessage
            controller.dictProperty = self.dictSelectedProperty
            controller.isInquired = self.isInquired
            
        }
        else if segue.identifier == "messageToDoc" {
            let controller = segue.destination as! DocMessageViewController
            controller.dictSelectedMessage = self.dictSelectedMessage
            controller.isFromSignature = false
            controller.dictProperty = self.dictSelectedProperty
        }
        else if segue.identifier == "messagesToDemo" {
            let controller = segue.destination as! DemoMessageViewController
            controller.dictSelectedMessage = self.dictSelectedMessage
            controller.dictProperty = self.dictSelectedProperty
        }
        else if segue.identifier == "messagesToPD" {
            let controller = segue.destination as! PropertyDetailViewController
            controller.propertyID = String(dictSelectedProperty["id"] as! Int)
            controller.dictProperty = dictSelectedProperty
            controller.isFromMainView = true
        }
    }
    
    
    
    /**
     Expand the cell at the index specified.
     
     - parameter index: The index of the cell to expand.
     */
    fileprivate func expandItemAtIndex(_ index : Int, parent: Int) {
        
        
        AppDelegate.returnAppDelegate().selectedParent = parent
        AppDelegate.returnAppDelegate().selectedIndex = index
        // the data of the childs for the specific parent cell.
        let currentSubItems = self.dataSource[parent].childs
        
        // update the state of the cell.
        self.dataSource[parent].state = .expanded
        
        // position to start to insert rows.
        var insertPos = index + 1
        
        let indexPaths = (0..<currentSubItems!.count).map { _ -> IndexPath in
            let indexPath = IndexPath(row: insertPos, section: 0)
            insertPos += 1
            return indexPath
        }
        
        // insert the new rows
        self.tblMessages.insertRows(at: indexPaths, with: UITableViewRowAnimation.fade)
        let parentIndexPath = IndexPath(row: parent, section: 0)
        if let parentCell = self.tblMessages.cellForRow(at: parentIndexPath) as? MessagesTableViewCell {
            parentCell.viewVerticalLine.isHidden = false
        }
        
        // update the total of rows
        self.total += currentSubItems!.count
    }
    
    /**
     Collapse the cell at the index specified.
     
     - parameter index: The index of the cell to collapse
     */
    fileprivate func collapseSubItemsAtIndex(_ index : Int, parent: Int) {
        
        var indexPaths = [IndexPath]()
        
        let numberOfChilds = self.dataSource[parent].childs.count
        
        // update the state of the cell.
        self.dataSource[parent].state = .collapsed
        
        guard index + 1 <= index + numberOfChilds else { return }
        
        // create an array of NSIndexPath with the selected positions
        indexPaths = (index + 1...index + numberOfChilds).map { IndexPath(row: $0, section: 0)}
        let parentIndexPath = IndexPath(row: parent, section: 0)
        if let parentCell = self.tblMessages.cellForRow(at: parentIndexPath) as? MessagesTableViewCell {
            parentCell.viewVerticalLine.isHidden = true
        }
        
        // remove the expanded cells
        self.tblMessages.deleteRows(at: indexPaths, with: UITableViewRowAnimation.fade)
        
        // update the total of rows
        self.total -= numberOfChilds
    }
    
    /**
     Update the cells to expanded to collapsed state in case of allow severals cells expanded.
     
     - parameter parent: The parent of the cell
     - parameter index:  The index of the cell.
     */
    fileprivate func updateCells(_ parent: Int, index: Int) {
        
        switch (self.dataSource[parent].state) {
            
        case .expanded:
            self.collapseSubItemsAtIndex(index, parent: parent)
            self.lastCellExpanded = NoCellExpanded
            AppDelegate.returnAppDelegate().selectedParent = -1
            AppDelegate.returnAppDelegate().selectedIndex = -1
            
        case .collapsed:
            switch (numberOfCellsExpanded) {
            case .one:
                // exist one cell expanded previously
                if self.lastCellExpanded != NoCellExpanded {
                    
                    let (indexOfCellExpanded, parentOfCellExpanded) = self.lastCellExpanded
                    
                    self.collapseSubItemsAtIndex(indexOfCellExpanded, parent: parentOfCellExpanded)
                    
                    // cell tapped is below of previously expanded, then we need to update the index to expand.
                    if parent > parentOfCellExpanded {
                        let newIndex = index - self.dataSource[parentOfCellExpanded].childs.count
                        self.expandItemAtIndex(newIndex, parent: parent)
                        self.lastCellExpanded = (newIndex, parent)
                    }
                    else {
                        self.expandItemAtIndex(index, parent: parent)
                        self.lastCellExpanded = (index, parent)
                    }
                }
                else {
                    self.expandItemAtIndex(index, parent: parent)
                    self.lastCellExpanded = (index, parent)
                }
            case .several:
                self.expandItemAtIndex(index, parent: parent)
            }
        }
    }
    
    /**
     Find the parent position in the initial list, if the cell is parent and the actual position in the actual list.
     
     - parameter index: The index of the cell
     
     - returns: A tuple with the parent position, if it's a parent cell and the actual position righ now.
     */
    fileprivate func findParent(_ index : Int) -> (parent: Int, isParentCell: Bool, actualPosition: Int) {
        
        var position = 0, parent = 0
        guard position < index else { return (parent, true, parent) }
        
        var item = self.dataSource[parent]
        
        repeat {
            
            switch (item.state) {
            case .expanded:
                position += item.childs.count + 1
            case .collapsed:
                position += 1
            }
            
            parent += 1
            
            // if is not outside of dataSource boundaries
            if parent < self.dataSource.count {
                item = self.dataSource[parent]
            }
            
        } while (position < index)
        
        // if it's a parent cell the indexes are equal.
        if position == index {
            return (parent, position == index, position)
        }
        
        item = self.dataSource[parent - 1]
        return (parent - 1, position == index, position - item.childs.count - 1)
    }
    
    @IBAction func btnAccount_Tapped(_ sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "accountVC") as! AccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
        
}

extension MessagesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.total
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let (parent, isParentCell, actualPosition) = self.findParent(indexPath.row)
        
        if !isParentCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "childCell", for: indexPath) as! MessagesTableViewCell
            let dictMessage = self.dataSource[parent].childs[indexPath.row - actualPosition - 1] as! NSDictionary
            let dictProperty = self.dataSource[parent].dictPorperty as NSDictionary
            cell.lblRoundedStatus.layer.cornerRadius = cell.lblRoundedStatus.frame.size.width / 2
            cell.lblRoundedStatus.clipsToBounds = true
            cell.lblRoundedStatus.layer.borderWidth = 4
            cell.lblRoundedStatus.layer.borderColor = UIColor(hexString: "908f8d").cgColor
            cell.selectionStyle = .none
            if dictMessage["type"] as! String == "doc_sign" {
                cell.lblSubject.text = "SIGN LEASE"
                cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "ff2602")
                cell.lblRoundedStatus.textColor = UIColor(hexString: "fafff9")
                cell.lblRoundedStatus.text = "SIGN"
            }
            else if dictMessage["type"] as! String == "follow_up" {
                cell.lblSubject.text = "FOLLOW UP"
                cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "ff2602")
                cell.lblRoundedStatus.textColor = UIColor(hexString: "fafff9")
                cell.lblRoundedStatus.text = "REPLY"
            
            }
            else if dictMessage["type"] as! String == "demo" {
                cell.lblSubject.text = "ON-SITE DEMO"
                cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "ff2602")
                cell.lblRoundedStatus.textColor = UIColor(hexString: "fafff9")
                cell.lblRoundedStatus.text = "DEMO"
            }
            else if dictMessage["type"] as! String == "inquire" {
                 cell.lblSubject.text = "INQUIRED"
                cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "ff2602")
                cell.lblRoundedStatus.textColor = UIColor(hexString: "fafff9")
                cell.lblRoundedStatus.text = "START"
                
            }
            else if dictMessage["type"] as! String == "negotiate" {
                cell.lblSubject.text = (dictMessage["type"]! as AnyObject).uppercased
                cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "ff2602")
                cell.lblRoundedStatus.textColor = UIColor(hexString: "fafff9")
                cell.lblRoundedStatus.text = "NEG"
                
            }
            else {
                cell.lblSubject.text = (dictMessage["type"]! as AnyObject).uppercased
                cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "ff2602")
                cell.lblRoundedStatus.textColor = UIColor(hexString: "fafff9")
                let strIndex = cell.lblSubject.text!.index(cell.lblSubject.text!.startIndex, offsetBy: 4)
                cell.lblRoundedStatus.text = cell.lblSubject.text?.substring(to: strIndex)
            }
            
            
            cell.lblDuration.text = dictMessage["updated_at_formatted"] as? String
            
            cell.lblDuration.text = cell.lblDuration.text?.replacingOccurrences(of: "months", with: "M")
            cell.lblDuration.text = cell.lblDuration.text?.replacingOccurrences(of: "month", with: "M")
            cell.lblDuration.text = cell.lblDuration.text?.replacingOccurrences(of: "weeks", with: "W")
            cell.lblDuration.text = cell.lblDuration.text?.replacingOccurrences(of: "week", with: "W")
            cell.lblDuration.text = cell.lblDuration.text?.replacingOccurrences(of: "hours", with: "H")
            cell.lblDuration.text = cell.lblDuration.text?.replacingOccurrences(of: "hour", with: "H")
            cell.lblDuration.text = cell.lblDuration.text?.replacingOccurrences(of: "minutes", with: "MIN")
            cell.lblDuration.text = cell.lblDuration.text?.replacingOccurrences(of: "minute", with: "MIN")
            
            cell.lblDuration.text = cell.lblDuration.text?.capitalized
            
            
            let imgURL = (dictProperty["img_url"] as! NSDictionary)["sm"] as! String
            cell.ivProperty.sd_setImage(with: URL(string: imgURL))
            
            
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "messagesCell", for: indexPath) as! MessagesTableViewCell
            let dictMessage = self.dataSource[parent].dict as NSDictionary
            let dictProperty = self.dataSource[parent].dictPorperty as NSDictionary
            cell.selectionStyle = .none
            cell.btnProperty.tag = indexPath.row
            cell.btnProperty.addTarget(self, action: #selector(MessagesViewController.btnProperty_Tapped(_:)), for: .touchUpInside)
            cell.btnAction.tag = indexPath.row
            cell.btnAction.addTarget(self, action: #selector(MessagesViewController.btnAction_Tapped(_:)), for: .touchUpInside)
            cell.lblRoundedStatus.layer.cornerRadius = cell.lblRoundedStatus.frame.size.width / 2
            cell.lblRoundedStatus.clipsToBounds = true
            cell.lblRoundedStatus.layer.borderWidth = 4
            cell.lblRoundedStatus.layer.borderColor = UIColor(hexString: "908f8d").cgColor
            
            cell.lblSubject.numberOfLines = 0;
//            cell.lblSubject.textAlignment = .Center
            //cell.lblSubject.textColor = UIColor(hexString: "ff0500")
            if dictMessage["type"] as! String == "doc_sign" {
                cell.lblSubject.text = "SIGN LEASE"
                if dictMessage["declined"] as! Int != 0 {
                    cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "9ffe00")
                    cell.lblRoundedStatus.textColor = UIColor(hexString: "000201")
                    cell.lblRoundedStatus.text = "DONE"
                    cell.btnAction.setTitle("DECLINED", for: UIControlState())
                }
                else if dictMessage["doc"] as? NSDictionary != nil {
                    if (dictMessage["doc"] as! NSDictionary)["signed"] as! Int == 0 {
                        cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "ff2602")
                        cell.lblRoundedStatus.textColor = UIColor(hexString: "fafff9")
                        cell.btnAction.setTitle("SIGN DOC", for: UIControlState())
                        cell.lblRoundedStatus.text = "SIGN"
                    }
                    else {
                        cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "9ffe00")
                        cell.lblRoundedStatus.textColor = UIColor(hexString: "000201")
                        cell.lblRoundedStatus.text = "DONE"
                        cell.btnAction.setTitle("SIGNED", for: UIControlState())
                    }
                }
                else {
                    cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "ff2602")
                    cell.lblRoundedStatus.textColor = UIColor(hexString: "fafff9")
                    cell.lblRoundedStatus.text = "SIGN"
                    cell.btnAction.setTitle("SIGN DOC", for: UIControlState())
                }
                
            }
            else if dictMessage["type"] as! String == "follow_up" {
                
                
                if dictMessage["replies"] as! Int == 0 {
                    cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "ff2602")
                    cell.lblRoundedStatus.textColor = UIColor(hexString: "fafff9")
                    cell.lblRoundedStatus.text = "REPLY"
                    cell.lblSubject.text = "FOLLOW UP"
                    cell.btnAction.setTitle("FOLLOW UP", for: UIControlState())
                }
                else {
                    cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "9ffe00")
                    cell.lblRoundedStatus.text = "DONE"
                    cell.lblRoundedStatus.textColor = UIColor(hexString: "000201")
                    cell.btnAction.setTitle("REPLIED", for: UIControlState())
                }
            }
            else if dictMessage["type"] as! String == "demo" {
                cell.lblSubject.text = "ON-SITE DEMO"
                
                if dictMessage["accepted"] as! Int != 0 {
                    cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "9ffe00")
                    cell.lblRoundedStatus.textColor = UIColor(hexString: "000201")
                    cell.btnAction.setTitle("ACCEPTED", for: UIControlState())
                    cell.lblRoundedStatus.text = "DONE"
                }
                else if dictMessage["declined"] as! Int != 0 {
                    cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "9ffe00")
                    cell.lblRoundedStatus.textColor = UIColor(hexString: "000201")
                    cell.btnAction.setTitle("DECLINED", for: UIControlState())
                    cell.lblRoundedStatus.text = "DONE"
                }
                else {
                    cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "ff2602")
                    cell.lblRoundedStatus.textColor = UIColor(hexString: "fafff9")
                    cell.btnAction.setTitle("DEMO", for: UIControlState())
                    cell.lblRoundedStatus.text = "DEMO"
                }
            }
            else if dictMessage["type"] as! String == "inquire" {
                cell.lblSubject.text = "INQUIRED"
                
                //cell.lblSubject.textColor = UIColor(hexString: "02ce37")
                if dictMessage["replies"] as! Int == 0 {
                    cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "ff2602")
                    cell.lblRoundedStatus.textColor = UIColor(hexString: "fafff9")
                    cell.btnAction.setTitle("VIEW", for: UIControlState())
                    cell.lblRoundedStatus.text = "START"
                }
                else {
                    cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "ff2602")
                    cell.lblRoundedStatus.textColor = UIColor(hexString: "fafff9")
                    cell.btnAction.setTitle("VIEW", for: UIControlState())
                    cell.lblRoundedStatus.text = "START"
                }
                
            }
            else if dictMessage["type"] as! String == "negotiate" {
                if dictMessage["replies"] as! Int == 0 {
                    cell.btnAction.setTitle("VIEW", for: UIControlState())
                    cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "ff2602")
                    cell.lblRoundedStatus.textColor = UIColor(hexString: "fafff9")
                    cell.lblRoundedStatus.text = "NEG"
                }
                else {
                    cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "9ffe00")
                    cell.lblRoundedStatus.textColor = UIColor(hexString: "000201")
                    cell.btnAction.setTitle("REPLIED", for: UIControlState())
                    cell.lblRoundedStatus.text = "DONE"
                    
                }
                
            }
            else {
                cell.lblSubject.text = (dictMessage["type"]! as AnyObject).uppercased
                if dictMessage["replies"] as! Int == 0 {
                    cell.btnAction.setTitle("VIEW", for: UIControlState())
                    cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "ff2602")
                    cell.lblRoundedStatus.textColor = UIColor(hexString: "fafff9")
                    let strIndex = cell.lblSubject.text!.index(cell.lblSubject.text!.startIndex, offsetBy: 4)
                    cell.lblRoundedStatus.text = cell.lblSubject.text?.substring(to: strIndex)
                }
                else {
                    cell.lblRoundedStatus.backgroundColor = UIColor(hexString: "9ffe00")
                    cell.lblRoundedStatus.textColor = UIColor(hexString: "000201")
                    cell.btnAction.setTitle("REPLIED", for: UIControlState())
                    cell.lblRoundedStatus.text = "DONE"
                    
                }
            }
            
            
            
//            cell.lblAddress.textAlignment = .Center
            cell.lblDuration.text = dictMessage["updated_at_formatted"] as? String
            cell.lblDuration.text = cell.lblDuration.text?.replacingOccurrences(of: "months", with: "M")
            cell.lblDuration.text = cell.lblDuration.text?.replacingOccurrences(of: "month", with: "M")
            cell.lblDuration.text = cell.lblDuration.text?.replacingOccurrences(of: "weeks", with: "W")
            cell.lblDuration.text = cell.lblDuration.text?.replacingOccurrences(of: "week", with: "W")
            cell.lblDuration.text = cell.lblDuration.text?.replacingOccurrences(of: "hours", with: "H")
            cell.lblDuration.text = cell.lblDuration.text?.replacingOccurrences(of: "hour", with: "H")
            cell.lblDuration.text = cell.lblDuration.text?.replacingOccurrences(of: "minutes", with: "MIN")
            cell.lblDuration.text = cell.lblDuration.text?.replacingOccurrences(of: "minute", with: "MIN")
            
            cell.lblDuration.text = cell.lblDuration.text?.capitalized
            let address1 = dictProperty["address1"] as! String
            let city = dictProperty["city"] as! String
            let state = dictProperty["state_or_province"] as! String
            let zip = dictProperty["zip"] as! String
            
            cell.lblAddress.text = address1
            cell.lblCountry.text = "\(city), \(state) \(zip)"
            
            let imgURL = (dictProperty["img_url"] as! NSDictionary)["sm"] as! String
            cell.ivProperty.sd_setImage(with: URL(string: imgURL))
            
            cell.viewVerticalLine.isHidden = true
            
            if self.dataSource[parent].state == .expanded {
                if parent == indexPath.row {
                    cell.viewVerticalLine.isHidden = false
                }
            }
            
            if UIDevice.current.screenType == .iPhone4 {
                cell.constraintAddress2.constant = 10
                cell.constraintAddress1.constant = 10
            }
            
            return cell

        }

        
        
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Archive"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let (_, isParentCell, _) = self.findParent(indexPath.row)
        if !isParentCell {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.tblMessages.beginUpdates()
        if editingStyle == .delete {
            
            let (parent, isParentCell, _) = self.findParent(indexPath.row)
            
            if isParentCell {
                
                switch self.dataSource[parent].state {
                case .collapsed:
                    self.deleteSingleRowOfTable(tableView, withParent: parent, andIndexPath: indexPath)
                case .expanded:
                    self.updateCells(parent, index: indexPath.row)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(1 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                        self.deleteSingleRowOfTable(tableView, withParent: parent, andIndexPath: indexPath)
                    })
                }
            }
            
        }
        self.tblMessages.endUpdates()
    }
}


extension MessagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (parent, isParentCell, actualPosition) = self.findParent(indexPath.row)
        
        if isParentCell {
        
        }
        else {
            
            self.isInquired = false
            dictSelectedMessage = self.dataSource[parent].childs[indexPath.row - actualPosition - 1] as! NSDictionary
            dictSelectedProperty = self.dataSource[parent].dictPorperty as NSDictionary
            if dictSelectedMessage["type"] as! String == "doc_sign" {
                self.performSegue(withIdentifier: "messageToDoc", sender: self)
            }
            else if dictSelectedMessage["type"] as! String == "demo" {
                self.performSegue(withIdentifier: "messagesToDemo", sender: self)
            }
            else if dictSelectedMessage["type"] as! String == "inquire" {
                self.isInquired = true
                self.performSegue(withIdentifier: "messageToFollowUp", sender: self)
            }
            else {
                self.performSegue(withIdentifier: "messageToFollowUp", sender: self)
            }
            
            return

        }
        
        
        self.tblMessages.beginUpdates()
        self.updateCells(parent, index: indexPath.row)
        self.tblMessages.endUpdates()
        

    }
    
    func getConditionalMessages() -> Void {
        if AppDelegate.returnAppDelegate().isBack == true {
            self.messages = NSMutableArray()
            self.getMessagesWhenBack()
        }
        else {
            self.getMessages()
//            if let savedParents = Utils.unarchiveDataForKey("savedParents") {
//                self.parents = savedParents
//                if self.parents.count > 0 {
//                    self.tblMessages.isHidden = false
//                    self.lblMessage.isHidden = true
//                }
//                else {
//                    self.tblMessages.isHidden = true
//                    self.lblMessage.isHidden = false
//                }
//                self.setInitialDataSource(numberOfRowParents: self.parents.count, numberOfRowChildPerParent: 3)
//                self.lastCellExpanded = self.NoCellExpanded
//                self.tblMessages.reloadData()
//                KVNProgress.dismiss()
//                self.tblMessages.pullToRefreshView.stopAnimating()
//            }
//            else {
//                self.messages = NSMutableArray()
//                //KVNProgress.show()
//                self.getMessages()
//            }
        }

    }
    
}
