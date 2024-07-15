//
//  DownloadAreaButtonView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 20/12/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

// we use a separate view to avoid redrawing the entire AreaView everytime, which makes the actionsheet unresponsive
// it probably won't be necessary anymore with iOS 17's @Observable
struct DownloadAreaButtonView : View {
    let area: Area
    
    @ObservedObject var areaDownloader: AreaDownloader
    @Binding var presentRemoveDownloadSheet: Bool
    @Binding var presentCancelDownloadSheet: Bool
    
    init(area: Area, presentRemoveDownloadSheet: Binding<Bool>, presentCancelDownloadSheet: Binding<Bool>) {
        self.area = area
        self.areaDownloader = DownloadCenter.shared.areaDownloader(id: area.id)
        self._presentRemoveDownloadSheet = presentRemoveDownloadSheet
        self._presentCancelDownloadSheet = presentCancelDownloadSheet
    }
    
    var body: some View {
        Button {
            if case .initial = areaDownloader.status  {
                areaDownloader.requestAndStartDownload()
            }
            // FIXME: remove this case
            if case .requested = areaDownloader.status  {
                areaDownloader.requestAndStartDownload()
            }
            else if case .downloading(_) = areaDownloader.status  {
                presentCancelDownloadSheet = true
            }
            else if case .downloaded = areaDownloader.status  {
                presentRemoveDownloadSheet = true
            }
        } label: {
            HStack {
                Spacer()
                
                if case .initial = areaDownloader.status  {
                    Image(systemName: "arrow.down.circle").font(.title2)
                    Text("area.photos.download")
                }
                else if case .downloading(let progress) = areaDownloader.status  {
                    CircularProgressView(progress: progress).frame(height: 18)
                    Text("area.photos.downloading")
                }
                else if case .downloaded = areaDownloader.status  {
                    Image(systemName: "checkmark.circle").font(.title2)
                    Text("area.photos.downloaded")
                }
                else {
                    Text(areaDownloader.status.label)
                }
                
                Spacer()
            }
        }
    }
}

//#Preview {
//    DownloadAreaButtonView()
//}
