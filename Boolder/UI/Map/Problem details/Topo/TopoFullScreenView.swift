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
    
//    let image: UIImage
    @Binding var problem: Problem
    
    @State private var zoomScale: CGFloat = 1
    
//    @State var pinchToZoomState = PinchToZoomState()
//    // drag gesture (to dismiss the sheet)
//    @State var dragOffset: CGSize = CGSize.zero
//    @State var dragOffsetPredicted: CGSize = CGSize.zero
    
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
                
                ZoomableScrollView(zoomScale: $zoomScale) {
                    TopoView(problem: $problem)
                }
                .containerRelativeFrame(.horizontal)
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
