//
//  DraggableSheet.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 29/03/2025.
//  Copyright © 2025 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct DraggableSheet: View {
    @State private var currentHeight: CGFloat = 60   // Starting height of the sheet
    @State private var dragOffset: CGFloat = 0         // Temporary offset during dragging

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Main background content (replace with your content)
//                Color.blue
//                    .ignoresSafeArea()
                
                // The draggable sheet view
                VStack {
                    // A small drag indicator
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray)
                        .frame(width: 40, height: 6)
                        .padding(8)
                    
                    // Your sheet content goes here
                    Text("12 voies")
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 5)
                // Adjust the offset so the sheet starts at the bottom with currentHeight visible
                .offset(y: max(geometry.size.height - currentHeight + dragOffset, 0))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Update the offset while dragging
                            dragOffset = value.translation.height
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                // If the user drags upward more than 100 points, expand the sheet
                                if -value.translation.height > 20 {
                                    currentHeight = geometry.size.height - 100
                                }
                                // Otherwise, if the user drags downward more than 100 points, collapse
                                else if value.translation.height > 20 {
                                    currentHeight = 60
                                }
                                // Reset temporary drag offset
                                dragOffset = 0
                            }
                        }
                )
                .clipped()
            }
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.3)),
                alignment: .bottom
            )
        }
    }
}

struct DraggableSheet_Previews: PreviewProvider {
    static var previews: some View {
        DraggableSheet()
    }
}
