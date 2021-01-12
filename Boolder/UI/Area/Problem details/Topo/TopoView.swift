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
    @State private var drawPercentage: CGFloat = .zero // FIXME: rename
    @Binding var areaResourcesDownloaded: Bool
    
//    @State var showImageViewer: Bool = false
//    @State var image = Image("topo-265")
    
    @State var scale: CGFloat = 1.0
    @State var anchor: UnitPoint = .center
    @State var offset: CGSize = .zero
    @State var isPinching: Bool = false
    
    var body: some View {
        ZStack(alignment: .center) {
            
            Group {
                if areaResourcesDownloaded {
                    if let topoPhoto = problem.mainTopoPhoto {
                        
                        Group {
                            Image(uiImage: topoPhoto)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            
                            //                    ImageViewer(image: self.$image, viewerShown: self.$showImageViewer)
                            
                            LineView(problem: $problem, drawPercentage: $drawPercentage)
                            
                            GeometryReader { geo in
                                if let lineStart = lineStart(problem: problem, inRectOfSize: geo.size) {
                                    ProblemCircleView(problem: problem, isDisplayedOnPhoto: true)
                                        .offset(lineStart)
                                        .animation(nil)
                                }
                            }
                        }
                        .scaleEffect(scale, anchor: anchor)
                        .offset(offset)
                        .animation(isPinching ? .none : .spring())
                        .overlay(PinchZoom(scale: $scale, anchor: $anchor, offset: $offset, isPinching: $isPinching))
                    }
                    else {
                        Image("nophoto")
                            .font(.system(size: 60))
                            .foregroundColor(Color.gray)
                    }
                    
//                    if !isPinching {
                    
                    GeometryReader { geo in
                        ForEach(problem.otherProblemsOnSameTopo) { secondaryProblem in
                            if let lineStart = lineStart(problem: secondaryProblem, inRectOfSize: geo.size) {
                                Button(action: {
                                    switchToProblem(secondaryProblem)
                                }) {
                                    ProblemCircleView(problem: secondaryProblem, isDisplayedOnPhoto: true)
                                }
                                .offset(lineStart)
                                .opacity(isPinching ? 0 : 1)
                                .animation(.easeIn(duration: 0.5))
//                                .transition(.opacity)
//                                .transition(
//                                    AnyTransition.opacity.animation(.easeInOut(duration: 2.0))
//                                )
                            }
//                        }
                        
                    }
                    }
                }
                else {
                    ImageLoadingView(progress: $odrManager.downloadProgress)
                        .aspectRatio(4/3, contentMode: .fill)
                }
            }
            
            
            // FIXME: move to ProblemDetailsView
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
        }
        .aspectRatio(4/3, contentMode: .fit)
        .background(Color(white: 0.9, opacity: 1))
        .onAppear {
            // hack to make the animation start after the view is properly loaded
            // I tried doing it synchronously by I couldn't make it work :grimacing:
            // I also tried to use a lower value for the delay but it doesn't work (no animation at all)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animate { drawPercentage = 1.0 }
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
        drawPercentage = 0.0
        problem = newProblem

        // doing it async to be sure that the line is reset to zero
        // (there's probably a cleaner way to do it)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animate { drawPercentage = 1.0 }
        }
    }
    
    func animate(action: () -> Void) {
        withAnimation(Animation.easeInOut(duration: 0.5)) {
            action()
        }
    }
}

struct TopoView_Previews: PreviewProvider {
    static let dataStore = DataStore()
    
    static var previews: some View {
        TopoView(problem: .constant(dataStore.problems.first!), areaResourcesDownloaded: .constant(true))
    }
}
