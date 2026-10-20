//
//  PremiumLegalLinksView.swift
//  Boolder
//
//  Created by Ivann Morice on 10/10/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct PremiumLegalLinksView: View {
    let termsTitle: LocalizedStringKey

    @Environment(\.openURL) var openURL

    var body: some View {
        Button {
            openURL(URL(string: "https://www.boolder.com/\(NSLocale.websiteLocale)/terms")!)
        } label: {
            Text(termsTitle).underline()
        }

        Text(verbatim: "·")

        Button {
            openURL(URL(string: "https://www.boolder.com/\(NSLocale.websiteLocale)/privacy")!)
        } label: {
            Text("premium.paywall.privacy").underline()
        }
    }
}

#Preview {
    HStack {
        PremiumLegalLinksView(termsTitle: "premium.paywall.terms")
    }
}
