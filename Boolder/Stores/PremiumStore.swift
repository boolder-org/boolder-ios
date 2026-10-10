//
//  PremiumStore.swift
//  Boolder
//
//  Created by Ivann Morice on 10/10/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import Foundation

@Observable
class PremiumStore {
    static let shared = PremiumStore()

    enum Status: String {
        case notSubscribed
        case subscribed
        case inGracePeriod
        case inBillingRetry
    }

    private static let statusKey = "premium/status"

    // cached locally so that a subscriber keeps access when offline
    var status: Status {
        didSet {
            UserDefaults.standard.set(status.rawValue, forKey: Self.statusKey)
        }
    }

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
}
