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
    
    @Binding var presentRemoveDownloadSheet: Bool
    @Binding var presentCancelDownloadSheet: Bool
    @Binding var areaToEdit: Area
    
    let downloadExplanationTip = DownloadExplanationTip()
    
    var body: some View {
        List {
            if #available(iOS 17.0, *) {
                TipView(downloadExplanationTip)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            
            bigButton
            
            Section(header: Text("Secteurs")) {
                ForEach(areas) { a in
                    HStack {
                        Text(a.name).foregroundColor(.primary)
                        
                        Spacer()
                        
                        AreaDownloadRowView(area: a, areaToEdit: $areaToEdit, presentRemoveDownloadSheet: $presentRemoveDownloadSheet, presentCancelDownloadSheet: $presentCancelDownloadSheet, clusterDownloader: clusterDownloader)
                    }
                }
            }
        }
    }
    
    var bigButton: some View {
        Group {
            if clusterDownloader.allDownloaded {
                Section {
                    Button {
                        
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.icloud").font(.title2)
                            Text("Tous les secteurs téléchargés") // .foregroundColor(.primary)
                            Spacer()
                        }
                        .foregroundStyle(.appGreen)
                    }
                }
            }
            else if clusterDownloader.downloadingOrQueued && clusterDownloader.queueType == .auto {
                Section {
                    Button {
                        clusterDownloader.stopDownloads()
                    } label: {
                        HStack {
                            Image(systemName: "stop.circle").frame(height: 18)
                            Text("Téléchargement \(Int(Double(clusterDownloader.progress*100).rounded()))%")
                        }
                        .font(.title3.weight(.semibold))
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(LargeButton())
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            else {
                Section {
                    Button {
                        clusterDownloader.start()
                    } label: {
                        HStack {
                            Image(systemName: "icloud.and.arrow.down").frame(height: 18)
                            Text("Télécharger")
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
    
    // TODO: use AreaDownloader instead of Area
    var areas: [Area] {
        clusterDownloader.areas.map{$0.area}
    }
}

//#Preview {
//    DownloadsView()
//}
