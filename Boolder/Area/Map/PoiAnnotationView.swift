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
    
    // FIXME: use prepareForDisplay()
    //     https://developer.apple.com/documentation/mapkit/mkannotationview/2921514-preparefordisplay
    override var annotation: MKAnnotation? {
        willSet {
            self.displayPriority = .required
        }
    }
}
