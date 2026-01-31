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
    
    private var linePath: Path {
        problem.line?.path ?? Path()
    }
    
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
}

