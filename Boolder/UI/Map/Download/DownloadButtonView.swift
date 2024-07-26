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
    @ObservedObject var clusterDownloader: ClusterDownloader
    
    var body: some View {
        Button {
            presentDownloads = true
        } label: {
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
        .buttonStyle(FabButton())
        .sheet(isPresented: $presentDownloads) {
            ClusterView(clusterDownloader: clusterDownloader)
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
}

//#Preview {
//    DownloadsButtonView()
//}
