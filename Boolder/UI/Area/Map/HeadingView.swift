//
//  HeadingView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 10/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class HeadingView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didLoad()
    }
    
    var headingAccuracy: CLLocationDirectionAccuracy = 90 {
        didSet {
            headingArcLayer.path = arcPath(angleInDegrees: CGFloat(headingAccuracy))
            headingArcLayer.isHidden = (headingAccuracy >= 90)
        }
    }
    
    private var headingArcLayer: CAShapeLayer!
    
    private func didLoad() {
        if headingArcLayer == nil {
            headingArcLayer = CAShapeLayer()
            headingArcLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.type = .radial
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            
            gradientLayer.colors = [
                UIColor(named: "AccentColor")!.withAlphaComponent(0.0).cgColor,
                UIColor(named: "AccentColor")!.withAlphaComponent(0.8).cgColor,
                UIColor(named: "AccentColor")!.withAlphaComponent(0.0).cgColor
            ]
            
            gradientLayer.frame = bounds
            gradientLayer.mask = headingArcLayer
            
            layer.addSublayer(gradientLayer)
        }
    }
    
    private func arcPath(angleInDegrees: CGFloat) -> CGPath {
        
        let bezierPath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.size.width/2, y: bounds.size.height/2),
            radius: bounds.size.height/2,
            startAngle: (-90-angleInDegrees) * CGFloat.pi / 180,
            endAngle: (-90+angleInDegrees) * CGFloat.pi / 180,
            clockwise: true
        )
        
        bezierPath.addLine(to: CGPoint(x: bounds.size.width/2, y: bounds.size.height/2))
        
        return bezierPath.cgPath
    }
}
