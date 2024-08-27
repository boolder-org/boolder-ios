//
//  PageIndicator.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/08/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct PageIndicator: View {
    var numberOfDots: Int = 5
    var currentIndex: Int = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<numberOfDots, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.white : Color.gray)
                    .frame(width: 4, height: 4)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.8))
        .cornerRadius(6)
    }
}
