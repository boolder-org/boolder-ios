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
    
    var badgeView: UIImageView = UIImageView()
    
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
                
                // FIXME: make DRY (with self.refresh())
                if problem.isFavorite() {
                    self.badgeView.isHidden = false
                }
                else {
                    self.badgeView.isHidden = true
                }
                
                self.refreshBadge()
            }
        }
    }
    
    func refreshBadge() {
        if let problem = annotation as? ProblemAnnotation {
            if problem.isFavorite() {
                self.badgeView.isHidden = false
            }
            else {
                self.badgeView.isHidden = true
            }
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        let badgeImage = UIImage(systemName: "star.fill")!.withTintColor(.yellow, renderingMode: .alwaysOriginal)
        
        badgeView = UIImageView(image: badgeImage)
        badgeView.frame = CGRect(x: 20, y: -10, width: 16, height: 16)
        badgeView.layer.zPosition = 10
        badgeView.isHidden = true
        
        addSubview(badgeView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
