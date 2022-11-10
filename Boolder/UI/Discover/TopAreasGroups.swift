//
//  TopAreasGroups.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 14/02/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopAreasGroups: View {
    @Binding var tabSelection: ContentView.Tab
    let mapState: MapState
    
    let gray = Color(red: 107/255, green: 114/255, blue: 128/255)
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    VStack(alignment: .leading, spacing: 32) {
                        
                        Text("top_areas.groups.description")
                            .font(.body)
                            .foregroundColor(gray)
                        
                        LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())], spacing: 8) {
                            
                            ForEach(areas) { area in
                                Button {
                                    tabSelection = .map
                                    mapState.centerOnArea(area)
                                } label: {
                                    AreaCardView(area: area, width: abs(geo.size.width-16*2-8)/2, height: abs(geo.size.width-16*2-8)/2*9/16)
                                        .contentShape(Rectangle())
                                }
                            }
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.vertical, 8)
                    
                }
                .padding(.horizontal)
                .padding(.top)
            }
        }
        .navigationTitle("top_areas.groups.title")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var areas: [Area] {
        [10, 13, 4, 11, 5, 29, 30, 1].map{Area.load(id: $0)!}.sorted {
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }
    }
}

//struct TopAreasGroups_Previews: PreviewProvider {
//    static var previews: some View {
//        TopAreasGroups()
//    }
//}
