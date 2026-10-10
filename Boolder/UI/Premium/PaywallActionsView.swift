//
//  PaywallActionsView.swift
//  Boolder
//
//  Created by Ivann Morice on 10/10/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct PaywallActionsView: View {
    @State private var presentTerms = false
    @State private var presentPrivacy = false

    private var price: String? {
        PremiumStore.shared.product?.displayPrice
    }

    var body: some View {
        VStack(spacing: 12) {
            Button {
                // TODO(premium): commit 12
            } label: {
                Text(subscribeTitle)
                    .font(.title3.weight(.semibold))
                    .padding(.vertical)
            }
            .buttonStyle(LargeButton())
            .disabled(price == nil)
            .opacity(price == nil ? 0.5 : 1)

            VStack(spacing: 4) {
                Text("premium.paywall.legal")

                ViewThatFits {
                    HStack(spacing: 6) {
                        links
                    }

                    VStack(spacing: 4) {
                        links
                    }
                }
            }
            .font(.caption)
            .foregroundColor(Color(.secondaryLabel))
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .fullScreenCover(isPresented: $presentTerms) {
            // TODO(premium): replace Apple's standard EULA with Boolder's own terms
            SafariWebView(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $presentPrivacy) {
            SafariWebView(url: URL(string: "https://www.boolder.com/\(NSLocale.websiteLocale)/privacy")!)
                .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var links: some View {
        Button {
            presentTerms = true
        } label: {
            Text("premium.paywall.terms").underline()
        }

        Text(verbatim: "·")

        Button {
            presentPrivacy = true
        } label: {
            Text("premium.paywall.privacy").underline()
        }

        Text(verbatim: "·")

        Button {
            // TODO(premium): commit 14
        } label: {
            Text("premium.paywall.restore").underline()
        }
    }

    private var subscribeTitle: String {
        if let price {
            return String(format: NSLocalizedString("premium.paywall.subscribe_with_price", comment: ""), price)
        }
        return NSLocalizedString("premium.paywall.subscribe", comment: "")
    }
}

#Preview {
    PaywallActionsView()
}
