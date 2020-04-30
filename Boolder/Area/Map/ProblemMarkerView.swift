//
//  ProblemMarkerView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 30/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import UIKit

class ProblemMarkerView: UIView {
    // MARK: Properties
    var isMinimal: Bool = true {
        didSet {
            guard isMinimal != oldValue else { return }
            
            if isMinimal {
                overlayCircleView.transform = CGAffineTransform(scaleX: 0.43, y: 0.43)
                circleView.transform = CGAffineTransform(scaleX: 0.33, y: 0.33)
                //        imageView.transform = CGAffineTransform(scaleX: 0.33, y: 0.33)
                //        imageView.alpha = 0
            } else {
                overlayCircleView.transform = .identity
                circleView.transform = .identity
                //        imageView.transform = .identity
                //        imageView.alpha = 1
            }
        }
    }
    
    // MARK: Subviews
    let overlayCircleView = UIView()
    let circleView = UIView()
    //  let imageView = UIImageView()
    
    // MARK: Constants
    private let borderSize: CGFloat = 2
    
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
        overlayCircleView.alpha = 0.3
        overlayCircleView.frame = bounds
        overlayCircleView.layer.cornerRadius = size / 2
        addSubview(overlayCircleView)
        
        circleView.frame = CGRect(x: borderSize, y: borderSize, width: bounds.width - 2 * borderSize, height: bounds.height - 2 * borderSize)
        circleView.layer.cornerRadius = (size - 2 * borderSize) / 2
        addSubview(circleView)
        
        overlayCircleView.transform = CGAffineTransform(scaleX: 0.43, y: 0.43)
        circleView.transform = CGAffineTransform(scaleX: 0.33, y: 0.33)
        
        //    imageView.frame = bounds
        //    imageView.contentMode = .center
        //    addSubview(imageView)
    }
    
    func setContent(color: UIColor, borderColor: UIColor? = nil) {
        overlayCircleView.backgroundColor = borderColor ?? color
        circleView.backgroundColor = color
        //    imageView.image = image
    }
}
