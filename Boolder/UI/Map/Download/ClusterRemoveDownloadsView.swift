//
//  ClusterRemoveDownloadsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 25/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ClusterRemoveDownloadsView: View {
    @ObservedObject var clusterDownloader: ClusterDownloader
    let cluster: Cluster
    @Binding var presentRemoveClusterDownloadSheet: Bool
    
    var body: some View {
        if clusterDownloader.allDownloaded {
            Section {
                Button {
                    presentRemoveClusterDownloadSheet = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Supprimer les téléchargements").foregroundColor(.red)
                        Spacer()
                    }
                }
            }
            .background {
                EmptyView().actionSheet(isPresented: $presentRemoveClusterDownloadSheet) {
                    ActionSheet(
                        title: Text("Supprimer les téléchargements ?"),
                        buttons: [
                            .destructive(Text("Supprimer")) {
                                clusterDownloader.removeDownloads()
                            },
                            .cancel()
                        ]
                    )
                }
            }
        }
    }
}

//#Preview {
//    ClusterRemoveDownloadsView()
//}
