//
//  LineView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 09/11/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct LineView: View {
    let linePath: Path
    let color: Color
    @Binding var drawPercentage: CGFloat
    @Binding var counterZoomScale: CGFloat
    
    init(problem: Problem, drawPercentage: Binding<CGFloat>, counterZoomScale: Binding<CGFloat>) {
        self.linePath = problem.line?.path ?? Path()
        self.color = Color(problem.circuitUIColorForPhotoOverlay)
        self._drawPercentage = drawPercentage
        self._counterZoomScale = counterZoomScale
    }
    
    init(line: Line, color: Color, drawPercentage: Binding<CGFloat>, counterZoomScale: Binding<CGFloat>) {
        self.linePath = line.path
        self.color = color
        self._drawPercentage = drawPercentage
        self._counterZoomScale = counterZoomScale
    }
    
    var body: some View {
        ResizablePath(path: linePath)
            .trim(from: 0, to: drawPercentage)
            .stroke(
                color,
                style: StrokeStyle(lineWidth: 4 * counterZoomScale, lineCap: .round, lineJoin: .round)
            )
            .modifier(DropShadow())
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
