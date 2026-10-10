//
//  LockedPhotoOverlay.swift
//  Boolder
//
//  Created by Ivann Morice on 10/10/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct LockedPhotoOverlay: View {
    let price: String?

    @State private var presentPaywall = false

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "lock")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.lockedPhotoOnContent)
                .frame(width: 46, height: 46)
                .background(Color.lockedPhotoContent.opacity(0.95))
                .clipShape(Circle())

            Text("premium.locked_photo.title")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.lockedPhotoContent)
                .multilineTextAlignment(.center)
                .modifier(DropShadow())

            Button {
                presentPaywall = true
            } label: {
                Text(buttonTitle)
                    .font(.footnote.weight(.bold))
                    .foregroundColor(.lockedPhotoOnContent)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(Color.lockedPhotoContent)
                    .clipShape(Capsule())
                    .shadow(color: .lockedPhotoOnContent.opacity(0.2), radius: 8, y: 2)
            }
        }
        .padding(.horizontal, 26)
        .fullScreenCover(isPresented: $presentPaywall) {
            PaywallView(presentation: .sheet)
        }
    }

    private var buttonTitle: String {
        if let price {
            return String(format: NSLocalizedString("premium.locked_photo.cta_with_price", comment: ""), price)
        }
        return NSLocalizedString("premium.locked_photo.cta", comment: "")
    }
}

#Preview("With price") {
    ZStack {
        Color.lockedPhotoVeil
        LockedPhotoOverlay(price: "10,00 €")
    }
    .aspectRatio(4/3, contentMode: .fit)
}

#Preview("Without price") {
    ZStack {
        Color.lockedPhotoVeil
        LockedPhotoOverlay(price: nil)
    }
    .aspectRatio(4/3, contentMode: .fit)
}
