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

    enum PurchaseOutcome {
        case purchased
        case cancelled
        case pending
        case failed
    }

    enum RestoreOutcome {
        case restored
        case nothingToRestore
        case cancelled
        case failed
    }

    private static let productId = "boolder_premium_yearly"
    private static let statusKey = "premium/status"

    var status: Status {
        didSet {
            UserDefaults.standard.set(status.rawValue, forKey: Self.statusKey)
        }
    }

    var product: Product?

    let freeAreaIds = Set(Area.popularAreas.map { $0.id })

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

    func isLocked(areaId: Int) -> Bool {
        !freeAreaIds.contains(areaId) && !hasAccess
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
    func purchase() async -> PurchaseOutcome {
        guard let product else { return .failed }

        do {
            switch try await product.purchase() {
            case .success(.verified(let transaction)):
                await transaction.finish()
                await refreshStatus()
                return .purchased
            case .success(.unverified):
                return .failed
            case .userCancelled:
                return .cancelled
            case .pending:
                return .pending
            @unknown default:
                return .failed
            }
        } catch {
            return .failed
        }
    }

    @MainActor
    func restore() async -> RestoreOutcome {
        do {
            try await AppStore.sync()
            await refreshStatus()
            return hasAccess ? .restored : .nothingToRestore
        } catch StoreKitError.userCancelled {
            return .cancelled
        } catch {
            return .failed
        }
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
