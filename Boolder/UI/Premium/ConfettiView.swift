//
//  ConfettiView.swift
//  Boolder
//
//  Created by Ivann Morice on 10/10/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ConfettiView: View {
    private let colors: [Color] = [.premiumSuccessConfettiYellow, .premiumSuccessConfettiPink, .paywallHeaderContent]
    private let count = 18

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<count, id: \.self) { index in
                ConfettiPieceView(color: colors[index % colors.count], containerSize: geo.size)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiPieceView: View {
    let color: Color
    let containerSize: CGSize

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasFallen = false

    // random values live in @State so that each piece keeps them across view updates
    @State private var column = CGFloat.random(in: 0...1)
    @State private var fallDuration = Double.random(in: 4...8)
    @State private var startDelay = Double.random(in: 0...4)
    @State private var drift = CGFloat.random(in: -70...70)
    @State private var startAngle = Double.random(in: 0...360)
    @State private var spin = Double.random(in: 360...1080) * (Bool.random() ? 1 : -1)

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(color)
            .frame(width: 9, height: 14)
            .rotationEffect(.degrees(startAngle + (hasFallen ? spin : 0)))
            .position(
                x: containerSize.width * column + (hasFallen ? drift : 0),
                y: hasFallen ? containerSize.height + 20 : -20
            )
            .onAppear {
                guard !reduceMotion else { return }

                // the fall starts and ends off screen, so the jump back to the top
                // on each repeat is never visible
                withAnimation(.linear(duration: fallDuration).repeatForever(autoreverses: false).delay(startDelay)) {
                    hasFallen = true
                }
            }
    }
}

#Preview {
    ConfettiView()
        .background(Color.paywallHeaderEnd)
}
