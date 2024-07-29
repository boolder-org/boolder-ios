//
//  ClusterViewWithActionsheet.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 26/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

// we use a separate view to avoid redrawing the entire view everytime, which makes the actionsheet unresponsive
// it probably won't be necessary anymore with iOS 17's @Observable
struct ClusterViewWithActionsheet: View {
    let clusterDownloader: ClusterDownloader // we don't use @ObservedObject because it would make the actionsheets unresponsive
    
    @State private var presentRemoveDownloadSheet = false
    @State private var presentCancelDownloadSheet = false
    @State private var areaToEdit: Area?
    
    var body: some View {
        ClusterView(clusterDownloader: clusterDownloader, presentRemoveDownloadSheet: $presentRemoveDownloadSheet, presentCancelDownloadSheet: $presentCancelDownloadSheet, areaToEdit: $areaToEdit)
            .background {
                EmptyView().actionSheet(isPresented: $presentRemoveDownloadSheet) {
                    ActionSheet(
                        title: Text("download.remove.title"),
                        buttons: [
                            .destructive(Text("download.remove.action")) {
                                if let areaToEdit = areaToEdit {
                                    DownloadCenter.shared.areaDownloader(id: areaToEdit.id).remove()
                                }
                            },
                            .cancel()
                        ]
                    )
                }
            }
            .background {
                EmptyView().actionSheet(isPresented: $presentCancelDownloadSheet) {
                    ActionSheet(
                        title: Text("download.cancel.title"),
                        buttons: [
                            .destructive(Text("download.cancel.action")) {
                                if let areaToEdit = areaToEdit {
                                    DownloadCenter.shared.areaDownloader(id: areaToEdit.id).cancel()
                                }
                            },
                            .cancel()
                        ]
                    )
                }
            }
    }
}

//#Preview {
//    ClusterViewWithActionsheet()
//}
