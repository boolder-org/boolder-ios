//
//  DownloadButtonView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreLocation

struct DownloadButtonView: View {
    let cluster: Cluster
    let mapState: MapState
    let selectedArea: Area?
    let zoom: CGFloat?
    let center: CLLocationCoordinate2D?
    @Binding var presentDownloads: Bool
    @ObservedObject var clusterDownloader: ClusterDownloader
    
    var body: some View {
        Button(action: {
            presentDownloads = true
        }) {
            if clusterDownloader.downloading {
                ProgressView()
            }
            else if clusterDownloader.allDownloaded {
                Image(systemName: "checkmark.icloud")
            }
            else {
                Image(systemName: "icloud.and.arrow.down")
                    
            }
            
        }
        .buttonStyle(FabButton())
        
        .sheet(isPresented: $presentDownloads) {
            ClusterView(cluster: cluster, area: areaBestGuess(in: cluster))
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
