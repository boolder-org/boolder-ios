//
//  PaywallBenefitsView.swift
//  Boolder
//
//  Created by Ivann Morice on 10/10/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct PaywallBenefitsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("premium.paywall.benefits.title")
                .font(.footnote.weight(.bold))
                .tracking(1.2)
                .textCase(.uppercase)
                .foregroundColor(Color(.secondaryLabel))

            row(icon: "map", title: "premium.paywall.benefits.areas.title", subtitle: "premium.paywall.benefits.areas.subtitle")
            row(icon: "chart.bar", title: "premium.paywall.benefits.problems.title", subtitle: "premium.paywall.benefits.problems.subtitle")
            row(icon: "camera", title: "premium.paywall.benefits.photos.title", subtitle: "premium.paywall.benefits.photos.subtitle")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 26)
        .padding(.top, 20)
    }

    private func row(icon: String, title: LocalizedStringKey, subtitle: LocalizedStringKey) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.appGreen)
                .frame(width: 50, height: 50)
                .background(Color.appGreen.opacity(0.15))
                .cornerRadius(14)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title3.weight(.bold))

                Text(subtitle)
                    .font(.body)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
    }
}

#Preview {
    PaywallBenefitsView()
}
