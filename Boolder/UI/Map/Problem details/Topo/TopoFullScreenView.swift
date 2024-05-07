//
//  TopoFullScreenView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 10/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopoFullScreenView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let image: UIImage
    let problem: Problem
    
    @StateObject var pinchToZoomState = PinchToZoomState()
    
    // drag gesture (to dismiss the sheet)
    @State var dragOffset: CGSize = CGSize.zero
    @State var dragOffsetPredicted: CGSize = CGSize.zero
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(Color(UIColor.white))
                                .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .zIndex(2)
                
                VStack {
                    ZStack {
                        VStack {
                            Spacer()
                            Group {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .overlay(
                                        ZStack {
//                                            LineView(problem: problem, drawPercentage: .constant(1), pinchToZoomScale: $pinchToZoomState.scale)
                                            
                                            GeometryReader { geo in
                                                if let lineStart = lineStart(problem: problem, inRectOfSize: geo.size) {
                                                    ProblemCircleView(problem: problem, isDisplayedOnPhoto: true)
                                                        .scaleEffect(1/pinchToZoomState.scale)
                                                        .offset(lineStart)
                                                }
                                            }
                                        }
                                    )
                            }
                            Spacer()
                        }
                        .offset(x: 0, y: self.dragOffset.height) // drag gesture
                        .scaleEffect(pinchToZoomState.scale, anchor: pinchToZoomState.anchor)
                        .offset(pinchToZoomState.offset)
                        .overlay(PinchToZoom(state: pinchToZoomState))
                        .gesture(DragGesture()
                            .onChanged { value in
                                self.dragOffset = value.translation
                                self.dragOffsetPredicted = value.predictedEndTranslation
                            }
                            .onEnded { value in
                                if(self.dragOffset.height > 200
                                  || (self.dragOffsetPredicted.height > 0 && abs(self.dragOffsetPredicted.height) / abs(self.dragOffset.height) > 3)) {
                                    withAnimation(.spring()) {
                                        self.dragOffset = self.dragOffsetPredicted
                                    }
                                    presentationMode.wrappedValue.dismiss()
                                    
                                    return
                                }
                                withAnimation(.interactiveSpring()) {
                                    self.dragOffset = .zero
                                }
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .edgesIgnoringSafeArea(.all)
                .zIndex(1)
            }
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // TODO: make this DRY with other screens
    func lineStart(problem: Problem, inRectOfSize size: CGSize) -> CGSize? {
        //f FIXME: 
        guard let lineFirstPoint = problem.lines.first!.firstPoint else { return nil }
        
        return CGSize(
            width:  (CGFloat(lineFirstPoint.x) * size.width) - 14,
            height: (CGFloat(lineFirstPoint.y) * size.height) - 14
        )
    }
}

//struct TopoFullScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopoFullScreenView()
//    }
//}
