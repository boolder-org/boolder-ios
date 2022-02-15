//
//  TopAreasLevelView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 07/02/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopAreasLevelView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.openURL) var openURL
    
    @State var presentArea = false
    @State private var level = 0
    
    let gray = Color(red: 107/255, green: 114/255, blue: 128/255)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                VStack {
                    Picker("top_areas.level.level", selection: $level) {
                        Text("top_areas.level.beginner").tag(0)
                        Text("top_areas.level.intermediate").tag(1)
                        Text("top_areas.level.advanced").tag(2)
                    }
                    .pickerStyle(.segmented)
                    
                }
                .padding(.vertical)
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    if(level == 0) {

                        VStack(alignment: .leading) {
                            
                            Divider()
                            
                            ForEach(beginnerAreas) { area in
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
                        
                        Text("top_areas.level.description.beginner")
                            .font(.body)
                            .foregroundColor(gray)
                        
                        
                        Button(action: {
                            openURL(URL(string: NSLocalizedString("top_areas.level.beginners_guide_url", comment: ""))!)
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "book")
                                Text("top_areas.level.read_guide")
                                Spacer()
                            }
                        }
                        .foregroundColor(Color.gray)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.top)
                    }
                    
                    if(level == 1) {

                        VStack(alignment: .leading) {
                            
                            Divider()
                            
                            ForEach(intermediateAreas) { area in
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
                        
                        Text("top_areas.level.description.intermediate")
                            .font(.body)
                            .foregroundColor(gray)
                    }
                    
                    if(level == 2) {
                        
                        VStack(alignment: .leading) {
                            
                            Divider()
                            
                            ForEach(advancedAreas) { area in
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
                        
                        Text("top_areas.level.description.advanced")
                            .font(.body)
                            .foregroundColor(gray)
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("top_areas.level.title")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var beginnerAreas: [Area] {
        [19,14,18,13,2].map{dataStore.area(withId:$0)!}.sorted {
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }
    }
    
    var intermediateAreas: [Area] {
        [10,2,4,5,14,11,7,1].map{dataStore.area(withId:$0)!}.sorted {
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }
    }
    
    var advancedAreas: [Area] {
        [14,12,1,11,4,5,23,7,10,15,13].map{dataStore.area(withId:$0)!}.sorted {
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }
    }
}

struct TopAreasLevelView_Previews: PreviewProvider {
    static var previews: some View {
        TopAreasLevelView()
    }
}
