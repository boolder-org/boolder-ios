//
//  ClusterView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/06/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
//import TipKit

struct ClusterView: View {
    @Environment(\.presentationMode) var presentationMode
    
//    let mapState: MapState
    let cluster: Cluster
    let area: Area
    
//    var tip = DownloadTip()
    
    @State private var presentRemoveDownloadSheet = false
    @State private var presentCancelDownloadSheet = false
    @State private var areaToEdit : Area = Area.load(id: 1)! // FIXME
    
    var areasToDisplay: [Area] {
        area.otherAreasOnSameClusterSorted.map{$0.area}
    }
    
    private var remainingAreasToDownload: [AreaDownloader] {
        self.areasToDisplay
            .map { DownloadCenter.shared.areaDownloader(id: $0.id) }
            .filter { $0.status != .downloaded }
    }
    
    private var showDownloadSection: Bool {
        self.areasToDisplay
            .map { DownloadCenter.shared.areaDownloader(id: $0.id) }
            .filter { $0.status != .initial }.count > 0
    }
    
    private var totalSize : Double {
        remainingAreasToDownload.map { $0.area.photosSize }.reduce(0) { sum, size in
            sum + size
        }.rounded()
    }
    
    private var label: String {
        let preview = remainingAreasToDownload.prefix(2).map{$0.area.name}.joined(separator: ", ")
        let remaining = remainingAreasToDownload.count - 2
        
        return [preview, remaining > 0 ? "+\(remaining)" : nil].compactMap{$0}.joined(separator: " ")
    }
    
    var body: some View {
        NavigationView {
            List {


                
                if remainingAreasToDownload.count > 0 {
                    Section { // (footer: Text("Téléchargez tous les secteurs pour utiliser Boolder en mode hors-connexion.")) {
                        Button {
                            remainingAreasToDownload.forEach{$0.requestAndStartDownload()}
                        } label : {
                            HStack {
                                
                                VStack(alignment: .leading) {
                                    Text(cluster.name).foregroundColor(.primary)
                                    Text("\(areasToDisplay.count) secteurs").foregroundColor(.gray).font(.caption) // TODO: deal with singulier
                                }
                                Spacer()
                                Text("\(Int(self.totalSize.rounded())) Mo").foregroundStyle(.gray)
                                Image(systemName: "icloud.and.arrow.down").font(.title2)
                            }
                        }
                    }
                }
                else {
                    Section { // (footer: Text("Vous pouvez utiliser Boolder en mode hors-connexion.")) {
                        Button {
                            //
                        } label : {
                            HStack(alignment: .center) {
                                
                                Text("Tous les secteurs").foregroundColor(.primary)
                                Spacer()
                                //                            Text("\(Int(self.totalSize.rounded())) Mo").foregroundStyle(.gray)
                                Image(systemName: "checkmark.icloud").font(.title2).foregroundStyle(.gray)
                            }
                        }
                    }
                }
               
                if true { //showDownloadSection {
                    Section("Téléchargements") {
                        ForEach(areasToDisplay) { a in
                            
                            HStack {
                                Text(a.name).foregroundColor(.primary)
                                
                                Spacer()
                                
                                DownloadAreaButtonView(area: a, areaToEdit: $areaToEdit, presentRemoveDownloadSheet: $presentRemoveDownloadSheet, presentCancelDownloadSheet: $presentCancelDownloadSheet)
                            }
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
}

//#Preview {
//    DownloadsView()
//}
