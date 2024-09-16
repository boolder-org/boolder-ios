//
//  InfiniteScrollView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 16/09/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct InfiniteScrollView<Content: View, T: Identifiable>: View {
    // Original items
    private var items: [T]
    private var content: (T) -> Content
    
    // Items with duplicates for infinite effect
    private var totalItems: [T]
    
    // Page width (assumed to be the width of the device)
    private var pageWidth: CGFloat
    
    // Current page index
    @State private var currentIndex: Int = 1
    
    // Offset binding
    @State private var offset: CGFloat = 0
    
    init(items: [T], @ViewBuilder content: @escaping (T) -> Content) {
        self.items = items
        self.content = content
        // Duplicate last and first items
        if let first = items.first, let last = items.last {
            self.totalItems = [last] + items + [first]
        } else {
            self.totalItems = items
        }
        // Assuming full screen width; alternatively, you can make this dynamic
        self.pageWidth = UIScreen.main.bounds.width
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(totalItems) { item in
                        content(item)
                            .frame(width: width, height: geometry.size.height)
                    }
                }
            }
            .content.offset(x: -CGFloat(currentIndex) * width + offset)
            .frame(width: width, height: geometry.size.height, alignment: .leading)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation.width
                    }
                    .onEnded { gesture in
                        let threshold: CGFloat = width / 2
                        var newIndex = currentIndex
                        
                        if gesture.predictedEndTranslation.width < -threshold {
                            newIndex += 1
                        } else if gesture.predictedEndTranslation.width > threshold {
                            newIndex -= 1
                        }
                        
                        withAnimation {
                            currentIndex = newIndex
                            offset = 0
                        }
                        
                        handleInfiniteScroll(width: width)
                    }
            )
            .onAppear {
                // Set the initial offset to the first real item
                currentIndex = 1
            }
            .onChange(of: currentIndex) { _ in
                handleInfiniteScroll(width: width)
            }
        }
    }
    
    private func handleInfiniteScroll(width: CGFloat) {
        let count = totalItems.count
        if currentIndex == 0 {
            // Jump to the last real item
            DispatchQueue.main.async {
                withAnimation(.none) {
                    currentIndex = count - 2
                }
            }
        } else if currentIndex == count - 1 {
            // Jump to the first real item
            DispatchQueue.main.async {
                withAnimation(.none) {
                    currentIndex = 1
                }
            }
        }
    }
}
