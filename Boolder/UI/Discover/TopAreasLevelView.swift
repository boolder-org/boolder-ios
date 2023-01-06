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
    
    @State private var level = 5
    
    @Binding var appTab: ContentView.Tab
    let mapState: MapState
    
    let gray = Color(red: 107/255, green: 114/255, blue: 128/255)
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading) {
                    
                    VStack {
                        Picker("top_areas.level.level", selection: $level) {
                            ForEach(1..<9) { level in
                                Text(String(level)).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    
                    VStack {
                        Divider() //.padding(.leading)
                        
                        ForEach(Area.allWithLevel(level).filter{$0.problemsCount >= 5}.prefix(20)) { areaWithCount in
                            
                            NavigationLink {
                                AreaView(area: areaWithCount.area, mapState: mapState, appTab: $appTab, linkToMap: true)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(areaWithCount.area.name)
//                                                    .font(.body.weight(.semibold))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
//                                                HStack(spacing: 2) {
//                                                    ForEach(1..<8) { level in
//                                                        Text(String(level))
////                                                            .font(.caption)
//                                                            .frame(width: 20, height: 20)
//                                                            .foregroundColor(.systemBackground)
//                                                            .background(areaWithCount.area.levels[level]! ? Color.levelGreen : Color.gray.opacity(0.5))
//                                                            .cornerRadius(4)
//                                                    }
//                                                }
                                    }

                                    Spacer()
                                    
                                    Text("\(areaWithCount.problemsCount)").foregroundColor(Color(.systemGray))
                                    

                                    
                                    
                                    Image(systemName: "chevron.right").foregroundColor(Color(.systemGray))
                                    
                                }
                                .font(.body)
//                                        .frame(minHeight: 32)
                                .foregroundColor(.primary)
//                                        .background(Color.red)
                                .padding(.horizontal)
//                                        .padding(.leading)
                                .padding(.vertical, 4)
                            }
                            
                            
                            Divider().padding(.leading)
                        }
                    }
                }
//                .padding(.horizontal)
            }
        }
        .navigationTitle("top_areas.level.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct TopAreasLevelView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopAreasLevelView()
//    }
//}
