/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A convenience extension to fetch the current bundle version of the app.
*/

import Foundation

extension Bundle {
    /// Fetches the current bundle version of the app.
    static var currentAppVersion: String? {
        #if os(macOS)
        let infoDictionaryKey = "CFBundleShortVersionString"
        #else
        let infoDictionaryKey = "CFBundleVersion"
        #endif
        
        return Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
    }
}
