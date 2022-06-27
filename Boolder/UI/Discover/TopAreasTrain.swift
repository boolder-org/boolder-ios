//
//  TopAreasTrain.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 14/02/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopAreasTrain: View {
    @EnvironmentObject var dataStore: DataStore
    
    @State var presentArea = false
    let gray = Color(red: 107/255, green: 114/255, blue: 128/255)
    
    var body: some View {
        GeometryReader { geo in
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                VStack(alignment: .leading, spacing: 32) {
                    
                    Text("top_areas.train.description")
                        .font(.body)
                        .foregroundColor(gray)
                    
                    LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())], spacing: 8) {
                        
                        ForEach(areas) { area in
                            
                            NavigationLink(
                                destination: AreaView(),
                                isActive: $presentArea,
                                label: {
                                    AreaCardView(area: area, width: abs(geo.size.width-16*2-8)/2, height: abs(geo.size.width-16*2-8)/2*9/16)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            dataStore.areaId = 1
                                            dataStore.filters = Filters()
                                            presentArea = true
                                        }
                                }
                            )
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
        .navigationTitle("top_areas.train.title")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    var areas: [Area] {
        [1,4,7,24].map{dataStore.area(withId:$0)!}.sorted {
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }
    }
}

struct TopAreasTrain_Previews: PreviewProvider {
    static var previews: some View {
        TopAreasTrain()
    }
}
