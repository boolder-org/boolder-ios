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
        Button {
            
            
            // TODO: refactor: use an enum for button state
            if clusterDownloader.downloadingOrQueued && !handpickedDownload {
                presentCancelClusterDownloadSheet = true
            }
            else if clusterDownloader.allDownloaded {
                presentRemoveClusterDownloadSheet = true
            }
            else {
                // TODO: launch area downloads at the same time or no?
                // TODO: handle priority?
                handpickedDownload = false // move logic to ClusterDownloader
                clusterDownloader.start()
            }
        } label : {
            HStack {
                VStack(alignment: .leading) {
                    Text("Zone \(cluster.name)").foregroundColor(.primary)
                    Text("\(cluster.areas.count) secteurs").foregroundColor(.gray).font(.caption)
                }
                
                Spacer()
                
                if clusterDownloader.downloadingOrQueued && !handpickedDownload {
                    CircularProgressView(progress: clusterDownloader.progress).frame(height: 18)
                }
                else if clusterDownloader.remainingAreasToDownload.count > 0 {
                    Text("\(Int(clusterDownloader.totalSize.rounded())) Mo").foregroundStyle(.gray)
                    Image(systemName: "icloud.and.arrow.down").font(.title2)
                }
                else {
                    Image(systemName: "checkmark.icloud").font(.title2).foregroundStyle(.gray)
                }
            }
        }
    }
}

//#Preview {
//    ClusterDownloadRowView()
//}
