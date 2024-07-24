//
//  ClusterView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/06/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ClusterView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var clusterDownloader: ClusterDownloader
    let cluster: Cluster
    let area: Area?
    
    @State private var presentRemoveDownloadSheet = false
    @State private var presentCancelDownloadSheet = false
    @State private var areaToEdit : Area = Area.load(id: 1)! // FIXME: don't use bang
    
    @State private var handpickedDownload = false // TODO: use enum
    
    var areas: [Area] {
        cluster.areasSortedByDistance(area)
    }
    
    var body: some View {
        NavigationView {
            List {
                if areas.count > 1 {
                    clusterSection
                }
                
                areasSection
            }
            .background {
                EmptyView().actionSheet(isPresented: $presentRemoveDownloadSheet) {
                    ActionSheet(
                        title: Text("download.remove.title"),
                        buttons: [
                            .destructive(Text("download.remove.action")) {
                                DownloadCenter.shared.areaDownloader(id: areaToEdit.id).remove()
                            },
                            .cancel()
                        ]
                    )
                }
            }
            .background {
                EmptyView().actionSheet(isPresented: $presentCancelDownloadSheet) {
                    ActionSheet(
                        title: Text("download.cancel.title"),
                        buttons: [
                            .destructive(Text("download.cancel.action")) {
                                DownloadCenter.shared.areaDownloader(id: areaToEdit.id).cancel()
                            },
                            .cancel()
                        ]
                    )
                }
            }
            .navigationTitle("Télécharger")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Fermer")
                        .padding(.vertical)
                        .font(.body)
                }
            )
        }
    }
    
    var clusterSection: some View {
        Section {
            Button {
                handpickedDownload = false
                
                // TODO: refactor: use an enum for button state
                if clusterDownloader.downloadingOrQueued {
                    // TODO: ask for confirmation
                    clusterDownloader.stopDownloads()
                }
                else {
                    // TODO: launch area downloads at the same time or no?
                    // TODO: handle priority?
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
    
    var areasSection: some View {
        Section { // }(header: Text("\(areas.count) secteurs")) {
            ForEach(areas) { a in
                HStack {
                    Text(a.name).foregroundColor(.primary)
                    
                    Spacer()
                    
                    AreaDownloadRowView(area: a, areaToEdit: $areaToEdit, presentRemoveDownloadSheet: $presentRemoveDownloadSheet, presentCancelDownloadSheet: $presentCancelDownloadSheet, handpickedDownload: $handpickedDownload)
                }
            }
        }
    }
}

//#Preview {
//    DownloadsView()
//}
