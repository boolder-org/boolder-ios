//
//  PaywallView.swift
//  Boolder
//
//  Created by Ivann Morice on 10/10/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct PaywallView: View {
    let presentation: Presentation
    var onPurchased: (() -> Void)? = nil

    enum Presentation {
        case sheet
        case tab
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        PaywallHeaderView(topInset: geo.safeAreaInsets.top, onClose: presentation == .sheet ? { dismiss() } : nil)
                        PaywallBenefitsView()
                        PaywallReasonsView()

                        // with very large text, pinned actions would leave no room for the content
                        if dynamicTypeSize.isAccessibilitySize {
                            PaywallActionsView(onPurchased: onPurchased)
                        }
                    }
                    .padding(.bottom)
                }
                .scrollBounceBehavior(.basedOnSize)
                .ignoresSafeArea(edges: .top)

                if !dynamicTypeSize.isAccessibilitySize {
                    PaywallActionsView(onPurchased: onPurchased)
                }
            }
        }
        .background(Color.systemBackground)
    }
}

#Preview("Sheet") {
    PaywallView(presentation: .sheet)
}

#Preview("Tab") {
    PaywallView(presentation: .tab)
}
