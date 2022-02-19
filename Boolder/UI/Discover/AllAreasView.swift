//
//  AllAreasView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/02/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct AllAreasView: View {
    @State private var selectedArea: Area?
    @State private var presentArea = false
    
    var body: some View {
        AllAreasMapView(selectedArea: $selectedArea, presentArea: $presentArea)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .edgesIgnoringSafeArea([.bottom, .horizontal])
            .navigationTitle("Carte")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                NavigationLink(
                    destination: AreaView(),
                    isActive: $presentArea,
                    label: {
                        EmptyView()
                    }
                )
            )
    }
}

struct AllAreasView_Previews: PreviewProvider {
    static var previews: some View {
        AllAreasView()
    }
}
