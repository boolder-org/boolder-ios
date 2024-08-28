//
//  VariantIndicator.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/08/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct VariantIndicator: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .foregroundColor(.white)
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(Color.clear.background(VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))))
        .cornerRadius(4)
    }
}

