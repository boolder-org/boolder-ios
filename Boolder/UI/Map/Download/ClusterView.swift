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
    
    @Binding var presentRemoveDownloadSheet: Bool
    @Binding var presentCancelDownloadSheet: Bool
    @Binding var areaToEdit: Area
    
    @State private var handpickedDownload = false
    
    var body: some View {
        NavigationView {
            List {
                ClusterDownloadRowView(clusterDownloader: clusterDownloader, handpickedDownload: $handpickedDownload)
                
                Section(header: Text("Secteurs")) {
                    ForEach(areas) { a in
                        HStack {
                            Text(a.name).foregroundColor(.primary)
                            
                            Spacer()
                            
                            AreaDownloadRowView(area: a, areaToEdit: $areaToEdit, presentRemoveDownloadSheet: $presentRemoveDownloadSheet, presentCancelDownloadSheet: $presentCancelDownloadSheet, handpickedDownload: $handpickedDownload, clusterDownloader: clusterDownloader)
                        }
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right").frame(minWidth: 30)
                        Text("Plus besoin de chercher du réseau Internet au milieu de la forêt").font(.caption)
                    }
                    .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "battery.75percent").frame(minWidth: 30)
                        Text("Économisez votre batterie en activant le mode avion").font(.caption)
                    }
                    .foregroundColor(.gray)
                }
            }
            
            .navigationTitle("Zone \(clusterDownloader.cluster.name)")
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
    
    // TODO: use AreaDownloader instead of Area
    var areas: [Area] {
        clusterDownloader.areas.map{$0.area}
    }
}

//#Preview {
//    DownloadsView()
//}
