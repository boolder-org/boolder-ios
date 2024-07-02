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
            else if case .downloading(_) = areaDownloader.status  {
                presentCancelDownloadSheet = true
            }
            else if case .downloaded = areaDownloader.status  {
                presentRemoveDownloadSheet = true
            }
        } label: {
            HStack {
                
                if case .initial = areaDownloader.status  {
                    Text("\(Int(area.photosSize.rounded())) Mo").foregroundStyle(.gray)
                    Image(systemName: "arrow.down.circle").font(.title2)
//                    Text("area.photos.download")
                }
                else if case .downloading(let progress) = areaDownloader.status  {
                    Text("area.photos.downloading")
                    CircularProgressView(progress: progress).frame(height: 18)
                }
                else if case .downloaded = areaDownloader.status  {
                    Text("\(Int(area.photosSize.rounded())) Mo").foregroundStyle(.gray)
                    Image(systemName: "checkmark.circle").font(.title2).foregroundColor(.gray)
//                    Text("area.photos.downloaded")
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
