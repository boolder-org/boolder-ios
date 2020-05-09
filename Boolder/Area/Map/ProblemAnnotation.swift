//
//  ProblemAnnotation.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 09/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import MapKit

class ProblemAnnotation: NSObject, MKAnnotation {
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    let problem: Problem
    var displayLabel: String = ""
    
    init(problem: Problem) {
        self.problem = problem
    }

    func displayColor() -> UIColor {
        guard let circuitColor = problem.circuitColor else { return UIColor.gray }
        
        return circuitColor.uicolor
    }
}
