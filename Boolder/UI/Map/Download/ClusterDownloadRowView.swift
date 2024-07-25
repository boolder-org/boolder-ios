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
        if clusterDownloader.allDownloaded {
            Section(footer: Text("Vous pouvez utiliser Boolder sans connexion dans tous les secteurs ci-dessous :")) {
                Button {
                    presentRemoveClusterDownloadSheet = true
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Zone \(cluster.name)").foregroundColor(.primary)
//                                    Text("\(cluster.areas.count) secteurs").font(.caption).foregroundColor(.gray)
                        }
                        
                        Spacer()
                        Image(systemName: "checkmark.icloud").foregroundStyle(.gray).font(.title2)
                    }
                }
                .actionSheet(isPresented: $presentRemoveClusterDownloadSheet) {
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
        else if clusterDownloader.downloadingOrQueued && !handpickedDownload {
            Section {
                Button {
                    presentCancelClusterDownloadSheet = true
                } label: {
                    Text("Téléchargement \(Int(Double(clusterDownloader.progress*100).rounded()))%")
                        .font(.title3.weight(.semibold))
                        .padding(.vertical, 8)
                }
                .buttonStyle(LargeButton())
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .background {
                EmptyView().actionSheet(isPresented: $presentCancelClusterDownloadSheet) {
                    ActionSheet(
                        title: Text("Arrêter les téléchargements ?"),
                        buttons: [
                            .destructive(Text("Arrêter")) {
                                clusterDownloader.stopDownloads()
                            },
                            .cancel()
                        ]
                    )
                }
            }
        }
        else {
            Section {
                Button {
                    // TODO: launch area downloads at the same time or no?
                    // TODO: handle priority?
                    handpickedDownload = false // move logic to ClusterDownloader
                    clusterDownloader.start()
                } label: {
                    HStack {
                        Image(systemName: "icloud.and.arrow.down")
                        Text("Télécharger")
                        //                        .font(.body.weight(.semibold))
                        //                        .padding(.vertical)
                    }
                    .font(.title3.weight(.semibold))
                    .padding(.vertical, 8)
                    
                }
                .buttonStyle(LargeButton())
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        
    }
}

//#Preview {
//    ClusterDownloadRowView()
//}
