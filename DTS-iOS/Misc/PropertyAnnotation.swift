//
//  PropertyAnnotation.swift
//  DTS-iOS
//
//  Created by Viktor on 15/04/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import MapKit

class PropertyAnnotation: NSObject, MKAnnotation {
    var dictProperty: NSDictionary!
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var img: UIImage?
    var anTag: Int
    var price: String?
    var type: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, img: UIImage?, withPropertyDictionary property: NSDictionary, andTag tag: Int, andPrice price: String?, andType type: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.img = img
        self.dictProperty = property
        self.anTag = tag
        self.price = price
        self.type = type
    }
}
