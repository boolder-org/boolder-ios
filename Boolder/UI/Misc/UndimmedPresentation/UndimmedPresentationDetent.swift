//
//  UndimmedPresentationDetent.swift
//  SwiftUIKit
//
//  Created by Daniel Saidi on 2022-11-01.
//  Copyright © 2022 Daniel Saidi. All rights reserved.
//

// Source:
// https://github.com/danielsaidi/SwiftUIKit/tree/3688eb19d9dc36886d2623161aeb6c5f5363cf0c/Sources/SwiftUIKit/Presentation/Detents

#if os(iOS)
import SwiftUI

/**
 This is used to bridge the SwiftUI `PresentationDetent`with
 the UIKit `UISheetPresentationController.Detent.Identifier`.
 */
@available(iOS 16.0, *)
public enum UndimmedPresentationDetent {

    /// The system detent for a sheet at full height.
    case large

    /// The system detent for a sheet that's approximately half the available screen height.
    case medium

    /// A custom detent with the specified fractional height.
    case fraction(_ value: CGFloat)

    ///  A custom detent with the specified height.
    case height(_ value: CGFloat)

    var swiftUIDetent: PresentationDetent {
        switch self {
        case .large: return .large
        case .medium: return .medium
        case .fraction(let value): return .fraction(value)
        case .height(let value): return .height(value)
        }
    }

    var uiKitIdentifier: UISheetPresentationController.Detent.Identifier {
        switch self {
        case .large: return .large
        case .medium: return .medium
        case .fraction(let value): return .fraction(value)
        case .height(let value): return .height(value)
        }
    }
}

@available(iOS 16.0, *)
extension Collection where Element == UndimmedPresentationDetent {

    var swiftUISet: Set<PresentationDetent> {
        Set(map { $0.swiftUIDetent })
    }
}
#endif
