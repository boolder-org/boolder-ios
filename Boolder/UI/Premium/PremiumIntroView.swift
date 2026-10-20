//
//  PremiumIntroView.swift
//  Boolder
//
//  Created by Ivann Morice on 10/10/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct PremiumIntroView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    header
                    PaywallBenefitsView()
                    PaywallReasonsView()

                    // with very large text, pinned actions would leave no room for the content
                    if dynamicTypeSize.isAccessibilitySize {
                        PaywallActionsView(onLater: { dismiss() }, showsRestore: false)
                    }
                }
                .padding(.bottom)
            }
            .scrollBounceBehavior(.basedOnSize)

            if !dynamicTypeSize.isAccessibilitySize {
                PaywallActionsView(onLater: { dismiss() }, showsRestore: false)
            }
        }
        .background(Color.systemBackground)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("premium.intro.badge")
                    .font(.footnote.weight(.bold))
                    .tracking(1)
                    .textCase(.uppercase)
                    .foregroundColor(.paywallIcon)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Color.paywallIconBackground)
                    .clipShape(Capsule())

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(.secondaryLabel))
                        .frame(width: 32, height: 32)
                        .background(Color(.secondarySystemFill))
                        .clipShape(Circle())
                }
            }

            Text("premium.paywall.title")
                .font(.largeTitle.weight(.bold))
                .padding(.top, 6)

            Text("premium.paywall.subtitle")
                .font(.body)
                .foregroundColor(Color(.secondaryLabel))

            Text("premium.intro.body")
                .font(.body)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 26)
        .padding(.top, 24)
    }
}

#Preview {
    PremiumIntroView()
}
