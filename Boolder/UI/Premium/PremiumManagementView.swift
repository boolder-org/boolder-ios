//
//  PremiumManagementView.swift
//  Boolder
//
//  Created by Ivann Morice on 10/10/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct PremiumManagementView: View {
    @State private var presentManageSubscriptions = false

    private var premiumStore: PremiumStore {
        PremiumStore.shared
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if premiumStore.hasBillingIssue {
                        PremiumBillingIssueView(status: premiumStore.status, gracePeriodExpirationDate: premiumStore.gracePeriodExpirationDate)
                    }
                    else {
                        statusCard

                        Button {
                            presentManageSubscriptions = true
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "creditcard")
                                    .foregroundColor(.paywallHeaderMiddle)

                                Text("premium.management.manage")
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: "arrow.up.right")
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                            .font(.body.weight(.medium))
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(16)
                        }
                    }

                    VStack(spacing: 4) {
                        Text("premium.management.legal")

                        HStack(spacing: 6) {
                            PremiumLegalLinksView(termsTitle: "premium.management.terms")
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                }
                .padding(.horizontal)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("tabs.premium")
        }
        .phoneOnlyStackNavigationView()
        .manageSubscriptionsSheet(isPresented: $presentManageSubscriptions)
        .onChange(of: presentManageSubscriptions) { _, isPresented in
            if !isPresented {
                Task {
                    await premiumStore.refreshStatus()
                }
            }
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("premium.paywall.title")
                    .font(.title3.weight(.bold))

                Spacer()

                Text("premium.management.active")
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.paywallHeaderContent.opacity(0.25))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 2) {
                if let expirationDate = premiumStore.expirationDate {
                    Text(String(format: NSLocalizedString(premiumStore.willAutoRenew ? "premium.management.renews_on" : "premium.management.ends_on", comment: ""), expirationDate.formatted(date: .long, time: .omitted)))
                }

                if let price = premiumStore.product?.displayPrice {
                    Text(String(format: NSLocalizedString("premium.management.price_per_year", comment: ""), price))
                }
            }
            .font(.callout)
            .opacity(0.9)
        }
        .foregroundColor(.paywallHeaderContent)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [.premiumSuccessBackgroundStart, .paywallHeaderEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
}

#Preview {
    PremiumManagementView()
}
