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
    private static let introSeenKey = "premium/introSeen"
    static let forceIntroKey = "premium/forceIntro"

    // TODO(premium): set to the build number of the first Premium release
    private static let premiumFirstBuild = "100"

    var status: Status {
        didSet {
            UserDefaults.standard.set(status.rawValue, forKey: Self.statusKey)
        }
    }

    var product: Product?
    var expirationDate: Date?
    var willAutoRenew = true
    var gracePeriodExpirationDate: Date?

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
    func shouldShowIntro() async -> Bool {
        guard !UserDefaults.standard.bool(forKey: Self.introSeenKey) else { return false }

        // nil when the App Store did not answer in time: the question is asked again at the next launch
        guard let isEligible = await firstResult(within: 3, of: { await self.isEligibleForIntro() }) else {
            return false
        }

        if !isEligible {
            markIntroSeen()
        }
        return isEligible
    }

    func markIntroSeen() {
        UserDefaults.standard.set(true, forKey: Self.introSeenKey)
    }

    func resetIntroSeen() {
        UserDefaults.standard.removeObject(forKey: Self.introSeenKey)
    }

    @MainActor
    private func isEligibleForIntro() async -> Bool? {
        await loadProduct()
        guard await refreshStatus() else { return nil }
        guard status == .notSubscribed else { return false }

        #if DEVELOPMENT
        if UserDefaults.standard.bool(forKey: Self.forceIntroKey) { return true }
        #endif

        guard case .verified(let appTransaction) = try? await AppTransaction.shared else { return nil }
        return appTransaction.originalAppVersion.compare(Self.premiumFirstBuild, options: .numeric) == .orderedAscending
    }

    private func firstResult<T>(within seconds: Double, of operation: @escaping () async -> T?) async -> T? {
        let results = AsyncStream<T?> { continuation in
            Task {
                continuation.yield(await operation())
                continuation.finish()
            }
            Task {
                try? await Task.sleep(for: .seconds(seconds))
                continuation.yield(nil)
                continuation.finish()
            }
        }

        for await result in results {
            return result
        }
        return nil
    }

    @MainActor
    @discardableResult
    func refreshStatus() async -> Bool {
        do {
            guard let subscriptionStatuses = try await product?.subscription?.status else {
                return false
            }

            let verifiedStatus = subscriptionStatuses.first { subscriptionStatus in
                if case .verified = subscriptionStatus.transaction { return true }
                return false
            }

            if case .verified(let transaction) = verifiedStatus?.transaction {
                expirationDate = transaction.expirationDate
            }
            if case .verified(let renewalInfo) = verifiedStatus?.renewalInfo {
                willAutoRenew = renewalInfo.willAutoRenew
                gracePeriodExpirationDate = renewalInfo.gracePeriodExpirationDate
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
            return true
        } catch {
            // keep the cached status: a network error must never lock out a subscriber
            return false
        }
    }
}
