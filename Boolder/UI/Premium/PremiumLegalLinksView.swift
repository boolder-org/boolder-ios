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

    @State private var presentTerms = false
    @State private var presentPrivacy = false

    var body: some View {
        Button {
            presentTerms = true
        } label: {
            Text(termsTitle).underline()
        }
        .fullScreenCover(isPresented: $presentTerms) {
            // TODO(premium): replace Apple's standard EULA with Boolder's own terms
            SafariWebView(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                .ignoresSafeArea()
        }

        Text(verbatim: "·")

        Button {
            presentPrivacy = true
        } label: {
            Text("premium.paywall.privacy").underline()
        }
        .fullScreenCover(isPresented: $presentPrivacy) {
            SafariWebView(url: URL(string: "https://www.boolder.com/\(NSLocale.websiteLocale)/privacy")!)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    HStack {
        PremiumLegalLinksView(termsTitle: "premium.paywall.terms")
    }
}
