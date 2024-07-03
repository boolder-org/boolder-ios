//
//  DownloadsButtonView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreLocation

struct DownloadsButtonView: View {
    let cluster: Cluster
    let mapState: MapState
    let selectedArea: Area?
    let zoom: CGFloat?
    let center: CLLocationCoordinate2D?
    @Binding var presentDownloads: Bool
    
    var body: some View {
        Button(action: {
            presentDownloads = true
        }) {
            
            Image(systemName: "arrow.down.circle")
                .padding(12)
            //                        .offset(x: -1, y: 0)
        }
        .accentColor(.primary)
        .background(Color.systemBackground)
        .clipShape(Circle())
        .overlay(
            Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
        )
        .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
        .padding(.horizontal)
        
        .sheet(isPresented: $presentDownloads) {
            DownloadsView(cluster: cluster, area: areaBestGuess(in: cluster))
                .modify {
                    if #available(iOS 16, *) {
                        $0.presentationDetents([.medium, .large])
                    }
                    else {
                        $0
                    }
                }
        }
    }
    
    private func areaBestGuess(in cluster: Cluster) -> Area {
        if let selectedArea = selectedArea {
            return selectedArea
        }
        
        if let zoom = zoom, let center = center {
            if zoom > 12.5 {
                if let area = closestArea(in: cluster, from: CLLocation(latitude: center.latitude, longitude: center.longitude)) {
                    return area
                }
            }
//            print(zoom)
//            print(center)
        }
        
        return cluster.mainArea
    }
    
    private func closestArea(in cluster: Cluster, from center: CLLocation) -> Area? {
        cluster.areas.sorted {
            $0.center.distance(from: center) < $1.center.distance(from: center)
        }.first
    }
}

//#Preview {
//    DownloadsButtonView()
//}
