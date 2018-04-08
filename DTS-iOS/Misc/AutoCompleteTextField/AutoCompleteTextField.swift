//
//  AutoCompleteTextField.swift
//  AutocompleteTextfieldSwift
//
//  Created by Viktor on 6/13/15.
//  Copyright (c) 2015 Mac. All rights reserved.
//

import Foundation
import UIKit

open class AutoCompleteTextField: UITextField {
    /// Manages the instance of tableview
    fileprivate var autoCompleteTableView:UITableView?
    /// Holds the collection of attributed strings
    fileprivate lazy var attributedAutoCompleteStrings = [NSAttributedString]()
    /// Handles user selection action on autocomplete table view
    open var onSelect:(String, IndexPath)->() = {_,_ in}
    /// Handles textfield's textchanged
    open var onTextChange:(String)->() = {_ in}
    
    open var isFromMap: Bool!
    
    open var showCurrentLocation: Bool?
    
    /// Font for the text suggestions
    open var autoCompleteTextFont = UIFont.systemFont(ofSize: 12)
    /// Color of the text suggestions
    open var autoCompleteTextColor = UIColor.black
    /// Used to set the height of cell for each suggestions
    open var autoCompleteCellHeight:CGFloat = 44.0
    /// The maximum visible suggestion
    open var maximumAutoCompleteCount = 3
    /// Used to set your own preferred separator inset
    open var autoCompleteSeparatorInset = UIEdgeInsets.zero
    /// Shows autocomplete text with formatting
    open var enableAttributedText = false
    /// User Defined Attributes
    open var autoCompleteAttributes:[String:AnyObject]?
    /// Hides autocomplete tableview after selecting a suggestion
    open var hidesWhenSelected = true
    var totalCount = 0
    /// Hides autocomplete tableview when the textfield is empty
    open var hidesWhenEmpty:Bool?{
        didSet{
            assert(hidesWhenEmpty != nil, "hideWhenEmpty cannot be set to nil")
            autoCompleteTableView?.isHidden = hidesWhenEmpty!
        }
    }
    /// The table view height
    open var autoCompleteTableHeight:CGFloat?{
        didSet{
            redrawTable()
        }
    }
    /// The strings to be shown on as suggestions, setting the value of this automatically reload the tableview
    open var autoCompleteStrings:[String]?{
        didSet{ reload() }
    }
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupAutocompleteTable(superview!)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
        setupAutocompleteTable(superview!)
    }
    
//    public override func willMoveToSuperview(newSuperview: UIView?) {
//        super.willMoveToSuperview(newSuperview)
//        commonInit()
//        setupAutocompleteTable(newSuperview!)
//    }
    
    fileprivate func commonInit(){
        self.superview?.layoutIfNeeded()
        hidesWhenEmpty = true
        autoCompleteAttributes = [NSForegroundColorAttributeName:UIColor.black]
        autoCompleteAttributes![NSFontAttributeName] = UIFont.boldSystemFont(ofSize: 12)
        self.clearButtonMode = .always
        self.addTarget(self, action: #selector(AutoCompleteTextField.textFieldDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(AutoCompleteTextField.textFieldDidEndEditing), for: .editingDidEnd)
    }
    
    fileprivate func setupAutocompleteTable(_ view:UIView){
        let screenSize = UIScreen.main.bounds.size
//        let tableView = UITableView(frame: CGRectMake(10, self.frame.origin.y + 65, screenSize.width - 20, 30.0))
        
        //let tobeDeducted = screenSize.width - (self.frame.origin.x + 10)
        
        let tableView = UITableView(frame: CGRect(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.height, width: screenSize.width - (self.frame.origin.x + 10), height: 30.0))
        
        //let tableView = UITableView(frame: CGRectMake(self.frame.origin.x, self.frame.origin.y + CGRectGetHeight(self.frame), view.bounds.width, 30.0))

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = autoCompleteCellHeight
        tableView.isHidden = hidesWhenEmpty ?? true
        view.addSubview(tableView)
        autoCompleteTableView = tableView
        view.bringSubview(toFront: tableView)
        autoCompleteTableHeight = 0
    }
    
    fileprivate func redrawTable(){
        if let autoCompleteTableView = autoCompleteTableView, let autoCompleteTableHeight = autoCompleteTableHeight {
            var newFrame = autoCompleteTableView.frame
            newFrame.size.height = autoCompleteTableHeight
            autoCompleteTableView.frame = newFrame
        }
    }
    
    //MARK: - Private Methods
    fileprivate func reload(){
        if enableAttributedText{
            let attrs = [NSForegroundColorAttributeName:autoCompleteTextColor, NSFontAttributeName:UIFont.systemFont(ofSize: 12.0)] as [String : Any]
    
            if attributedAutoCompleteStrings.count > 0 {
                attributedAutoCompleteStrings.removeAll(keepingCapacity: false)
            }
            
            autoCompleteTableHeight = 0
            
            if let autoCompleteStrings = autoCompleteStrings, let autoCompleteAttributes = autoCompleteAttributes {
                for i in 0..<autoCompleteStrings.count{
                    let str = autoCompleteStrings[i] as NSString
                    let range = str.range(of: text!, options: .caseInsensitive)
                    let attString = NSMutableAttributedString(string: autoCompleteStrings[i], attributes: attrs)
                    attString.addAttributes(autoCompleteAttributes, range: range)
                    attributedAutoCompleteStrings.append(attString)
                }
                
                if self.isFromMap == true {
                    autoCompleteTableHeight = CGFloat((autoCompleteStrings.count + 1) * 36)
                }
                else {
                    if autoCompleteStrings.count > 3 {
                        autoCompleteTableHeight = 180
                    }
                    else {
                        autoCompleteTableHeight = CGFloat((autoCompleteStrings.count + 1) * 36)
                    }
                }
            }
            
            
        }
        autoCompleteTableView?.reloadData()
    }
    
    func textFieldDidChange(){
        guard let _ = text else {
            return
        }
        
        onTextChange(text!)
        if text!.isEmpty{ autoCompleteStrings = nil }
        DispatchQueue.main.async(execute: { () -> Void in
            self.autoCompleteTableView?.isHidden =  self.hidesWhenEmpty! ? self.text!.isEmpty : false
        })
    }
    
    func textFieldDidEndEditing() {
        autoCompleteTableView?.isHidden = true
    }
}

