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
    
    
    var closeButton: some View {
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
    }
    
    var contentView: some View {
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
                                    LineView(problem: problem, drawPercentage: .constant(1), pinchToZoomScale: $pinchToZoomState.scale)
                                    
                                    GeometryReader { geo in
                                        if let firstPoint = problem.line?.firstPoint {
                                            ProblemCircleView(problem: problem, isDisplayedOnPhoto: true)
                                                .scaleEffect(1/pinchToZoomState.scale)
                                                .position(x: firstPoint.x * geo.size.width, y: firstPoint.y * geo.size.height)
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
    }
    var body: some View {
        VStack {
            ZStack {
                closeButton
                    .padding()
                    .zIndex(2)
                contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .edgesIgnoringSafeArea(.all)
                .zIndex(1)
            }
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//struct TopoFullScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopoFullScreenView()
//    }
//}
