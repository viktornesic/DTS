//
//  Images.swift
//  CoucouApp
//
//  Created by Viktor on 03/11/2016.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ImageUrl: String {
    case raw = "raw"
    case extraSmall = "xs"
    case small = "sm"
    case medium = "md"
    case large = "lg"
    
}

class Image: NSObject {
    var raw: String?
    var extraSmall: String?
    var small: String?
    var medium: String?
    var large: String?
    
    init?(raw: String,extraSmall: String, small: String,medium: String,large: String)
    {
        self.raw = raw
        self.extraSmall = extraSmall
        self.small = small
        self.medium = medium
        self.large = large
    }
    
    required init(withAttributes attributes: OptionalSwiftJSONParameters) throws {
        super.init()
        self.raw = ImageUrl.raw.rawValue => attributes
        self.extraSmall = ImageUrl.extraSmall.rawValue => attributes
        self.small = ImageUrl.small.rawValue => attributes
        self.medium = ImageUrl.medium.rawValue => attributes
        self.large = ImageUrl.large.rawValue => attributes
    }
    
    override init () {
        super.init()
    }
    
    
    class func parseArrayinToModal(withAttributes attributes : [JSON]?) -> AnyObject {
        
        var images: [Image] = []
        
        guard let attri = attributes else {
            
            return([] as? AnyObject?)!!
        }
        for dict in attri {
            do {
                let modal = try Image(withAttributes: dict.dictionaryValue)
                images.append(modal)
            }
            catch _ {
                
            }
        }
        return (images as AnyObject?)!
    }
    

}
