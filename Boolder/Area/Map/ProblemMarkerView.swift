//
//  ProblemMarkerView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 30/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import UIKit

class ProblemMarkerView: UIView {
    let scaleSmall: CGFloat = 0.2
    let scaleMedium: CGFloat = 0.4
    
    
    // MARK: Properties
    var size: ProblemAnnotationViewSize = .small {
        didSet {
            guard size != oldValue else { return }
            
            switch size {
            case .full:
                circleView.transform = .identity
            case .medium:
                circleView.transform = CGAffineTransform(scaleX: scaleMedium, y: scaleMedium)
            case .small:
                circleView.transform = CGAffineTransform(scaleX: scaleSmall, y: scaleSmall)
            }
        }
    }
    
    // MARK: Subviews
    let overlayCircleView = UIView()
    let circleView = UIView()
    let label = UILabel()
    
    // MARK: Constants
    private let borderSize: CGFloat = 0
    
    // MARK: Life cycle
    init(size: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        
        initUI(size: size)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI
    private func initUI(size: CGFloat) {
//        backgroundColor = .white
        
        circleView.frame = CGRect(x: borderSize, y: borderSize, width: bounds.width - 2 * borderSize, height: bounds.height - 2 * borderSize)
        circleView.layer.cornerRadius = (size - 2 * borderSize) / 2
        addSubview(circleView)
        
        circleView.transform = CGAffineTransform(scaleX: scaleSmall, y: scaleSmall)
    }
    
    func setContent(color: UIColor, borderColor: UIColor? = nil) {
        circleView.backgroundColor = color
    }
}
