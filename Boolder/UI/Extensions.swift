//
//  Extensions.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 11/01/2021.
//  Copyright © 2021 Nicolas Mondollot. All rights reserved.
//

import UIKit
import SwiftUI

extension UIColor {
    static let appGreen = UIColor(named: "AppGreen")!
}

extension Color {
    static let appGreen = Color(UIColor.appGreen)
    static let systemBackground = Color(UIColor.systemBackground)
}

// Locale to use when redirectign to URLs hosted on boolder.com
extension NSLocale {
    static var websiteLocale: String {
        if let lang = NSLocale.current.languageCode {
            if (lang == "en") {
                return "en"
            }
        }
        
        return "fr"
    }
}
