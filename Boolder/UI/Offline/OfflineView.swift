//
//  OfflineView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/11/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct OfflineView: View {
//    @State private var offlineAreas = [OfflineManager.OfflineArea]()
    @StateObject private var offlineManager = OfflineManager.shared
    
    var body: some View {
        NavigationView {
            List {
                ForEach(offlineManager.offlineAreas.indices, id: \.self) { index in
                    OfflineAreaRow(offlineArea: offlineManager.offlineAreas[index])
                }
            }
            .navigationTitle(Text("Offline"))
            .onAppear {
//                offlineManager.start()
            }
        }
    }
}

struct OfflineAreaRow: View {
    @ObservedObject var offlineArea: OfflineArea
    
    var body: some View {
        
        HStack {
            Text(offlineArea.area.name)
            Spacer()
            Button {
                OfflineManager.shared.requestArea(areaId: offlineArea.areaId)
                offlineArea.download()
            } label: {
                Text(offlineArea.status.label)
            }
            
        }
    }
}

#Preview {
    OfflineView()
}
