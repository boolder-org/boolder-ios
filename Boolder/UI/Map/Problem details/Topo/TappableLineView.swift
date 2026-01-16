//
//  TappableLineView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 16/01/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TappableLineView: View {
    let problem: Problem
    @Binding var counterZoomScale: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // Invisible wider stroke for easier tapping
            ResizablePath(path: linePath)
                .stroke(
                    Color.clear,
                    style: StrokeStyle(lineWidth: 30 * counterZoomScale, lineCap: .round, lineJoin: .round)
                )
                .contentShape(
                    ResizablePath(path: linePath)
                        .stroke(style: StrokeStyle(lineWidth: 30 * counterZoomScale, lineCap: .round, lineJoin: .round))
                )
            
            // Visible line
            LineView(problem: problem, drawPercentage: .constant(1.0), counterZoomScale: $counterZoomScale)
        }
        .onTapGesture {
            onTap()
        }
    }
    
    private var linePath: Path {
        guard problem.line != nil else { return Path() }
        guard linePoints.count > 0 else { return Path() }
        
        let points = linePoints
        let controlPoints = CubicCurveAlgorithm().controlPointsFromPoints(dataPoints: points)
        
        return Path { path in
            for i in 0..<points.count {
                let point = points[i]
                
                if i == 0 {
                    path.move(to: CGPoint(x: point.x, y: point.y))
                } else {
                    let segment = controlPoints[i-1]
                    path.addCurve(to: point, control1: segment.controlPoint1, control2: segment.controlPoint2)
                }
            }
        }
    }
    
    private var linePoints: [CGPoint] {
        if let line = problem.line?.coordinates {
            return line.map { CGPoint(x: $0.x, y: $0.y) }
        } else {
            return []
        }
    }
}

