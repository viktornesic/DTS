//
//  ImageProperty.swift
//  CoucouApp
//
//  Created by Viktor on 03/11/2016.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ImageKeys: String {
    case id = "id"
    case propertyId = "property_id"
    case mediaFileName = "media_filename"
    case displayOrder = "display_order"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case type = "type"
    case completed = "completed"
    case deleted = "deleted"
    
}

class PropertyImage: NSObject {
    var id: Int?
    var propertyId: Int?
    var mediaFileName: String?
    var displayOrder: String?
    var createdAt: String?
    var updatedAt: String?
    var type: String?
    var completed: Int?
    var deleted: Int?
    
    init(id: Int,propertyId: Int,mediaFileName: String,displayOrder: String,createdAt: String,updatedAt: String,type: String,completed: Int,deleted: Int) {
        self.id = id
        self.propertyId = propertyId
        self.displayOrder = displayOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.type = type
        self.completed = completed
        self.deleted = deleted
    }
    required init(withAttributes attributes: OptionalSwiftJSONParameters) throws {
        super.init()
        self.id = ImageKeys.id.rawValue =/ attributes
        self.propertyId = ImageKeys.propertyId.rawValue =/ attributes
        self.displayOrder = ImageKeys.displayOrder.rawValue => attributes
        self.createdAt = ImageKeys.createdAt.rawValue => attributes
        self.updatedAt = ImageKeys.updatedAt.rawValue => attributes
        self.type = ImageKeys.type.rawValue => attributes
        self.completed = ImageKeys.completed.rawValue =/ attributes
        self.deleted = ImageKeys.deleted.rawValue =/ attributes

        
    }
    override init () {
        super.init()
    }
    class func parseArrayinToModal(withAttributes attributes : [JSON]?) -> AnyObject {
        
        var images: [PropertyImage] = []
        
        guard let attri = attributes else {
            
            return([] as? AnyObject?)!!
        }
        for dict in attri {
            do {
                let modal = try PropertyImage(withAttributes: dict.dictionaryValue)
                images.append(modal)
            }
            catch _ {
                
            }
        }
        return (images as AnyObject?)!
    }


    
}
