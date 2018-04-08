//
//  String+Extensions.swift
//  DTS-iOS
//
//  Created by Viktor on 03/11/2016.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import UIKit

protocol StringType { var get: String { get } }
extension String: StringType { var get: String { return self } }
extension Optional where Wrapped: StringType {
    func unwrap() -> String {
        return self?.get ?? ""
    }
}



extension String {
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
    
    //    var trim :  String{
    //    return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    //    }
    
    
    
    
    func boldString(fontSize : CGFloat ,font : UIFont?) -> NSMutableAttributedString {
        let attrs = [NSFontAttributeName : font ?? UIFont.systemFontOfSize(8)]
        return NSMutableAttributedString(string:self, attributes:attrs)
    }
    
    
    //    var color : UIColor{
    //        return UIColor(hexString: self) ?? UIColor.blackColor()
    //    }
    
    
    
    
    
}