//MARK: - UITableViewDataSource - UITableViewDelegate
extension AutoCompleteTextField: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
  
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFromMap == true {
            return autoCompleteStrings != nil ? (autoCompleteStrings!.count > maximumAutoCompleteCount ? maximumAutoCompleteCount + 1 : autoCompleteStrings!.count + 1) : 0
        }
        if showCurrentLocation != nil
        {
            totalCount = 1
            if (autoCompleteStrings != nil) {
                if (autoCompleteStrings!.count > maximumAutoCompleteCount) {
                    totalCount = maximumAutoCompleteCount + 1
                }
                else {
                    totalCount = autoCompleteStrings!.count + 1
                }
            }
            return totalCount;
        }
        
        if (autoCompleteStrings != nil) {
            if (autoCompleteStrings!.count > maximumAutoCompleteCount) {
                totalCount = maximumAutoCompleteCount
            }
            else {
                totalCount = autoCompleteStrings!.count
            }
        }
        return totalCount;
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if self.isFromMap == false {
//            if indexPath.row == totalCount - 1 {
//                var cell = tableView.dequeueReusableCellWithIdentifier("cell")
//                if cell == nil {
//                    cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
//                }
//                cell?.textLabel?.text = "Don't see your address?"
//                cell?.selectionStyle = .None
//                return cell!
//            }
//        }
        
        
        let cellIdentifier = "autocompleteCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        if showCurrentLocation != nil {
            if indexPath.row == 0 {
                cell?.textLabel?.font = autoCompleteTextFont
                cell?.textLabel?.textColor = autoCompleteTextColor
                
                cell?.textLabel?.text = "Current Location"
                cell?.contentView.gestureRecognizers = nil
                return cell!
            }
            
            
            if enableAttributedText{
                
                cell?.textLabel?.attributedText = attributedAutoCompleteStrings[indexPath.row - 1]
            }
            else{
                cell?.textLabel?.font = autoCompleteTextFont
                cell?.textLabel?.textColor = autoCompleteTextColor
                
                cell?.textLabel?.text = autoCompleteStrings![indexPath.row - 1]
                
            }
            
            cell?.contentView.gestureRecognizers = nil
            return cell!
        }
        else {
            
            if enableAttributedText{
                
                cell?.textLabel?.attributedText = attributedAutoCompleteStrings[indexPath.row]
            }
            else{
                cell?.textLabel?.font = autoCompleteTextFont
                cell?.textLabel?.textColor = autoCompleteTextColor
                
                cell?.textLabel?.text = autoCompleteStrings![indexPath.row  ]
                
            }
            
            cell?.contentView.gestureRecognizers = nil
            return cell!
        }
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if let selectedText = cell?.textLabel?.text {
            self.text = selectedText
            onSelect(selectedText, indexPath)
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            tableView.isHidden = self.hidesWhenSelected
        })
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.isFromMap == false {
            if indexPath.row < totalCount {
                if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
                    cell.separatorInset = autoCompleteSeparatorInset
                }
                if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)){
                    cell.preservesSuperviewLayoutMargins = false
                }
                if cell.responds(to: #selector(setter: UIView.layoutMargins)){
                    cell.layoutMargins = autoCompleteSeparatorInset
                }
            }
        }
        else {
            if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
                cell.separatorInset = autoCompleteSeparatorInset
            }
            if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)){
                cell.preservesSuperviewLayoutMargins = false
            }
            if cell.responds(to: #selector(setter: UIView.layoutMargins)){
                cell.layoutMargins = autoCompleteSeparatorInset
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return autoCompleteCellHeight
    }
}
