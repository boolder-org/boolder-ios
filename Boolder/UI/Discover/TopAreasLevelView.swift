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
    
    @Binding var appTab: ContentView.Tab
    let mapState: MapState
    
    @State private var areas = [AreaWithLevelsCount]()
    @State private var areasForBeginners = [AreaWithCount]()
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading) {
                    
                    NavigationLink {
                        TopAreasBeginnerView(appTab: $appTab, mapState: mapState)
                    } label: {
                        HStack(alignment: .firstTextBaseline) {
                            Text("discover.top_areas.level.beginner_friendly")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.primary)
                                
                            Image(systemName: "chevron.right")
                                .font(.body.weight(.bold))
                                .foregroundColor(.gray.opacity(0.7))
                            
                            Spacer()
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                        .padding(.horizontal)
                    }

                    
                    
                    VStack {
                        VStack(alignment: .leading) {
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top, spacing: 0) {
                                    
                                    Color.white.opacity(0)
                                        .frame(width: 0, height: 1)
                                        .padding(.leading, 8)
                                    
                                    ForEach(areasForBeginners) { areaWithCount in
                                        NavigationLink {
                                            AreaView(area: areaWithCount.area, mapState: mapState, appTab: $appTab, linkToMap: true)
                                        } label: {
                                            AreaCardView(area: areaWithCount.area, width: abs(geo.size.width-16*2-8)/2, height: abs(geo.size.width-16*2-8)/2*9/16)
                                                .padding(.leading, 8)
                                                .contentShape(Rectangle())
                                        }
                                    }
                                    
                                    Color.white.opacity(0)
                                        .frame(width: 0, height: 1)
                                        .padding(.trailing, 16)
                                }
                            }
                        }
                    }
                    
                    Text("discover.all_areas")
                        .font(.title2).bold()
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                        .padding(.horizontal)
                    
                    if areas.isEmpty {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            Spacer()
                        }
                        .frame(minHeight: 200)
                    }
                    else {
                        VStack {
                            Divider()
                            
                            ForEach(areas) { areaWithLevelsCount in
                                
                                NavigationLink {
                                    AreaView(area: areaWithLevelsCount.area, mapState: mapState, appTab: $appTab, linkToMap: true)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(areaWithLevelsCount.area.name)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 2) {
                                            ForEach(areaWithLevelsCount.problemsCount) { levelCount in
                                                Text(String(levelCount.name))
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.systemBackground)
                                                    .background(levelCount.count >= 20 ? Color.levelGreen : Color.gray.opacity(0.5))
                                                    .cornerRadius(4)
                                            }
                                        }
                                        
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption.weight(.bold))
                                            .foregroundColor(.gray.opacity(0.7))
                                        
                                    }
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                                }
                                
                                
                                Divider().padding(.leading)
                            }
                        }
                    }
                }
                .padding(.bottom)
            }
            .modify {
                if #available(iOS 16, *) {
                    $0.onAppear {
                        loadAreasForBeginners()
                    }
                    .task {
                        loadAreas()
                    }
                }
                else {
                    $0.onAppear {
                        loadAreasForBeginners()
                        loadAreas()
                    }
                }
            }
        }
        .navigationTitle("top_areas.level.title")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func loadAreasForBeginners() {
        if areasForBeginners.isEmpty {
            areasForBeginners = Area.forBeginners
        }
    }
    
    func loadAreas() {
        if areas.isEmpty {
            areas = Area.all.map{ areaWithCount in
                AreaWithLevelsCount(
                    area: areaWithCount.area,
                    problemsCount:
                        [
                            .init(name: "1", count: areaWithCount.area.problemsCount(level: 1)),
                            .init(name: "2", count: areaWithCount.area.problemsCount(level: 2)),
                            .init(name: "3", count: areaWithCount.area.problemsCount(level: 3)),
                            .init(name: "4", count: areaWithCount.area.problemsCount(level: 4)),
                            .init(name: "5", count: areaWithCount.area.problemsCount(level: 5)),
                            .init(name: "6", count: areaWithCount.area.problemsCount(level: 6)),
                            .init(name: "7", count: areaWithCount.area.problemsCount(level: 7)),
                            .init(name: "8", count: areaWithCount.area.problemsCount(level: 8)),
                        ]
                )
            }
        }
    }
}

//struct TopAreasLevelView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopAreasLevelView()
//    }
//}
