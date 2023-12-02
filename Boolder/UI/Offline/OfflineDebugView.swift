//
//  OfflineView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/11/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct OfflineDebugView: View {
//    @State private var offlineAreas = [OfflineManager.OfflineArea]()
    @StateObject private var offlineManager = OfflinePhotosManager.shared
    
    var body: some View {
        
        
        List {
            ForEach(offlineManager.requestedAreas.indices, id: \.self) { index in
                OfflineAreaRow(offlineArea: offlineManager.requestedAreas[index])
            }
        }
        .navigationTitle(Text("Offline"))
        .onAppear {
            //                offlineManager.start()
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
                OfflinePhotosManager.shared.requestArea(areaId: offlineArea.areaId)
                offlineArea.download()
            } label: {
                Text(offlineArea.status.label)
            }
            Text("\(packSize) Mo").foregroundColor(.gray)
            
        }
    }
    
    var packSize: Int {
        // TODO: improve estimation
        Int(Double(offlineArea.area.problemsCount)*0.7*150.0/1000.0)
    }
}

#Preview {
    OfflineDebugView()
}
