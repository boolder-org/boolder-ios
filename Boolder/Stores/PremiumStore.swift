//
//  PremiumStore.swift
//  Boolder
//
//  Created by Ivann Morice on 10/10/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import Foundation
import StoreKit

@Observable
class PremiumStore {
    static let shared = PremiumStore()

    enum Status: String {
        case notSubscribed
        case subscribed
        case inGracePeriod
        case inBillingRetry
    }

    private static let productId = "boolder_premium_yearly"
    private static let statusKey = "premium/status"

    var status: Status {
        didSet {
            UserDefaults.standard.set(status.rawValue, forKey: Self.statusKey)
        }
    }

    var product: Product?

    private init() {
        let cachedStatus = UserDefaults.standard.string(forKey: Self.statusKey) ?? ""
        status = Status(rawValue: cachedStatus) ?? .notSubscribed
    }

    var hasAccess: Bool {
        status == .subscribed || status == .inGracePeriod
    }

    var hasBillingIssue: Bool {
        status == .inGracePeriod || status == .inBillingRetry
    }

    func start() {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
                await self.refreshStatus()
            }
        }

        Task {
            await loadProduct()
            await refreshStatus()
        }
    }

    @MainActor
    func loadProduct() async {
        guard product == nil else { return }

        product = try? await Product.products(for: [Self.productId]).first
    }

    @MainActor
    func refreshStatus() async {
        do {
            guard let subscriptionStatuses = try await product?.subscription?.status else {
                return
            }

            let verifiedStatus = subscriptionStatuses.first { subscriptionStatus in
                if case .verified = subscriptionStatus.transaction { return true }
                return false
            }

            switch verifiedStatus?.state {
            case .subscribed:
                status = .subscribed
            case .inGracePeriod:
                status = .inGracePeriod
            case .inBillingRetryPeriod:
                status = .inBillingRetry
            default:
                status = .notSubscribed
            }
        } catch {
            // keep the cached status: a network error must never lock out a subscriber
        }
    }
}
