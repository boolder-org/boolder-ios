//
//  DownloadsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/06/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct DownloadsView: View {
    @Environment(\.presentationMode) var presentationMode
    
//    let mapState: MapState
    let cluster: Cluster
    let area: Area?
    
    private let maxAreas = 5
    
    @State private var collapsed = true
    
    @State private var presentRemoveDownloadSheet = false
    @State private var presentCancelDownloadSheet = false
    @State private var areaToEdit : Area = Area.load(id: 1)! // FIXME
    
//    private func otherClusters(except: Cluster) -> [Cluster] {
//        Cluster.troisPignons
//        
//        return Array(
//            Set(Cluster.troisPignons).subtracting(Set([except]))
//        )
//    }
    
    var mainArea : Area {
        area ?? cluster.mainArea
    }
    
    var title: String {
        if area == nil && cluster.troisPignons {
            return "Trois Pignons"
        }
        else {
            return mainArea.cluster?.name ?? ""
        }
    }
    
    var areasToDisplay: [Area] {
        let areas = mainArea.otherAreasOnSameClusterSorted.map{$0.area}
        
        if collapsed && areas.count > maxAreas {
            return Array(areas.prefix(maxAreas-1))
        }
        else {
            return areas
        }
    }
    
    private var footer: some View {
        Text("Téléchargez les secteurs en avance pour utiliser Boolder en mode hors-connexion.")
    }
    
    var body: some View {
        NavigationView {
            List {
                
                if area == nil && cluster.troisPignons {
                    Section(footer: footer) {
                        ForEach(Cluster.troisPignons) { cluster in
                            NavigationLink {
                                List {
                                    Section(footer: footer) {
                                        ForEach(cluster.areasSorted) { a in
                                            Button {
                                                //
                                            } label: {
                                                HStack {
                                                    Text(a.name).foregroundColor(.primary)
                                                    Spacer()
                                                    DownloadAreaButtonView(area: a, areaToEdit: $areaToEdit, presentRemoveDownloadSheet: .constant(false), presentCancelDownloadSheet: .constant(false))
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                                .navigationTitle(cluster.name)
                                
                            } label: {
                                HStack {
                                    
                                    VStack(alignment: .leading) {
                                        Text("\(cluster.name)")
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(cluster.areas.count)").foregroundStyle(.gray)
                                    
                                }
                            }
                        }
                    }
                }
                
                else {
                    
                        Section(footer: footer) {
                            
                            ForEach(areasToDisplay) { a in
                                
                                HStack {
                                    Text(a.name).foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    DownloadAreaButtonView(area: a, areaToEdit: $areaToEdit, presentRemoveDownloadSheet: $presentRemoveDownloadSheet, presentCancelDownloadSheet: $presentCancelDownloadSheet)
                                }
                                
                            }
                            
                            if collapsed && mainArea.otherAreasOnSameClusterSorted.count > maxAreas {
                                HStack {
                                    Spacer()
                                    Button {
                                        collapsed = false
                                    } label: {
                                        Text("+ \(mainArea.otherAreasOnSameClusterSorted.count - maxAreas + 1) secteurs")
                                    }
                                    Spacer()
                                }
                            }
                        }
                    
                }
                
            }
            .background {
                EmptyView().actionSheet(isPresented: $presentRemoveDownloadSheet) {
                    ActionSheet(
                        title: Text("area.photos.remove.title"),
                        buttons: [
                            .destructive(Text("area.photos.remove.action")) {
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
                        title: Text("area.photos.cancel.title"),
                        buttons: [
                            .destructive(Text("area.photos.cancel.action")) {
                                DownloadCenter.shared.areaDownloader(id: areaToEdit.id).cancel()
                            },
                            .cancel()
                        ]
                    )
                }
            }
            .navigationTitle(title)
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
