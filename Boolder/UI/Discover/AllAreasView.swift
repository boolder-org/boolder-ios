//
//  AllAreasView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 06/05/2021.
//  Copyright © 2021 Nicolas Mondollot. All rights reserved.
//

import Foundation
import SwiftUI

struct AllAreasView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var presentationMode // required because of a bug with iOS 13: https://stackoverflow.com/questions/58512344/swiftui-navigation-bar-button-not-clickable-after-sheet-has-been-presented
    
    @State var presentArea = false
    
    
    
    let areas = [
        Area(id: 1,  name: "Rocher Canon", published: true),
        Area(id: 2,  name: "Cul de Chien", published: true),
        Area(id: 4,  name: "Cuvier", published: true),
        Area(id: 5,  name: "Franchard Isatis", published: true),
        Area(id: 6,  name: "Cuvier Est (Bellevue)", published: false),
        Area(id: 7,  name: "Apremont", published: true),
        Area(id: 8,  name: "Rocher Fin", published: false),
        Area(id: 9,  name: "Éléphant", published: true),
        Area(id: 10, name: "95.2", published: true),
        Area(id: 11, name: "Franchard Cuisinière", published: true),
        Area(id: 12, name: "Roche aux Sabots", published: true),
        Area(id: 13, name: "Canche aux Merciers", published: true),
        Area(id: 14, name: "Rocher du Potala", published: true),
        Area(id: 15, name: "Gorge aux Châts", published: true),
    ]
    
    var areasDisplayed: [Area] {
        let published = areas.filter { $0.published }
        
        var displayed = published
        
        #if DEVELOPMENT
        displayed = areas
        #endif
        
        return displayed.sorted {
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
            
        }
    }
    
    var body: some View {
//        List {
//            ForEach(areas) { area in
//                NavigationLink(
//                    destination: AreaView(),
//                    isActive: $presentArea,
//                    label: {
//                        HStack {
//                            Text(area.name)
//                                .font(.body)
//                            Spacer()
//                            Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
//                        }
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            dataStore.areaId = area.id
//                            dataStore.filters = Filters()
////                            presentArea = true
//                        }
//                    }
//                )
//            }
//        }
        ScrollView {
            LazyVStack {
                VStack(alignment: .leading) {

                    ForEach(areasDisplayed) { area in
                        NavigationLink(
                            destination: AreaView(),
                            isActive: $presentArea,
                            label: {
                                HStack {
                                    Text(area.name)
                                        .font(.body)
                                        .foregroundColor(Color.primary)
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
                .padding(.horizontal)
            }
        }
        .navigationBarTitle(Text("all_areas.title"), displayMode: .inline)
    }
}

struct AllAreasView_Previews: PreviewProvider {
    static var previews: some View {
        AllAreasView()
    }
}
