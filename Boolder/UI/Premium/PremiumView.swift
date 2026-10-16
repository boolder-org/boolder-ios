//
//  PremiumView.swift
//  Boolder
//
//  Created by Ivann Morice on 10/10/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct PremiumView: View {
    @State private var presentSuccess = false

    var body: some View {
        Group {
            if PremiumStore.shared.hasAccess || PremiumStore.shared.hasBillingIssue {
                PremiumManagementView()
            }
            else {
                PaywallView(presentation: .tab, onPurchased: { presentSuccess = true })
            }
        }
        .task {
            await PremiumStore.shared.refreshStatus()
        }
        .fullScreenCover(isPresented: $presentSuccess) {
            PremiumSuccessView()
        }
    }
}

#Preview {
    PremiumView()
}
