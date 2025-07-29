//
//  LineView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 09/11/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct LineView: View {
    let problem: Problem
    @Binding var drawPercentage: CGFloat
    
    @Binding var counterZoomScale: CGFloat
    
    var body: some View {
        ResizablePath(path: problem.line?.path ?? Path())
            .trim(from: 0, to: drawPercentage) // make the path animatable chunk by chunk
            .stroke(
                Color(problem.circuitUIColorForPhotoOverlay),
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
