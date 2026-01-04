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
    @Binding var presentDownloads: Bool
    var clusterDownloader: ClusterDownloader
    
    var body: some View {
        Button {
            presentDownloads = true
        } label: {
            Group {
                if clusterDownloader.downloadingOrQueued {
                    CircularProgressView(progress: clusterDownloader.progress)
                }
                else if clusterDownloader.allDownloaded {
                    Image(systemName: "checkmark.icloud")
                }
                else {
                    Image(systemName: "icloud.and.arrow.down")
                }
            }
            .frame(width: 44, height: 44)
        }
//        .buttonStyle(FabButton())
        .sheet(isPresented: $presentDownloads) {
            ClusterViewWithActionsheet(clusterDownloader: clusterDownloader)
                .presentationDetents([.medium, .large])
        }
    }
}

//#Preview {
//    DownloadsButtonView()
//}
