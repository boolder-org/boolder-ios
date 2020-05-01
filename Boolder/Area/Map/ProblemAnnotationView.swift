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
            if let problem = newValue as? ProblemAnnotation {
                if(problem.isFavorite()) {
                    self.displayPriority = .defaultHigh
                }
                else {
                    self.displayPriority = .defaultLow
                }
                
            }
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
    private var badgeView = UIImageView()
    
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
        
        label.frame = CGRect(x: 0, y: 0, width: frameSize, height: frameSize)
        label.textColor = .systemBackground
        label.text = ""
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        addSubview(label)
                
        badgeView = UIImageView()
        badgeView.frame = CGRect(x: 18, y: -6, width: 16, height: 16)
        badgeView.layer.zPosition = 10
        badgeView.isHidden = true
        badgeView.isUserInteractionEnabled = false
        addSubview(badgeView)
        
        hasBeenSetup = true
    }
    
    func refreshUI() {
        guard hasBeenSetup, let annotation = annotation as? ProblemAnnotation else { return }
        
        refreshSize()
        refreshBadge()
        
        circleView.backgroundColor = annotation.displayColor()
        label.text = annotation.displayLabel
    }
    
    func refreshSize() {
        switch size {
        case .full:
            circleView.transform = .identity
            label.isHidden = false
            label.alpha = 1
            badgeView.isHidden = false
            badgeView.alpha = 1
        case .medium:
            circleView.transform = CGAffineTransform(scaleX: scaleMedium, y: scaleMedium)
            label.isHidden = true
            label.alpha = 0
            badgeView.isHidden = true
            badgeView.alpha = 0
        case .small:
            circleView.transform = CGAffineTransform(scaleX: scaleSmall, y: scaleSmall)
            label.isHidden = true
            label.alpha = 0
            badgeView.isHidden = true
            badgeView.alpha = 0
        }
    }
    
    func refreshBadge() {
        guard let annotation = annotation as? ProblemAnnotation else { return }
        
        if annotation.isFavorite() {
            let badgeImage = UIImage(systemName: "star.fill")!.withTintColor(.yellow, renderingMode: .alwaysOriginal)
            //        let badgeImage = UIImage(systemName: "checkmark.circle.fill")!.withTintColor(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), renderingMode: .alwaysOriginal)
            
            badgeView.image = badgeImage
        }
        else {
            badgeView.image = nil
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
