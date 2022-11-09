//
//  TopAreasLevelView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 07/02/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopAreasLevelView: View {
    @Environment(\.openURL) var openURL
    
    @State private var level = 0
    
    @Binding var tabSelection: Int
    @Binding var centerOnArea: Area?
    @Binding var centerOnAreaCount: Int
    
    let gray = Color(red: 107/255, green: 114/255, blue: 128/255)
    
    var body: some View {
        GeometryReader { geo in
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
                            
                            VStack(alignment: .leading, spacing: 32) {
                                
                                Text("top_areas.level.description.beginner")
                                    .font(.body)
                                    .foregroundColor(gray)
                                
                                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())], spacing: 8) {
                                    
                                    ForEach(beginnerAreas) { area in
                                        Button {
                                            tabSelection = 1
                                            centerOnArea = area
                                            centerOnAreaCount += 1
                                        } label: {
                                            AreaCardView(area: area, width: abs(geo.size.width-16*2-8)/2, height: abs(geo.size.width-16*2-8)/2*9/16)
                                                .contentShape(Rectangle())
                                        }
                                        
                                        
                                    }
                                }
                                
                                Button(action: {
                                    openURL(guideURL)
                                }) {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "book")
                                        Text("top_areas.level.read_guide")
                                        Spacer()
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                            
                        }
                        
                        if(level == 1) {
                            
                            VStack(alignment: .leading, spacing: 32) {
                                
                                Text("top_areas.level.description.intermediate")
                                    .font(.body)
                                    .foregroundColor(gray)
                                
                                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())], spacing: 8) {
                                    
                                    ForEach(intermediateAreas) { area in
                                        
                                        Button {
                                            tabSelection = 1
                                            centerOnArea = area
                                            centerOnAreaCount += 1
                                        } label: {
                                            AreaCardView(area: area, width: abs(geo.size.width-16*2-8)/2, height: abs(geo.size.width-16*2-8)/2*9/16)
                                                .contentShape(Rectangle())
                                        }
                                    }
                                }
                                
                                HStack(alignment: .top) {
                                    Image(systemName: "exclamationmark.triangle.fill").font(.body)
                                    Text("top_areas.level.intermediate.warning").font(.body)
                                    Spacer()
                                }
                                .foregroundColor(Color.orange.opacity(0.8))
                                .padding()
                                .background(Color.yellow.opacity(0.2))
                                .cornerRadius(8)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                            
                            
                            
                        }
                        
                        if(level == 2) {
                            
                            VStack(alignment: .leading, spacing: 32) {
                                
                                Text("top_areas.level.description.advanced")
                                    .font(.body)
                                    .foregroundColor(gray)
                                
                                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())], spacing: 8) {
                                    
                                    ForEach(advancedAreas) { area in
                                        
                                        Button {
                                            tabSelection = 1
                                            centerOnArea = area
                                            centerOnAreaCount += 1
                                        } label: {
                                            AreaCardView(area: area, width: abs(geo.size.width-16*2-8)/2, height: abs(geo.size.width-16*2-8)/2*9/16)
                                                .contentShape(Rectangle())
                                        }
                                        
                                        
                                    }
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("top_areas.level.title")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var beginnerAreas: [Area] {
        [19, 14, 18, 13, 2, 51].map{Area.load(id: $0)!}.sorted {
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }
    }
    
    var intermediateAreas: [Area] {
        [10, 2, 4, 11, 5, 14, 29, 32, 30, 1].map{Area.load(id: $0)!}.sorted {
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }
    }
    
    var advancedAreas: [Area] {
        [21, 10, 13, 4, 11, 5, 15, 12, 14, 6, 23, 26, 29, 33, 30, 41, 20, 50, 1, 44, 69].map{Area.load(id: $0)!}.sorted {
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }
    }
    
    var guideURL: URL {
        URL(string: "https://www.boolder.com/\(NSLocale.websiteLocale)/articles/beginners-guide")!
    }
}

//struct TopAreasLevelView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopAreasLevelView()
//    }
//}
