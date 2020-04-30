//
//  ProblemAnnotationView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/03/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import MapKit

enum ProblemAnnotationViewSize: Int {
    case dot
    case full
}

class ProblemAnnotationView: MKAnnotationView {
    static let ReuseID = "problemAnnotation"
    
    override var annotation: MKAnnotation? {
        didSet {
            refreshUI()
        }
    }
    
    var size: ProblemAnnotationViewSize = .dot {
        didSet {
            guard size != oldValue else { return }
            
            switch size {
            case .full:
                problemMarkerView.isMinimal = false
                
            case .dot:
                problemMarkerView.isMinimal = true
            }
        }
    }
    
    var hasBeenSetup = false
    let problemMarkerView = ProblemMarkerView(size: 28)
    let textLabel = UILabel()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        backgroundColor = UIColor.clear
        
        //      addSubview(textLabel)
        //      textLabel.textAlignment = .center
        //      textLabel.padding = UIEdgeInsets(top: topPadding, left: sidePadding, bottom: topPadding, right: sidePadding)
        
        addSubview(problemMarkerView)
        
        hasBeenSetup = true
    }
    
    func refreshUI() {
        guard hasBeenSetup, let annotation = annotation as? ProblemAnnotation else { return }
        
        problemMarkerView.setContent(color: annotation.displayColor())
        
        //        problemMarkerView.center = CGPoint(x: , y: )
        //        center = CGPoint(x: center.x, y: center.y)
        //        centerOffset = CGPoint(x: 0, y: )
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        refreshUI()
    }
}
