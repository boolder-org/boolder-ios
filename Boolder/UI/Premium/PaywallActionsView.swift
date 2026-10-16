//
//  PaywallActionsView.swift
//  Boolder
//
//  Created by Ivann Morice on 10/10/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct PaywallActionsView: View {
    var onPurchased: (() -> Void)? = nil
    var onLater: (() -> Void)? = nil

    @State private var isPurchasing = false
    @State private var presentPurchasePendingAlert = false
    @State private var presentPurchaseErrorAlert = false
    @State private var presentSuccess = false
    @State private var isRestoring = false
    @State private var presentRestoredAlert = false
    @State private var presentNothingToRestoreAlert = false
    @State private var presentRestoreErrorAlert = false

    @Environment(\.dismiss) private var dismiss

    private var price: String? {
        PremiumStore.shared.product?.displayPrice
    }

    var body: some View {
        VStack(spacing: 12) {
            Button {
                purchase()
            } label: {
                Text(subscribeTitle)
                    .font(.title3.weight(.semibold))
                    .opacity(isPurchasing ? 0 : 1)
                    .overlay {
                        if isPurchasing {
                            ProgressView()
                                .tint(Color.systemBackground)
                        }
                    }
                    .padding(.vertical)
            }
            .buttonStyle(LargeButton())
            .disabled(price == nil || isPurchasing || isRestoring)
            .opacity(price == nil ? 0.5 : 1)

            if let onLater {
                Button {
                    onLater()
                } label: {
                    Text("premium.intro.later")
                        .font(.body.weight(.semibold))
                        .foregroundColor(Color(.secondaryLabel))
                }
            }

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
        .alert("premium.purchase.pending", isPresented: $presentPurchasePendingAlert) {
            Button("OK") { onLater?() }
        }
        .alert("premium.purchase.error", isPresented: $presentPurchaseErrorAlert) {
            Button("OK") { }
        }
        .alert("premium.restore.restored", isPresented: $presentRestoredAlert) {
            Button("OK") { dismiss() }
        }
        .alert("premium.restore.nothing_to_restore", isPresented: $presentNothingToRestoreAlert) {
            Button("OK") { }
        }
        .alert("premium.restore.error", isPresented: $presentRestoreErrorAlert) {
            Button("OK") { }
        }
        .fullScreenCover(isPresented: $presentSuccess, onDismiss: { dismiss() }) {
            PremiumSuccessView()
        }
    }

    @ViewBuilder
    private var links: some View {
        PremiumLegalLinksView(termsTitle: "premium.paywall.terms")

        Text(verbatim: "·")

        Button {
            restore()
        } label: {
            Text("premium.paywall.restore").underline()
        }
        .disabled(isPurchasing || isRestoring)
    }

    private func purchase() {
        isPurchasing = true

        Task {
            let outcome = await PremiumStore.shared.purchase()
            isPurchasing = false

            switch outcome {
            case .purchased:
                if let onPurchased {
                    onPurchased()
                }
                else {
                    presentSuccess = true
                }
            case .cancelled:
                break
            case .pending:
                presentPurchasePendingAlert = true
            case .failed:
                presentPurchaseErrorAlert = true
            }
        }
    }

    private func restore() {
        isRestoring = true

        Task {
            let outcome = await PremiumStore.shared.restore()
            isRestoring = false

            switch outcome {
            case .restored:
                presentRestoredAlert = true
            case .nothingToRestore:
                presentNothingToRestoreAlert = true
            case .cancelled:
                break
            case .failed:
                presentRestoreErrorAlert = true
            }
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
