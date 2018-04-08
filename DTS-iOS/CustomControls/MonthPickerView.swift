//
//  MonthPickerView.swift
//  DTS-iOS
//
//  Created by Viktor on 19/12/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit

typealias DateSelected = (_ view: UIView, _ month: Int, _ year: Int) -> ()
typealias CancelButtonSelected = (_ view: UIView) -> ()

class MonthPickerView: UIView {
    
    
    @IBOutlet weak var mPicker: MonthYearPickerView!
    
    var selectedDateListener: DateSelected?
    var cancelButtonListener: CancelButtonSelected?
    
    class func setUpMonthPickerView(selectedDateListener: @escaping DateSelected, cancelButtonListener: @escaping CancelButtonSelected) ->MonthPickerView {
        let monthPickerView = Bundle.main.loadNibNamed("MonthPickerView", owner: self, options: nil)![0] as! MonthPickerView
        monthPickerView.selectedDateListener = selectedDateListener
        monthPickerView.cancelButtonListener = cancelButtonListener
        monthPickerView.mPicker.commonSetup()
        return monthPickerView
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if let block = self.selectedDateListener {
            block(self, mPicker.month, mPicker.year)
        }
    }
    
}
