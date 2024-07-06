//
//  ClusterView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/06/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import TipKit

struct ClusterView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var clusterDownloader: ClusterDownloader
    
//    let mapState: MapState
    let cluster: Cluster
    let area: Area
    
    var tip = DownloadTip()
    
    @State private var presentRemoveDownloadSheet = false
    @State private var presentCancelDownloadSheet = false
    @State private var areaToEdit : Area = Area.load(id: 1)! // FIXME
    
    @State private var expandDetails = false
    @State private var handpickedDownload = false
    
    var areasToDisplay: [Area] {
        area.otherAreasOnSameClusterSorted.map{$0.area}
    }
    
//    private var showDownloadSection: Bool {
//        clusterDownloader.areas.count > 1 && (clusterDownloader.downloadRequested || !collapsed)
//    }
    
    var body: some View {
        NavigationView {
            List {
                if clusterDownloader.areas.count > 1 {
                    Section { // (footer: Text("Téléchargez tous les secteurs pour utiliser Boolder en mode hors-connexion.")) {
                        Button {
                            handpickedDownload = false
//                            expandDetails = true // necessary?
                            
                            if clusterDownloader.severalDownloading {
                                // TODO: ask for confirmation
                                clusterDownloader.stopDownloads()
                            }
                            else {
                                // TODO: launch area downloads at the same time or no?
                                clusterDownloader.remainingAreasToDownload.forEach{ area in
                                    //                                DispatchQueue.main.asyncAfter(deadline: .now() + 2 * Double.random(in: 0..<1)) {
                                    area.requestAndStartDownload()
                                    //                                }
                                }
                            }
                        } label : {
                            HStack {
                                
                                VStack(alignment: .leading) {
                                    Text("Zone \(cluster.name)").foregroundColor(.primary)
                                    // TODO: deal with singulier
                                    // TODO: Elephant + 2 secteurs - when there is a selectedArea
//                                    Text("\(areasToDisplay.count) secteurs").foregroundColor(.gray).font(.caption)
                                }
                                Spacer()
                                
                                if clusterDownloader.downloading && !handpickedDownload {
                                    //                                Text("\(Int(clusterDownloader.totalSize.rounded())) Mo").foregroundStyle(.gray)
                                    //                                    .padding(.trailing)
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
//                        .modify {
//                            if #available(iOS 17.0, *) {
//                                $0.popoverTip(tip, arrowEdge: .top)
//                            }
//                        }
                        
                        
                        
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
               
//                if clusterDownloader.areas.count > 1 {
                if expandDetails || clusterDownloader.areas.count == 1 {
                        Section {
                            ForEach(areasToDisplay) { a in
                                
                                HStack {
                                    Text(a.name).foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    DownloadAreaButtonView(area: a, areaToEdit: $areaToEdit, presentRemoveDownloadSheet: $presentRemoveDownloadSheet, presentCancelDownloadSheet: $presentCancelDownloadSheet, handpickedDownload: $handpickedDownload)
                                }
                            }
                        }
                    }
                else {
                    Button {
                        expandDetails = true
                    } label : {
                        HStack {
                            Text("\(areasToDisplay.count) secteurs").foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down").foregroundStyle(.gray)
                        }
                    }
                }
//
//                }

                
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
}

//#Preview {
//    DownloadsView()
//}
