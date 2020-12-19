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
    case large
    case full
}

class ProblemAnnotationView: MKAnnotationView {
    static let ReuseID = "problemAnnotation"
    
    // FIXME: use prepareForDisplay()
    // 	https://developer.apple.com/documentation/mapkit/mkannotationview/2921514-preparefordisplay
    override var annotation: MKAnnotation? {
        willSet {
            if let annotation = newValue as? ProblemAnnotation {
                if(annotation.problem.isFavorite()) {
                    displayPriority = .required
                }
                else if(annotation.problem.isTicked()) {
                    displayPriority = .defaultHigh
                }
                else {
                    if annotation.problem.circuitColor != .offCircuit {
                        displayPriority = MKFeatureDisplayPriority.init(250)
                    }
                    else {
                        displayPriority = MKFeatureDisplayPriority.init(249)
                    }
                }
                
            }
        }
        didSet {
            refreshUI()
        }
    }
    
    var size: ProblemAnnotationViewSize = .small {
        didSet {
            self.isEnabled = (size == .full || size == .large || size == .medium)
            guard size != oldValue else { return }
            refreshSize()
        }
    }
    
    private var hasBeenSetup = false
    private let frameSize: CGFloat = 28
    private let scaleSmall: CGFloat = 0.2
    private let scaleMedium: CGFloat = 0.4
    private let scaleLarge: CGFloat = 0.7
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
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
//        guard let annotation = annotation as? ProblemAnnotation else { return }
//        print("preparfordisplay \(annotation.id!)")
        
        refreshUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        size = .small
    }
    
    func initUI() {
        collisionMode = .circle
        frame = CGRect(x: -14, y: -14, width: frameSize, height: frameSize)
        
        circleView.frame = CGRect(x: borderSize, y: borderSize, width: bounds.width - 2 * borderSize, height: bounds.height - 2 * borderSize)
        circleView.layer.cornerRadius = (frameSize - 2 * borderSize) / 2
        addSubview(circleView)
        
        circleView.transform = CGAffineTransform(scaleX: scaleSmall, y: scaleSmall)
        
        label.frame = CGRect(x: 0, y: 0, width: frameSize, height: frameSize)
        label.textColor = .systemBackground
        label.text = ""
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        addSubview(label)
        
        hasBeenSetup = true
    }
    
    func refreshUI() {
        guard hasBeenSetup, let annotation = annotation as? ProblemAnnotation else { return }
        
        refreshSize()
        
        circleView.backgroundColor = annotation.tintColor
        
        label.text = annotation.glyphText
        label.textColor = (annotation.tintColor == Circuit.CircuitColor.white.uicolor) ? .black : .systemBackground
    }
    
    func refreshSize() {
        switch size {
        case .full:
            circleView.transform = .identity
            label.isHidden = false
            label.alpha = 1
        case .large:
            circleView.transform = CGAffineTransform(scaleX: scaleLarge, y: scaleLarge)
            label.isHidden = true
            label.alpha = 0
        case .medium:
            circleView.transform = CGAffineTransform(scaleX: scaleMedium, y: scaleMedium)
            label.isHidden = true
            label.alpha = 0
        case .small:
            circleView.transform = CGAffineTransform(scaleX: scaleSmall, y: scaleSmall)
            label.isHidden = true
            label.alpha = 0
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
        case .large:
            return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        case .medium:
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        case .small:
            return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        }
        
    }
}
