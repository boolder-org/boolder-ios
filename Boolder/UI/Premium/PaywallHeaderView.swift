//
//  PaywallHeaderView.swift
//  Boolder
//
//  Created by Ivann Morice on 10/10/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct PaywallHeaderView: View {
    var topInset: CGFloat = 0
    var onClose: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 6) {
            Text("premium.paywall.title")
                .font(.title.weight(.bold))

            Text("premium.paywall.subtitle")
                .font(.callout.weight(.medium))
                .opacity(0.88)
        }
        .foregroundColor(.paywallHeaderContent)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 56)
        .padding(.top, topInset + 12)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                LinearGradient(
                    stops: [
                        .init(color: .paywallHeaderStart, location: 0),
                        .init(color: .paywallHeaderMiddle, location: 0.62),
                        .init(color: .paywallHeaderEnd, location: 1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                GeometryReader { geo in
                    Ellipse()
                        .frame(width: 172, height: 114)
                        .position(x: 54, y: geo.size.height - 30)

                    Ellipse()
                        .frame(width: 137, height: 92)
                        .position(x: geo.size.width - 44, y: geo.size.height - 31)
                }
                .foregroundColor(Color.paywallHeaderContent.opacity(0.13))
            }
        )
        .clipped()
        .overlay(alignment: .topTrailing) {
            if let onClose {
                Button {
                    onClose()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.paywallHeaderContent)
                        .frame(width: 36, height: 36)
                        .background(Color.paywallHeaderContent.opacity(0.28))
                        .clipShape(Circle())
                }
                .padding(.horizontal, 16)
                .padding(.top, topInset)
            }
        }
    }
}

#Preview("With close button") {
    PaywallHeaderView(topInset: 62, onClose: {})
}

#Preview("Without close button") {
    PaywallHeaderView()
}
