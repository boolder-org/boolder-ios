//
//  BottomSheetView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 04/01/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

@available(iOS 26.0, *)
struct BottomSheetView<Content: View>: View {
    @Binding var isPresented: Bool
    @ViewBuilder var content: () -> Content
    
    @State private var dragOffset: CGFloat = 0
    @State private var animatedPresentation: Bool = false
    
    private let dismissThreshold: CGFloat = 100
    
    var body: some View {
        GeometryReader { geo in
            let calculatedHeight = geo.size.height * 0.5
            let sheetY = geo.size.height - calculatedHeight
            let offscreenY = geo.size.height + 20
            
            // Fixed position container - content renders at final position inside
            ZStack(alignment: .top) {
                content()
                    .frame(width: geo.size.width, height: calculatedHeight)
            }
            .frame(width: geo.size.width, height: calculatedHeight)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -5)
            // Position the entire container - this is what animates
            .position(
                x: geo.size.width / 2,
                y: (animatedPresentation ? sheetY : offscreenY) + calculatedHeight / 2 + max(0, dragOffset)
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.height
                    }
                    .onEnded { value in
                        if value.translation.height > dismissThreshold {
                            withAnimation(.easeOut(duration: 0.25)) {
                                animatedPresentation = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                isPresented = false
                            }
                        }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            dragOffset = 0
                        }
                    }
            )
            .onChange(of: isPresented) { oldValue, newValue in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    animatedPresentation = newValue
                }
            }
            .onAppear {
                if isPresented {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        animatedPresentation = true
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .allowsHitTesting(isPresented)
    }
}

