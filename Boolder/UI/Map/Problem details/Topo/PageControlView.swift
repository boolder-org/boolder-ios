//
//  PageControlView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 16/03/2025.
//  Copyright © 2025 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct PageControlView: View {
    let numberOfPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.primary : Color.secondary.opacity(0.5))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
