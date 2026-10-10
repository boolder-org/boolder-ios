//
//  PremiumBillingIssueView.swift
//  Boolder
//
//  Created by Ivann Morice on 10/10/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct PremiumBillingIssueView: View {
    let status: PremiumStore.Status
    let gracePeriodExpirationDate: Date?

    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(.premiumBillingIssueAccent)

                Text("premium.billing_issue.title")
            }
            .font(.title3.weight(.bold))

            Text(LocalizedStringKey(message))
                .font(.callout)

            Button {
                openURL(URL(string: "https://apps.apple.com/account/billing")!)
            } label: {
                Text("premium.billing_issue.update_payment")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.paywallHeaderContent)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color.premiumBillingIssueAccent)
                    .clipShape(Capsule())
            }
            .padding(.top, 6)
        }
        .foregroundColor(.premiumBillingIssueText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.premiumBillingIssueBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.premiumBillingIssueBorder, lineWidth: 1)
        )
    }

    private var message: String {
        if status == .inBillingRetry {
            return NSLocalizedString("premium.billing_issue.suspended", comment: "")
        }
        if let gracePeriodExpirationDate {
            return String(format: NSLocalizedString("premium.billing_issue.grace_period_until", comment: ""), gracePeriodExpirationDate.formatted(date: .long, time: .omitted))
        }
        return NSLocalizedString("premium.billing_issue.grace_period", comment: "")
    }
}

#Preview("Grace period") {
    PremiumBillingIssueView(status: .inGracePeriod, gracePeriodExpirationDate: Date())
        .padding()
}

#Preview("Billing retry") {
    PremiumBillingIssueView(status: .inBillingRetry, gracePeriodExpirationDate: nil)
        .padding()
}
