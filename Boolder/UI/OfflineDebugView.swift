//
//  OfflineView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/11/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct OfflineDebugView: View {
    @StateObject private var offlineManager = AreaPhotosDownloader.shared
    
    var body: some View {
        List {
            ForEach(offlineManager.requestedAreas.indices, id: \.self) { index in
                OfflineAreaRow(offlineArea: offlineManager.requestedAreas[index])
            }
        }
        .navigationTitle(Text("Offline"))
    }
}

struct OfflineAreaRow: View {
    @ObservedObject var offlineArea: OfflineArea
    
    var body: some View {
        HStack {
            Text(offlineArea.area.name)
            Spacer()
            
            Button {
                AreaPhotosDownloader.shared.download(areaId: offlineArea.areaId)
            } label: {
                Text(offlineArea.status.label)
            }
        }
    }
}

#Preview {
    OfflineDebugView()
}
