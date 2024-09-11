//
//  ImprovedTopoView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 11/09/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ImprovedTopoView: View {
    let topo: TopoWithPosition
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    var image: UIImage {
        topo.topo.onDiskPhoto!
    }
}

//#Preview {
//    ImprovedTopoView()
//}
