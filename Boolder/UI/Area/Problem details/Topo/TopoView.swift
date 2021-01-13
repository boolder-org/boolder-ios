//
//  TopoView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 21/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopoView: View {
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var odrManager: ODRManager
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var problem: Problem
    @State private var lineDrawPercentage: CGFloat = .zero
    @Binding var areaResourcesDownloaded: Bool
    
    @ObservedObject var pinchToZoomState: PinchToZoomState
    
    var body: some View {
        ZStack(alignment: .center) {
            
            Group {
                if areaResourcesDownloaded {
                    if let topoPhoto = problem.mainTopoPhoto {
                        
                        Group {
                            Image(uiImage: topoPhoto)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            
                            LineView(problem: $problem, drawPercentage: $lineDrawPercentage, pinchToZoomScale: $pinchToZoomState.scale)
                            
                            GeometryReader { geo in
                                if let lineStart = lineStart(problem: problem, inRectOfSize: geo.size) {
                                    ProblemCircleView(problem: problem, isDisplayedOnPhoto: true)
                                        .scaleEffect(1/pinchToZoomState.scale)
                                        .offset(lineStart)
                                }
                                
                                ForEach(problem.otherProblemsOnSameTopo) { secondaryProblem in
                                    if let lineStart = lineStart(problem: secondaryProblem, inRectOfSize: geo.size) {
                                        ProblemCircleView(problem: secondaryProblem, isDisplayedOnPhoto: true)
                                            .offset(lineStart)
                                            .opacity(pinchToZoomState.isPinching ? 0 : 1)
                                            .animation(.easeIn(duration: 0.5))
                                    }
                                }
                            }
                        }
                        .scaleEffect(pinchToZoomState.scale, anchor: pinchToZoomState.anchor)
                        .offset(pinchToZoomState.offset)
                        .overlay(PinchToZoom(state: pinchToZoomState))
                        
                    }
                    else {
                        Image("nophoto")
                            .font(.system(size: 60))
                            .foregroundColor(Color.gray)
                    }
                    
                    // We do this on top of the PinchToZoom view to be able to intercept taps on secondary problems
                    GeometryReader { geo in
                        ForEach(problem.otherProblemsOnSameTopo) { secondaryProblem in
                            if let lineStart = lineStart(problem: secondaryProblem, inRectOfSize: geo.size) {
                                Button(action: {
                                    switchToProblem(secondaryProblem)
                                }) {
                                    // FIXME: use constant for size
                                    Circle().frame(width: 28, height: 28).foregroundColor(.clear)
                                }
                                .offset(lineStart)
                            }
                        }
                    }
                }
                else {
                    ImageLoadingView(progress: $odrManager.downloadProgress)
                        .aspectRatio(4/3, contentMode: .fill)
                }
            }
            
            HStack {
                VStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(UIColor.init(white: 1.0, alpha: 0.8)))
                            .padding(16)
                            .shadow(color: Color.gray, radius: 8, x: 0, y: 0)
                    }
                    Spacer()
                }
                Spacer()
            }
            .opacity(pinchToZoomState.isPinching ? 0 : 1)
            .animation(.easeIn(duration: 0.5))
        }
        .aspectRatio(4/3, contentMode: .fit)
        .background(Color(white: 0.9, opacity: 1))
        .onAppear {
            // hack to make the animation start after the view is properly loaded
            // I tried doing it synchronously by I couldn't make it work :grimacing:
            // I also tried to use a lower value for the delay but it doesn't work (no animation at all)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animate { lineDrawPercentage = 1.0 }
            }
        }
    }
    
    func lineStart(problem: Problem, inRectOfSize size: CGSize) -> CGSize? {
        guard let lineFirstPoint = problem.lineFirstPoint() else { return nil }
        
        return CGSize(
            width:  (CGFloat(lineFirstPoint.x) * size.width) - 14,
            height: (CGFloat(lineFirstPoint.y) * size.height) - 14
        )
    }
    
    func switchToProblem(_ newProblem: Problem) {
        lineDrawPercentage = 0.0
        problem = newProblem
        
        // doing it async to be sure that the line is reset to zero
        // (there's probably a cleaner way to do it)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animate { lineDrawPercentage = 1.0 }
        }
    }
    
    func animate(action: () -> Void) {
        withAnimation(Animation.easeInOut(duration: 0.5)) {
            action()
        }
    }
}

//struct TopoView_Previews: PreviewProvider {
//    static let dataStore = DataStore()
//    
//    static var previews: some View {
//        TopoView(problem: .constant(dataStore.problems.first!), areaResourcesDownloaded: .constant(true), scale: .constant(1))
//    }
//}
