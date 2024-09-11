//
//  ImprovedTopoView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 11/09/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ImprovedTopoView: View {
    let topo: TopoWithPosition
    let problem: Problem
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            if topo.problems.contains(problem) {
                if problem.line?.coordinates != nil {
                    LineView(problem: problem, drawPercentage: .constant(1.0), pinchToZoomScale: .constant(1))
                }
                else {
                    //                Text("problem.missing_line")
                    //                    .padding(.vertical, 4)
                    //                    .padding(.horizontal, 8)
                    //                    .background(Color.gray.opacity(0.8))
                    //                    .foregroundColor(Color(UIColor.systemBackground))
                    //                    .cornerRadius(16)
                    //                    .transition(.opacity)
                    //                    .opacity(showMissingLineNotice ? 1.0 : 0.0)
                }
            }
            
            GeometryReader { geo in
                ForEach(topo.startGroups) { (group: StartGroup) in
                    ForEach(group.problems) { (p: Problem) in
                        if let firstPoint = p.lineFirstPoint {
                            ProblemCircleView(problem: p, isDisplayedOnPhoto: true)
                                .allowsHitTesting(false)
                                .position(x: firstPoint.x * geo.size.width, y: firstPoint.y * geo.size.height)
                                .zIndex(p == problem ? .infinity : p.zIndex)
                        }
                    }
                }
            }
//            
//            GeometryReader { geo in
//                TapLocationView { location in
////                    handleTap(at: Line.PhotoPercentCoordinate(x: location.x / geo.size.width, y: location.y / geo.size.height))
//                }
//            }
        }
    }
    
    var image: UIImage {
        topo.topo.onDiskPhoto!
    }
}

//#Preview {
//    ImprovedTopoView()
//}
