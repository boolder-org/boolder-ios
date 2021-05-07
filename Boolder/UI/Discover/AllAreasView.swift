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
    
    var body: some View {
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
    
    var areasDisplayed: [Area] {
        let published = dataStore.areas.filter { $0.published }
        
        var displayed = published
        
        #if DEVELOPMENT
        displayed = dataStore.areas
        #endif
        
        return displayed.sorted {
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
            
        }
    }
}

struct AllAreasView_Previews: PreviewProvider {
    static var previews: some View {
        AllAreasView()
    }
}
