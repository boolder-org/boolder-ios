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
    
    @EnvironmentObject var appState: AppState
    
    @State private var areas = [Area]()
    @State private var areasForBeginners = [Area]()
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
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
                    VStack(alignment: .leading) {
                        
                        NavigationLink {
                            TopAreasBeginnerView()
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
                                        
                                        ForEach(areasForBeginners) { area in
                                            NavigationLink {
                                                AreaView(area: area, linkToMap: true)
                                            } label: {
                                                AreaCardView(area: area, width: abs(geo.size.width-16*2-8)/2, height: abs(geo.size.width-16*2-8)/2*9/16)
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
                        
                        
                        VStack {
                            Divider()
                            
                            ForEach(areas) { area in
                                
                                NavigationLink {
                                    AreaView(area: area, linkToMap: true)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(area.name)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        AreaLevelsBarView(area: area)
                                        
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
                    .padding(.bottom)
                }
            }
            .task {
                loadAreasForBeginners()
                loadAreas()
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
            areas = Area.all
        }
    }
}

//struct TopAreasLevelView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopAreasLevelView()
//    }
//}
