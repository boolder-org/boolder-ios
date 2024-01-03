//
//  AreaLoadingStatus.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 18/12/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

// we use a separate view to avoid redrawing the entire view and make the actionsheet unresponsive
// it probably won't be necessary anymore with iOS 17's @Observable
struct AreaLoadingStatus: View {
    let area: Area
    
    @ObservedObject var offlineArea: OfflineArea
    
    init(area: Area) {
        self.area = area
        self.offlineArea = OfflinePhotosManager.shared.offlineArea(withId: area.id)
    }
    
    var body: some View {
        if case .downloading(let progress) = offlineArea.status  {
            CircularProgressView(progress: progress).frame(height: 14)
        }
        else if case .downloaded = offlineArea.status  {
            Image(systemName: "checkmark.circle")
        }
        else {
            Image(systemName: "info.circle")
        }
    }
}

//#Preview {
//    AreaLoadingStatus()
//}
