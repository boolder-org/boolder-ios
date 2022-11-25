//
//  UISheetPresentationController.Detent.Identifier+Init.swift
//  SwiftUIKit
//
//  Created by Daniel Saidi on 2022-11-01.
//  Copyright © 2022 Daniel Saidi. All rights reserved.
//

// Source:
// https://github.com/danielsaidi/SwiftUIKit/tree/3688eb19d9dc36886d2623161aeb6c5f5363cf0c/Sources/SwiftUIKit/Presentation/Detents

#if os(iOS)
import UIKit

@available(iOS 16.0, *)
public extension UISheetPresentationController.Detent.Identifier {

    /// A fraction-specific detent identifier.
    static func fraction(_ value: CGFloat) -> Self {
        .init("Fraction:\(String(format: "%.1f", value))")
    }

    /// A height-specific detent identifier.
    static func height(_ value: CGFloat) -> Self {
        .init("Height:\(value)")
    }
}
#endif
