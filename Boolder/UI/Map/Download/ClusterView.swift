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
    
    let downloadTip = DownloadTip()
    
    var body: some View {
        List {
            bigButton
            
            if #available(iOS 17.0, *) {
                TipView(downloadTip)
                    .tipBackground(Color.systemBackground)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            
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
        .modify {
            if #available(iOS 17.0, *) {
                $0.sensoryFeedback(.success, trigger: clusterDownloader.allDownloaded) { oldValue, newValue in
                    newValue
                }
            }
        }
    }
    
    var bigButton: some View {
        Group {
            if clusterDownloader.allDownloaded {
                Section {
                    Button {
                        // TODO: remove downloads
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.icloud").font(.title2)
                            Text("Secteurs téléchargés") // .foregroundColor(.primary)
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
                        if #available(iOS 17.0, *) {
                            downloadTip.invalidate(reason: .actionPerformed)
                        }
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
