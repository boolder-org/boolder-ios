//
//  AreaDownloadRowView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 20/12/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct AreaDownloadRowView : View {
    let area: Area
    
    @ObservedObject var areaDownloader: AreaDownloader
    @Binding var presentRemoveDownloadSheet: Bool
    @Binding var presentCancelDownloadSheet: Bool
    @Binding var areaToEdit : Area
    
    @ObservedObject var clusterDownloader: ClusterDownloader
    
    init(area: Area, areaToEdit: Binding<Area>, presentRemoveDownloadSheet: Binding<Bool>, presentCancelDownloadSheet: Binding<Bool>, clusterDownloader: ClusterDownloader) {
        self.area = area
        self.areaDownloader = DownloadCenter.shared.areaDownloader(id: area.id)
        self._areaToEdit = areaToEdit
        self._presentRemoveDownloadSheet = presentRemoveDownloadSheet
        self._presentCancelDownloadSheet = presentCancelDownloadSheet
        self.clusterDownloader = clusterDownloader
    }
    
    var body: some View {
        Button {
            if !clusterDownloader.queueRunning || clusterDownloader.queueType == .manual {
                if case .initial = areaDownloader.status  {
                    clusterDownloader.addAreaToQueue(areaDownloader)
                }
                else if case .queued = areaDownloader.status  {
                    clusterDownloader.removeAreaFromQueue(areaDownloader)
                }
                else if case .downloading(_) = areaDownloader.status  {
                    areaToEdit = area
                    presentCancelDownloadSheet = true
                }
                else if case .downloaded = areaDownloader.status  {
                    areaToEdit = area
                    presentRemoveDownloadSheet = true
                }
            }
        } label: {
            HStack {
                
                if case .initial = areaDownloader.status  {
                    Image(systemName: "icloud.and.arrow.down").font(.title2)
                }
                else if areaDownloader.downloadingOrQueued  {
                    CircularProgressView(progress: areaDownloader.status.progress).frame(height: 18)
                }
                else if case .downloaded = areaDownloader.status  {
                    Image(systemName: "checkmark.icloud").foregroundStyle(.gray).font(.title2)
                }
                else {
                    Text(areaDownloader.status.label)
                }
            }
        }
    }
}

//#Preview {
//    DownloadAreaButtonView()
//}
