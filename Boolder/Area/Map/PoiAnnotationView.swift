//
//  CIrcuitAnnotationView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import MapKit

class PoiAnnotationView: MKMarkerAnnotationView {
    static let ReuseID = "poiAnnotation"
    
    override var annotation: MKAnnotation? {
        willSet {
            if let _ = newValue as? PoiAnnotation {
                self.displayPriority = .required
            }
        }
    }
}
