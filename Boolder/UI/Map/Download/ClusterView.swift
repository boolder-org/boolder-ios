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
    let area: Area // TODO: rename
    
    @State private var presentRemoveDownloadSheet = false
    @State private var presentCancelDownloadSheet = false
    @State private var areaToEdit : Area = Area.load(id: 1)! // FIXME: don't use bang
    
    @State private var expandDetails = false
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
                
                if expandDetails || areas.count == 1 {
                    areasSection
                }
                else {
                    Button {
                        expandDetails = true
                    } label : {
                        HStack {
                            Text("\(areas.count) secteurs").foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down").foregroundStyle(.gray)
                        }
                    }
                }
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
                
                if clusterDownloader.severalDownloading {
                    // TODO: ask for confirmation
                    clusterDownloader.stopDownloads()
                }
                else {
                    // TODO: launch area downloads at the same time or no?
                    // TODO: handle priority?
                    clusterDownloader.remainingAreasToDownload.forEach{ area in
                        area.requestAndStartDownload()
                    }
                }
            } label : {
                HStack {
                    Text("Zone \(cluster.name)").foregroundColor(.primary)
                    
                    Spacer()
                    
                    if clusterDownloader.downloading && !handpickedDownload {
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
            
            if clusterDownloader.severalDownloading && !handpickedDownload {
                Button {
                    // TODO: ask for confirmation
                    clusterDownloader.stopDownloads()
                } label : {
                    HStack {
                        Spacer()
                        Text("Annuler").foregroundStyle(.red)
                        Spacer()
                    }
                }
            }
        }
    }
    
    var areasSection: some View {
        Section {
            ForEach(areas) { a in
                HStack {
                    Text(a.name).foregroundColor(.primary)
                    
                    Spacer()
                    
                    DownloadAreaButtonView(area: a, areaToEdit: $areaToEdit, presentRemoveDownloadSheet: $presentRemoveDownloadSheet, presentCancelDownloadSheet: $presentCancelDownloadSheet, handpickedDownload: $handpickedDownload)
                }
            }
        }
    }
}

//#Preview {
//    DownloadsView()
//}
