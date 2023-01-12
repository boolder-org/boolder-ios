//
//  AreaLevelsBarView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 11/01/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct AreaLevelsBarView: View {
    let area: Area
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(area.levels) { level in
                Text(String(level.name))
                    .frame(width: 20, height: 20)
                    .foregroundColor(.systemBackground)
                    .background(level.count >= 20 ? Color.levelGreen : Color.gray.opacity(0.5))
                    .cornerRadius(4)
            }
        }
    }
}

struct AreaLevelsBarView_Previews: PreviewProvider {
    static var previews: some View {
        AreaLevelsBarView(area: Area.load(id: 1)!)
    }
}
