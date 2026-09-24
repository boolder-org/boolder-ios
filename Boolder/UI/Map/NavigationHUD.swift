//
//  NavigationHUD.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 07/05/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreLocation

struct NavigationHUD: View {
    @Environment(MapState.self) private var mapState: MapState

    var body: some View {
        VStack {
            if let user = mapState.userCoordinate,
               let target = mapState.selectedProblem?.coordinate {
                let bearing = Self.bearingDegrees(from: user, to: target)
                let distance = CLLocation(latitude: user.latitude, longitude: user.longitude)
                    .distance(from: CLLocation(latitude: target.latitude, longitude: target.longitude))

                HStack(spacing: 8) {
                    Image(systemName: "arrow.up")
                        .rotationEffect(.degrees(bearing))
                        .font(.subheadline.weight(.semibold))
                    Text("\(Self.formattedDistance(distance)) · \(Self.cardinal8(forDegrees: bearing))")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
                .shadow(color: Color.black.opacity(0.15), radius: 4, y: 2)
                .padding(.top, 64)
            }
            Spacer()
        }
        .allowsHitTesting(false)
    }

    private static func formattedDistance(_ meters: CLLocationDistance) -> String {
        let measurement = Measurement(value: meters, unit: UnitLength.meters)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.unitStyle = .medium
        formatter.numberFormatter.maximumFractionDigits = meters < 1000 ? 0 : 1
        return formatter.string(from: measurement)
    }

    /// Forward azimuth (great-circle) from a → b, in degrees [0, 360).
    private static func bearingDegrees(
        from a: CLLocationCoordinate2D,
        to b: CLLocationCoordinate2D
    ) -> Double {
        let lat1 = a.latitude * .pi / 180
        let lat2 = b.latitude * .pi / 180
        let dLon = (b.longitude - a.longitude) * .pi / 180
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        var deg = atan2(y, x) * 180 / .pi
        if deg < 0 { deg += 360 }
        return deg
    }

    private static func cardinal8(forDegrees deg: Double) -> String {
        let keys = [
            "map.cardinal.n", "map.cardinal.ne", "map.cardinal.e", "map.cardinal.se",
            "map.cardinal.s", "map.cardinal.sw", "map.cardinal.w", "map.cardinal.nw"
        ]
        let idx = Int((deg + 22.5) / 45) % 8
        return NSLocalizedString(keys[idx], comment: "Cardinal direction abbreviation")
    }
}
