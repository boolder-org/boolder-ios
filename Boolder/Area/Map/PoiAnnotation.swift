//
//  PoiAnnotation.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import MapKit

class PoiAnnotation: NSObject, MKAnnotation {
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    internal var title: String?
    internal var subtitle: String?
    var glyphColor = UIColor.gray
}
