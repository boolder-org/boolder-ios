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

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        PaywallHeaderView(topInset: geo.safeAreaInsets.top, onClose: presentation == .sheet ? { dismiss() } : nil)
                        PaywallBenefitsView()
                        PaywallReasonsView()
                    }
                    .padding(.bottom)
                }
                .scrollBounceBehavior(.basedOnSize)
                .ignoresSafeArea(edges: .top)

                PaywallActionsView(onPurchased: onPurchased)
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
