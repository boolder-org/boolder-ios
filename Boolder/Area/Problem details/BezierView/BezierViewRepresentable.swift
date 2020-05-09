//
//  BezierViewRepresentable.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 26/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct BezierViewRepresentable: UIViewRepresentable {
    var problem: Problem
    
    func makeUIView(context: Context) -> BezierView {
        let bezierView = BezierView()
        
        if problem.topo?.line != nil && problem.isPhotoPresent() {
            bezierView.dataSource = context.coordinator
        }
        
        bezierView.lineColor = problem.circuitUIColor
        return bezierView
    }
    
    func updateUIView(_ view: BezierView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, BezierViewDataSource {
        var parent: BezierViewRepresentable

        init(_ parent: BezierViewRepresentable) {
            self.parent = parent
        }
        
        func bezierViewDataPoints(bezierView: BezierView) -> [CGPoint] {
            if let line = parent.problem.topo?.line {
                return line.map{CGPoint(x: $0.x * Double(bezierView.bounds.size.width), y: $0.y * Double(bezierView.bounds.size.height))}
            }
            else {
                return []
            }
        }
    }
}
