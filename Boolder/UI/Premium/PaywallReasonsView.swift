//
//  PaywallReasonsView.swift
//  Boolder
//
//  Created by Ivann Morice on 10/10/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct PaywallReasonsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("premium.paywall.reasons.title")
                .font(.footnote.weight(.bold))
                .tracking(1.2)
                .textCase(.uppercase)
                .foregroundColor(Color(.secondaryLabel))
                .padding(.horizontal, 2)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    // TODO(premium): replace the bleau.info logo with the original file
                    logo("PaywallLogoBoolder")

                    Text(verbatim: "×")
                        .font(.callout)
                        .foregroundColor(Color.paywallCardText.opacity(0.5))

                    logo("PaywallLogoBleauInfo")

                    Text("premium.paywall.reasons.card.title")
                        .font(.headline)
                        .foregroundColor(.paywallCardTitle)
                        .padding(.leading, 4)
                }

                Text("premium.paywall.reasons.card.body")
                    .font(.callout)
                    .foregroundColor(.paywallCardText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.paywallCardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.paywallCardBorder, lineWidth: 1)
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    private func logo(_ name: String) -> some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 36, height: 36)
            .cornerRadius(10)
    }
}

#Preview {
    PaywallReasonsView()
}
