//
//  TopoFullScreenView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 10/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopoFullScreenView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var problem: Problem
    @State private var zoomScale: CGFloat = 1
    
    // drag gesture (to dismiss the sheet)
    @State var dragOffset: CGSize = CGSize.zero
    @State var dragOffsetPredicted: CGSize = CGSize.zero
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        
                        if #available(iOS 26, *) {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
                                    .padding(4)
                            }
                            .buttonStyle(.glass)
                            .buttonBorderShape(.circle)
                        }
                        else {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(Color(UIColor.white))
                                    .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    overlayInfos
                }
                .modify {
                    if #available(iOS 26, *) {
                        $0.edgesIgnoringSafeArea(.bottom)
                    }
                    else {
                        $0
                    }
                }
                .zIndex(2)
                
                ZoomableScrollView(zoomScale: $zoomScale) {
                    TopoView(problem: $problem, zoomScale: $zoomScale)
                }
                .containerRelativeFrame(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                .zIndex(1)
                .offset(x: 0, y: self.dragOffset.height) // drag gesture
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
                            dismiss()
                            
                            return
                        }
                        withAnimation(.interactiveSpring()) {
                            self.dragOffset = .zero
                        }
                    }
                )
                .background(Color.black)
                .edgesIgnoringSafeArea(.all)
                
            }
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var overlayInfos: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProblemInfoView(problem: problem, titleFont: .title2)
                .foregroundColor(.primary.opacity(0.8))
            
            ProblemActionButtonsView(problem: problem, withHorizontalPadding: false)
        }
        .modify {
            if #available(iOS 26, *) {
                $0
                    .padding()
                    .frame(minHeight: 140, alignment: .top)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
                    
            } else {
                $0
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(16)
            }
        }
    }
}

//struct TopoFullScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopoFullScreenView()
//    }
//}
