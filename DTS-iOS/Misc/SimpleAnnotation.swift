//
//  SimpleAnnotation.swift
//  DTS-iOS
//
//  Created by Viktor on 18/07/2016.
//  Copyright © 2016 Mac, LLC. All rights reserved.
//

import UIKit
import MapKit

class SimpleAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }

}
