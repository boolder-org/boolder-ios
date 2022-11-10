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
    
    @State var scale: CGFloat = 1.0
    @State var anchor: UnitPoint = .center
    @State var offset: CGSize = .zero
    @State var isPinching: Bool = false
    
    @State private var currentAmount = 1.0
        @State private var previousAmount = 1.0
    
    var body: some View {
        VStack {
            if(true) {
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
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
//                                .scaleEffect(previousAmount*currentAmount, anchor: anchor)
//                                .offset(offset)
//                                .gesture(
//                                    MagnificationGesture()
//                                        .onChanged { amount in
//                                            print("amount: \(amount)")
//                                            currentAmount = amount
//                                        }
//                                        .onEnded { amount in
//                                            previousAmount *= currentAmount
//                                            print("final amount: \(previousAmount)")
//                                            currentAmount = 1
//                                        }
//                                )
//                                .simultaneousGesture(
//                                    DragGesture()
//                                        .onChanged { gesture in
//                                            offset = gesture.translation
//                                        }
////                                        .onEnded { _ in
////                                            if abs(offset.width) > 100 {
////                                                // remove the card
////                                            } else {
////                                                offset = .zero
////                                            }
////                                        }
//                                )
                                            
                                .scaleEffect(scale, anchor: anchor)
                                .offset(offset)
                                .overlay(PinchZoom(scale: $scale, anchor: $anchor, offset: $offset, isPinching: $isPinching))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black).edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                }
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//struct TopoFullScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopoFullScreenView()
//    }
//}
