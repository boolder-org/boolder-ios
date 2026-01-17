//
//  SegmentType.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 17/01/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//


//
//  CGPathExtensions.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/03/2025.
//  Copyright © 2025 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreGraphics

// MARK: - CGPath Iteration
extension CGPath {
    /// Iterates over each element in the CGPath.
    func forEach(body: @escaping (CGPathElement) -> Void) {
        // The callback pointer will be our block.
        let callback: @convention(block) (UnsafePointer<CGPathElement>) -> Void = { elementPointer in
            body(elementPointer.pointee)
        }
        // Pass the block as an unsafe mutable raw pointer.
        let unsafeBody = unsafeBitCast(callback, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody) { (info, elementPointer) in
            let block = unsafeBitCast(info, to: (@convention(block) (UnsafePointer<CGPathElement>) -> Void).self)
            block(elementPointer)
        }
    }
}

// MARK: - Helper functions for distance and Bezier calculations
fileprivate func distance(from: CGPoint, to: CGPoint) -> CGFloat {
    let dx = from.x - to.x
    let dy = from.y - to.y
    return sqrt(dx * dx + dy * dy)
}

fileprivate func quadBezierPoint(t: CGFloat, start: CGPoint, control: CGPoint, end: CGPoint) -> CGPoint {
    let mt = 1 - t
    let x = mt * mt * start.x + 2 * mt * t * control.x + t * t * end.x
    let y = mt * mt * start.y + 2 * mt * t * control.y + t * t * end.y
    return CGPoint(x: x, y: y)
}

fileprivate func cubicBezierPoint(t: CGFloat, start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint) -> CGPoint {
    let mt = 1 - t
    let mt2 = mt * mt
    let t2 = t * t
    let a = mt2 * mt
    let b = 3 * mt2 * t
    let c = 3 * mt * t2
    let d = t * t2
    let x = a * start.x + b * control1.x + c * control2.x + d * end.x
    let y = a * start.y + b * control1.y + c * control2.y + d * end.y
    return CGPoint(x: x, y: y)
}

// MARK: - Representing a path segment
enum SegmentType {
    case line(to: CGPoint)
    case quadCurve(control: CGPoint, to: CGPoint)
    case cubicCurve(control1: CGPoint, control2: CGPoint, to: CGPoint)
}

struct PathSegment {
    let start: CGPoint
    let type: SegmentType

    /// Approximates the length of the segment.
    func length(samples: Int = 100) -> CGFloat {
        switch type {
        case .line(let end):
            return distance(from: start, to: end)
        case .quadCurve(let control, let end):
            var length: CGFloat = 0
            var previous = start
            for i in 1...samples {
                let t = CGFloat(i) / CGFloat(samples)
                let point = quadBezierPoint(t: t, start: start, control: control, end: end)
                length += distance(from: previous, to: point)
                previous = point
            }
            return length
        case .cubicCurve(let control1, let control2, let end):
            var length: CGFloat = 0
            var previous = start
            for i in 1...samples {
                let t = CGFloat(i) / CGFloat(samples)
                let point = cubicBezierPoint(t: t, start: start, control1: control1, control2: control2, end: end)
                length += distance(from: previous, to: point)
                previous = point
            }
            return length
        }
    }
    
    /// Returns a point at a relative position (t between 0 and 1) along this segment.
    func point(at t: CGFloat) -> CGPoint {
        switch type {
        case .line(let end):
            return CGPoint(x: start.x + t * (end.x - start.x),
                           y: start.y + t * (end.y - start.y))
        case .quadCurve(let control, let end):
            return quadBezierPoint(t: t, start: start, control: control, end: end)
        case .cubicCurve(let control1, let control2, let end):
            return cubicBezierPoint(t: t, start: start, control1: control1, control2: control2, end: end)
        }
    }
}

// MARK: - Extract segments from a CGPath
fileprivate func segments(from path: CGPath) -> [PathSegment] {
    var segments: [PathSegment] = []
    var currentPoint = CGPoint.zero
    var subpathStart = CGPoint.zero
    
    path.forEach { element in
        switch element.type {
        case .moveToPoint:
            currentPoint = element.points[0]
            subpathStart = currentPoint
        case .addLineToPoint:
            let end = element.points[0]
            segments.append(PathSegment(start: currentPoint, type: .line(to: end)))
            currentPoint = end
        case .addQuadCurveToPoint:
            let control = element.points[0]
            let end = element.points[1]
            segments.append(PathSegment(start: currentPoint, type: .quadCurve(control: control, to: end)))
            currentPoint = end
        case .addCurveToPoint:
            let control1 = element.points[0]
            let control2 = element.points[1]
            let end = element.points[2]
            segments.append(PathSegment(start: currentPoint, type: .cubicCurve(control1: control1, control2: control2, to: end)))
            currentPoint = end
        case .closeSubpath:
            segments.append(PathSegment(start: currentPoint, type: .line(to: subpathStart)))
            currentPoint = subpathStart
        @unknown default:
            break
        }
    }
    return segments
}

// MARK: - Finding the point at a given percentage along a CGPath
extension CGPath {
    /// Returns the point at a given progress (0.0 to 1.0) along the path’s total length.
    func point(at percentage: CGFloat) -> CGPoint? {
        let pathSegments = segments(from: self)
        let totalLength = pathSegments.reduce(0) { $0 + $1.length() }
        let targetLength = percentage * totalLength
        
        var accumulated: CGFloat = 0
        for segment in pathSegments {
            let segLength = segment.length()
            if accumulated + segLength >= targetLength {
                let remainder = targetLength - accumulated
                let t = remainder / segLength
                return segment.point(at: t)
            }
            accumulated += segLength
        }
        return nil
    }
}

// MARK: - SwiftUI Example Usage
struct CGPathExtensionsView: View {
    var body: some View {
        // Define a path (in this case a cubic Bezier for demonstration)
        let path = Path { p in
            p.move(to: CGPoint(x: 50, y: 300))
            p.addCurve(to: CGPoint(x: 350, y: 300),
                       control1: CGPoint(x: 150, y: 50),
                       control2: CGPoint(x: 250, y: 550))
        }
        
        // Get the midpoint (50% along the path's total length)
        let midPoint = path.cgPath.point(at: 0.5) ?? .zero
        
        return ZStack {
            path.stroke(Color.blue, lineWidth: 2)
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .position(midPoint)
        }
        .frame(width: 400, height: 600)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CGPathExtensionsView()
    }
}