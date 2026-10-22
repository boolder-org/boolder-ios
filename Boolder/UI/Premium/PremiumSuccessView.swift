//
//  PremiumSuccessView.swift
//  Boolder
//
//  Created by Ivann Morice on 10/10/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct PremiumSuccessView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "checkmark")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.appGreen)
                    .frame(width: 104, height: 104)
                    .background(Color.white.opacity(0.96))
                    .clipShape(Circle())

                Text("premium.success.title")
                    .font(.title.weight(.bold))

                Text("premium.success.subtitle")
                    .font(.title3)
                    .opacity(0.93)

                HStack(spacing: 16) {
                    // TODO(premium): replace the logo with the original file
                    Image("PaywallLogoBleauInfo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                        .cornerRadius(11)

                    Text("premium.success.thanks")
                        .font(.callout)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(18)
                .background(Color.white.opacity(0.16))
                .cornerRadius(20)
            }
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)

            Spacer()
            Spacer()

            Button {
                dismiss()
            } label: {
                Text("premium.success.continue")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.appGreen)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .background(
            ZStack {
                Color.appGreen

                ConfettiView()
            }
            .ignoresSafeArea()
        )
    }
}

#Preview {
    PremiumSuccessView()
}
