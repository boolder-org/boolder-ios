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
    @Binding var areaToEdit: Area?
    
    let tip = DownloadTip()
    
    var body: some View {
        List {
            bigButton
            
            if #available(iOS 17.0, *) {
                TipView(tip)
                    .tipBackground(Color.systemBackground)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .onChange(of: clusterDownloader.queueRunning) { oldValue, newValue in
                        tip.invalidate(reason: .actionPerformed)
                    }
            }
            
            Section(header: Text("download.cluster.areas")) {
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
                            Text("download.cluster.downloaded")
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
                            Text(titleDownloading)
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
                            Text("download.cluster.download")
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
    
    var titleDownloading: String {
        let percentage = Int(Double(clusterDownloader.progress*100).rounded())
        return String(format: NSLocalizedString("download.cluster.downloading", comment: ""), percentage)
    }
    
    // TODO: use AreaDownloader instead of Area
    var areas: [Area] {
        clusterDownloader.areas.map{$0.area}
    }
}

//#Preview {
//    DownloadsView()
//}
