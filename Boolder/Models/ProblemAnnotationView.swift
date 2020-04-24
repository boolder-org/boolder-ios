//
//  ProblemAnnotationView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/03/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import MapKit

class ProblemAnnotationView: MKMarkerAnnotationView {

    static let ReuseID = "problemAnnotation"
    
    // Fix found on https://medium.com/@hashemi.eng1985/map-view-does-not-show-all-annotations-at-first-9789d77f6a3a
    override var annotation: MKAnnotation? {
        willSet {
            if let problem = newValue as? ProblemAnnotation {
                if problem.displayLabel.isEmpty {
                    self.displayPriority = .defaultLow
                }
                else {
                    if(problem.belongsToCircuit) {
                        self.displayPriority = .defaultLow
                    }
                    else {
                        self.displayPriority = .required
                    }
                }
                
                glyphText = problem.displayLabel
                markerTintColor = problem.displayColor()
                
//                if(problem.boulderIdentifier.isEmpty) {
//                    clusteringIdentifier = nil
//                }
//                else {
//                    clusteringIdentifier = "problem-\(problem.displayColor())"
//                }
            }
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
