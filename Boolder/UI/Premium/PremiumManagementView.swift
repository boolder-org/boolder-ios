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

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if PremiumStore.shared.hasBillingIssue {
                        PremiumBillingIssueView(status: PremiumStore.shared.status, gracePeriodExpirationDate: PremiumStore.shared.gracePeriodExpirationDate)
                    }
                    else {
                        statusCard

                        Button {
                            presentManageSubscriptions = true
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "creditcard")
                                    .foregroundColor(.appGreen)

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
                    await PremiumStore.shared.refreshStatus()
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
                    .background(Color.white.opacity(0.25))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 2) {
                if let expirationDate = PremiumStore.shared.expirationDate {
                    Text(String(format: NSLocalizedString(PremiumStore.shared.willAutoRenew ? "premium.management.renews_on" : "premium.management.ends_on", comment: ""), expirationDate.formatted(date: .long, time: .omitted)))
                }

                if let price = PremiumStore.shared.product?.displayPrice {
                    Text(String(format: NSLocalizedString("premium.management.price_per_year", comment: ""), price))
                }
            }
            .font(.callout)
            .opacity(0.9)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.appGreen)
        .cornerRadius(20)
    }
}

#Preview {
    PremiumManagementView()
}
