//
//  BezierView.swift
//  Bezier
//
//  Created by Ramsundar Shandilya on 10/14/15.
//  Copyright © 2015 Y Media Labs. All rights reserved.
//

// MIT License
// https://github.com/Ramshandilya/Bezier/blob/master/LICENSE

import UIKit
import Foundation

protocol BezierViewDataSource: class {
    func bezierViewDataPoints(bezierView: BezierView) -> [CGPoint]
}

class BezierView: UIView {
   
    private let kStrokeAnimationKey = "StrokeAnimationKey"
    private let kFadeAnimationKey = "FadeAnimationKey"
    
    //MARK: Public members
    weak var dataSource: BezierViewDataSource?
    
    var lineColor = #colorLiteral(red: 0.07843137255, green: 0.4509803922, blue: 0.7921568627, alpha: 1)
    
    var animates = true
    
    var lineLayer = CAShapeLayer()
    
    //MARK: Private members
    
    private var dataPoints: [CGPoint]? {
		return dataSource?.bezierViewDataPoints(bezierView: self)
    }
    
    private let cubicCurveAlgorithm = CubicCurveAlgorithm()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.sublayers?.forEach({ (layer: CALayer) -> () in
            layer.removeFromSuperlayer()
        })
        
        drawSmoothLines()
        
        animateLayers()
    }
    
    private func drawSmoothLines() {
        
        guard let points = dataPoints else {
            return
        }
        
		let controlPoints = cubicCurveAlgorithm.controlPointsFromPoints(dataPoints: points)
        
        
        let linePath = UIBezierPath()
		
		for i in 0..<points.count {
			let point = points[i];
			
			if i==0 {
				linePath.move(to: point)
			} else {
				let segment = controlPoints[i-1]
				linePath.addCurve(to: point, controlPoint1: segment.controlPoint1, controlPoint2: segment.controlPoint2)
			}
		}
        
        lineLayer = CAShapeLayer()
		lineLayer.path = linePath.cgPath
		lineLayer.fillColor = UIColor.clear.cgColor
		lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineWidth = 4.0
        
		lineLayer.shadowColor = UIColor.black.cgColor
        lineLayer.shadowOffset = CGSize(width: 0, height: 8)
        lineLayer.shadowOpacity = 0.5
        lineLayer.shadowRadius = 6.0
        
        self.layer.addSublayer(lineLayer)
        
        if animates {
            lineLayer.strokeEnd = 0
        }
    }
}

extension BezierView {
    
    func animateLayers() {
        animateLine()
    }
    
    func animateLine() {
        
        let growAnimation = CABasicAnimation(keyPath: "strokeEnd")
        growAnimation.toValue = 1
        growAnimation.beginTime = CACurrentMediaTime() + 0.5
        growAnimation.duration = 0.3
		growAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
		growAnimation.fillMode = CAMediaTimingFillMode.forwards
		growAnimation.isRemovedOnCompletion = false
		lineLayer.add(growAnimation, forKey: kStrokeAnimationKey)
    }
    
}

