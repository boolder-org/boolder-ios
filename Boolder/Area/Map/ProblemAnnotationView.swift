//
//  ProblemAnnotationView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/03/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import MapKit

enum ProblemAnnotationViewSize: Int {
    case small
    case medium
    case full
}

class ProblemAnnotationView: MKAnnotationView {
    static let ReuseID = "problemAnnotation"
    
    // FIXME: use prepareForDisplay()
    // 	https://developer.apple.com/documentation/mapkit/mkannotationview/2921514-preparefordisplay
    override var annotation: MKAnnotation? {
        willSet {
            self.displayPriority = .defaultLow
        }
        didSet {
            refreshUI()
        }
    }
    
    var size: ProblemAnnotationViewSize = .small {
        didSet {
            guard size != oldValue else { return }
            refreshSize()
        }
    }
    
    private var hasBeenSetup = false
    private let frameSize: CGFloat = 28
    private let scaleSmall: CGFloat = 0.2
    private let scaleMedium: CGFloat = 0.4
    private let borderSize: CGFloat = 0
    
    private let overlayCircleView = UIView()
    private let circleView = UIView()
    private let label = UILabel()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
//        backgroundColor = UIColor.white
//        alpha = 1
        
        collisionMode = .circle
        frame = CGRect(x: -14, y: -14, width: frameSize, height: frameSize)
        
        circleView.frame = CGRect(x: borderSize, y: borderSize, width: bounds.width - 2 * borderSize, height: bounds.height - 2 * borderSize)
        circleView.layer.cornerRadius = (frameSize - 2 * borderSize) / 2
        addSubview(circleView)
        
        circleView.transform = CGAffineTransform(scaleX: scaleSmall, y: scaleSmall)
        
        hasBeenSetup = true
    }
    
    func refreshUI() {
        guard hasBeenSetup, let annotation = annotation as? ProblemAnnotation else { return }
        
        refreshSize()
        
        self.setContent(color: annotation.displayColor())
    }
    
    func setContent(color: UIColor, borderColor: UIColor? = nil) {
        circleView.backgroundColor = color
    }
    
    func refreshSize() {
        switch size {
        case .full:
            circleView.transform = .identity
        case .medium:
            circleView.transform = CGAffineTransform(scaleX: scaleMedium, y: scaleMedium)
        case .small:
            circleView.transform = CGAffineTransform(scaleX: scaleSmall, y: scaleSmall)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        refreshUI()
    }
    
    override var alignmentRectInsets: UIEdgeInsets {
        switch size {
        case .full:
            return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        case .medium:
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        case .small:
            return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        }
        
    }
}
