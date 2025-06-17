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
    func lighter(_ componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: componentDelta)
    }
    
    func darker(_ componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: -1*componentDelta)
    }
    
    private func makeColor(componentDelta: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Extract r,g,b,a components from the
        // current UIColor
        getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )
        
        // Create a new UIColor modifying each component
        // by componentDelta, making the new UIColor either
        // lighter or darker.
        return UIColor(
            red: add(componentDelta, toComponent: red),
            green: add(componentDelta, toComponent: green),
            blue: add(componentDelta, toComponent: blue),
            alpha: alpha
        )
    }
    
    // Add value to component ensuring the result is
    // between 0 and 1
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        return max(0, min(1, toComponent + value))
    }
}

extension Color {
    static let systemBackground = Color(UIColor.systemBackground)
    static let levelGreen = Color(UIColor(red: 5/255, green: 150/255, blue: 105/255, alpha: 0.8))
}

// Locale to use when redirectign to URLs hosted on boolder.com
extension NSLocale {
    static var websiteLocale: String {
        if let lang = NSLocale.current.language.languageCode?.identifier {
            if (lang == "en") {
                return "en"
            }
        }
        
        return "fr"
    }
}

// Hack to use if #available within a view modifier
// https://blog.overdesigned.net/posts/2020-09-23-swiftui-availability/
extension View {
    func modify<T: View>(@ViewBuilder _ modifier: (Self) -> T) -> some View {
        return modifier(self)
    }
}

// FIXME: is there a cleaner way?
// https://stackoverflow.com/a/58988238/230309
extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// https://useyourloaf.com/blog/how-to-percent-encode-a-url-string/
extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
}

extension String {
    var normalized: String {
        self.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "[^0-9a-zA-Z]", with: "", options: .regularExpression)
            .lowercased()
    }
}

extension Array {
    /// Safe “circular” indexing: wraps any Int into 0..<count
    subscript(circular index: Int) -> Element? {
        guard !isEmpty else { return nil }
        let idx = ((index % count) + count) % count
        return self[idx]
    }
}
