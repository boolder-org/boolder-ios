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
    
    @Binding var handpickedDownload: Bool
    
    var body: some View {
        NavigationView {
            List {
                ClusterDownloadRowView(clusterDownloader: clusterDownloader, handpickedDownload: $handpickedDownload)
                
                Section(header: Text("Secteurs"), footer: footer) {
                    ForEach(areas) { a in
                        HStack {
                            Text(a.name).foregroundColor(.primary)
                            
                            Spacer()
                            
                            AreaDownloadRowView(area: a, areaToEdit: $areaToEdit, presentRemoveDownloadSheet: $presentRemoveDownloadSheet, presentCancelDownloadSheet: $presentCancelDownloadSheet, handpickedDownload: $handpickedDownload, clusterDownloader: clusterDownloader)
                        }
                    }
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
    
    var footer: some View {
        if clusterDownloader.allDownloaded {
            Text("Tout est bon, vous pouvez utiliser Boolder sans connexion dans tous ces secteurs.")
        }
        else {
            Text("Après avoir téléchargé ces secteurs, vous pourrez utiliser Boolder sans connexion.")
        }
    }
}

//#Preview {
//    DownloadsView()
//}
