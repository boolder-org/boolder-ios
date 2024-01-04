//
//  OfflineView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/11/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct OfflineDebugView: View {
    @StateObject private var downloadCenter = DownloadCenter.shared
    
    var body: some View {
        List {
            ForEach(downloadCenter.requestedAreas) { areaDownloader in
                AreaDowloadRow(areaDownloader: areaDownloader)
            }
        }
        .navigationTitle(Text("Offline"))
    }
}

struct AreaDowloadRow: View {
    @ObservedObject var areaDownloader: AreaDownloader
    
    var body: some View {
        HStack {
            Text(areaDownloader.area.name)
            Spacer()
            
            Button {
                areaDownloader.requestAndStartDownload()
            } label: {
                Text(areaDownloader.status.label)
            }
        }
    }
}

#Preview {
    OfflineDebugView()
}
