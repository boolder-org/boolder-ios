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
                    .fill(index == currentIndex ? Color.white : Color.black.opacity(0.2))
                    .frame(width: 4, height: 4)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.clear.background(VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))))
        .cornerRadius(6)
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}
