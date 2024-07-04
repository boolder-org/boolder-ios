//
//  DownloadsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/06/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import TipKit

struct DownloadsView: View {
    @Environment(\.presentationMode) var presentationMode
    
//    let mapState: MapState
    let cluster: Cluster
    let area: Area
    
    var tip = DownloadTip()
    
    @State private var presentRemoveDownloadSheet = false
    @State private var presentCancelDownloadSheet = false
    @State private var areaToEdit : Area = Area.load(id: 1)! // FIXME
    
    var areasToDisplay: [Area] {
        area.otherAreasOnSameClusterSorted.map{$0.area}
    }
    
    private var footer: some View {
        Text("Téléchargez les secteurs en avance pour utiliser Boolder en mode hors-connexion.")
    }
    
    // Vous pouvez utiliser Boolder en mode hors-connexion dans tous les secteurs ci-dessus.
    
    var body: some View {
        NavigationView {
            List {
                
                if #available(iOS 17.0, *) {
                    Section {
                        TipView(tip)
                            .listRowInsets(EdgeInsets()) // Remove default padding
                            .background(Color.clear) // Remove default white background
                    }
                    .padding(.vertical, 0)
                }

                Section {
                    ForEach(areasToDisplay) { a in
                        
                        HStack {
                            Text(a.name).foregroundColor(.primary)
                            
                            Spacer()
                            
                            DownloadAreaButtonView(area: a, areaToEdit: $areaToEdit, presentRemoveDownloadSheet: $presentRemoveDownloadSheet, presentCancelDownloadSheet: $presentCancelDownloadSheet)
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
            .navigationTitle(cluster.name)
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
