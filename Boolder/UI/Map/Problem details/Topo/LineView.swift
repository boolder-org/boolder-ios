//
//  LineView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 09/11/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct LineView: View {
    let line: Line
    @Binding var drawPercentage: CGFloat
    
    @Binding var pinchToZoomScale: CGFloat
    
    var problem: Problem {
        line.problem
    }
    
    var body: some View {
        ResizablePath(path: linePath)
            .trim(from: 0, to: drawPercentage) // make the path animatable chunk by chunk
            .stroke(
                Color(problem.circuitUIColorForPhotoOverlay),
                style: StrokeStyle(lineWidth: 4/pinchToZoomScale, lineCap: .round, lineJoin: .round)
            )
            .modifier(DropShadow())
    }
    
    private var linePath: Path {
//        guard line != nil else { return Path() }
        guard linePoints.count > 0 else { return Path() }
        
        let points = linePoints
        let controlPoints = CubicCurveAlgorithm().controlPointsFromPoints(dataPoints: points)
        
        return Path { path in
            for i in 0..<points.count {
                let point = points[i]
                
                if i==0 {
                    path.move(to: CGPoint(x: point.x, y: point.y))
                } else {
                    let segment = controlPoints[i-1]
                    path.addCurve(to: point, control1: segment.controlPoint1, control2: segment.controlPoint2)
                }
            }
        }
    }
    
    private var linePoints: [CGPoint] {
        if let line = line.coordinates {
            return line.map{CGPoint(x: $0.x, y: $0.y)}
        }
        else {
            return []
        }
    }
}

//struct LineView_Previews: PreviewProvider {
//    static var previews: some View {
//        LineView(problem: .constant(dataStore.problems.first!), drawPercentage: .constant(0))
//    }
//}

struct ResizablePath: Shape {
    let path: Path

    func path(in rect: CGRect) -> Path {
        let transform = CGAffineTransform(scaleX: rect.width, y: rect.height)
        return path.applying(transform)
    }
}
