//
//  Poi.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 09/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import CoreLocation

class Poi {
    let title: String?
    let subtitle: String?
    let description: String?
    let coordinate: CLLocationCoordinate2D
    var annotation: PoiAnnotation {
        didSet {
            annotation.poi = self
        }
    }
    
    init(title: String?, subtitle: String?, description: String?, coordinate: CLLocationCoordinate2D, annotation: PoiAnnotation) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.coordinate = coordinate
        self.annotation = annotation
    }
}
