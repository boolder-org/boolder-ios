//
//  ClusterDownloadRowView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ClusterDownloadRowView: View {
    @ObservedObject var clusterDownloader: ClusterDownloader
    let cluster: Cluster
    @Binding var presentRemoveClusterDownloadSheet: Bool
    @Binding var presentCancelClusterDownloadSheet: Bool
    @Binding var handpickedDownload: Bool
    
    var body: some View {
        if clusterDownloader.downloadingOrQueued && !handpickedDownload {
            Button {
                presentCancelClusterDownloadSheet = true
            } label: {
                Text("Téléchargement \(Int(Double(clusterDownloader.progress*100).rounded()))%")
                    .font(.body.weight(.semibold))
                    .padding(.vertical)
            }
            .buttonStyle(LargeButton())
        }
        else if clusterDownloader.allDownloaded {
            // not supposed to happen
        }
        else {
            Button {
                // TODO: launch area downloads at the same time or no?
                // TODO: handle priority?
                handpickedDownload = false // move logic to ClusterDownloader
                clusterDownloader.start()
            } label: {
                Text("Télécharger tous les secteurs")
                    .font(.body.weight(.semibold))
                    .padding(.vertical)
            }
            .buttonStyle(LargeButton())
        }
        
    }
}

//#Preview {
//    ClusterDownloadRowView()
//}
