//
//  InfiniteTabView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 15/09/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct InfiniteTabView<Content: View, T: Identifiable>: View {
    // Original items
    private var items: [T]
    private var content: (T) -> Content
    
    // Items with duplicates for infinite effect
    private var totalItems: [T]
    
    // Current selected index
    @State private var currentIndex: Int = 1
    
    // Flag to prevent recursive updates
    @State private var isAdjusting: Bool = false
    
    init(items: [T], @ViewBuilder content: @escaping (T) -> Content) {
        self.items = items
        self.content = content
        // Duplicate last and first items
        if let first = items.first, let last = items.last {
            self.totalItems = [last] + items + [first]
        } else {
            self.totalItems = items
        }
    }
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<totalItems.count, id: \.self) { index in
                content(totalItems[index])
                    .tag(index)
                    .onAppear {
                        handlePageAppear(index: index)
                    }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .onAppear {
            // Start at the first real item
            currentIndex = 1
        }
    }
    
    private func handlePageAppear(index: Int) {
        guard !isAdjusting else { return }
        let count = totalItems.count
        
        if index == 0 {
            // User swiped to the duplicated last item; jump to the real last item
            isAdjusting = true
            currentIndex = count - 2
            DispatchQueue.main.async {
                isAdjusting = false
            }
        } else if index == count - 1 {
            // User swiped to the duplicated first item; jump to the real first item
            isAdjusting = true
            currentIndex = 1
            DispatchQueue.main.async {
                isAdjusting = false
            }
        }
    }
}
