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
                    HStack {
                        Text(offlineManager.offlineAreas[index].area.name)
                        Spacer()
                        Button {
                            offlineManager.offlineAreas[index].download()
                        } label: {
                            Text(offlineManager.offlineAreas[index].downloaded ? "downloaded" : "download")
                        }
                    }
                }
            }
            .navigationTitle(Text("Offline"))
            .onAppear {
                
            }
        }
    }
}

#Preview {
    OfflineView()
}
