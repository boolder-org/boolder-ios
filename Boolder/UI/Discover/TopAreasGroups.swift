//
//  TopAreasGroups.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 14/02/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopAreasGroups: View {
    @EnvironmentObject var dataStore: DataStore
    
    @State var presentArea = false
    let gray = Color(red: 107/255, green: 114/255, blue: 128/255)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                VStack(alignment: .leading) {
                    
                    Divider()
                    
                    ForEach(areas) { area in
                        NavigationLink(
                            destination: AreaView(),
                            isActive: $presentArea,
                            label: {
                                HStack {
                                    Text(area.name)
                                        .font(.body)
                                        .foregroundColor(Color.appGreen)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    dataStore.areaId = area.id
                                    dataStore.filters = Filters()
                                    presentArea = true
                                }
                            }
                        )
                        
                        Divider()
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                .padding(.vertical, 8)
                
                Text("Ces secteurs offrent de nombreuses voies dans tous les niveaux de 2 à 7.")
                    .font(.body)
                    .foregroundColor(gray)
                
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .navigationTitle("En groupe")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    var areas: [Area] {
        [10,7,13,4,11,5,1].map{dataStore.area(withId:$0)!}.sorted {
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }
    }
}

struct TopAreasGroups_Previews: PreviewProvider {
    static var previews: some View {
        TopAreasGroups()
    }
}
