//
//  DownloadAreaButtonView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 20/12/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

// we use a separate view to avoid redrawing the entire view and make the actionsheet unresponsive
// it probably won't be necessary anymore with iOS 17's @Observable
struct DownloadAreaButtonView : View {
    let area: Area
    
    @ObservedObject var offlineArea: OfflineArea
    @Binding var presentRemoveDownloadSheet: Bool
    @Binding var presentCancelDownloadSheet: Bool
    
    init(area: Area, presentRemoveDownloadSheet: Binding<Bool>, presentCancelDownloadSheet: Binding<Bool>) {
        self.area = area
        self.offlineArea = OfflinePhotosManager.shared.offlineArea(withId: area.id)
        self._presentRemoveDownloadSheet = presentRemoveDownloadSheet
        self._presentCancelDownloadSheet = presentCancelDownloadSheet
    }
    
    var body: some View {
        let _ = Self._printChanges()
        Button {
            if case .initial = offlineArea.status  {
                // FIXME: refactor
                OfflinePhotosManager.shared.requestArea(areaId: offlineArea.areaId)
                offlineArea.download()
            }
            else if case .downloading(_) = offlineArea.status  {
                presentCancelDownloadSheet = true
            }
            else if case .downloaded = offlineArea.status  {
                presentRemoveDownloadSheet = true
            }
        } label: {
            HStack {
                Spacer()
                
                if case .initial = offlineArea.status  {
                    Image(systemName: "arrow.down.circle").font(.title2)
                    Text("Télécharger les photos")
                }
                else if case .downloading(let progress) = offlineArea.status  {
                    CircularProgressView(progress: progress).frame(height: 18)
                    Text("Téléchargement")
                }
                else if case .downloaded = offlineArea.status  {
                    Image(systemName: "checkmark.circle").font(.title2)
                    Text("Photos téléchargées")
                }
                else {
                    Text(offlineArea.status.label)
                }
                
                Spacer()
            }
        }
    }
}

//#Preview {
//    DownloadAreaButtonView()
//}
