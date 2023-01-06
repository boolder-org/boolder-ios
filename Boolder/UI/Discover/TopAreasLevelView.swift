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
    
    @State private var level = 6
    
    @Binding var appTab: ContentView.Tab
    let mapState: MapState
    
    let gray = Color(red: 107/255, green: 114/255, blue: 128/255)
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading) {
                    
                    VStack {
                        Picker("top_areas.level.level", selection: $level) {
                            Text("1 → 3").tag(3)
                            ForEach(4..<9) { level in
                                Text(String(level)).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    
                    if level == 3 {
                        VStack(alignment: .leading) {
//                            Text("Débutant")
//                                .font(.title2).bold()
//                                .padding(.horizontal)
//                                .padding(.bottom)
                            
                            Divider() //.padding(.leading)
                            
                            ForEach(Area.forBeginners) { areaWithCount in
                                
                                NavigationLink {
                                    AreaView(area: areaWithCount.area, mapState: mapState, appTab: $appTab, linkToMap: true)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(areaWithCount.area.name)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(areaWithCount.problemsCount)").foregroundColor(Color(.systemGray))
                                        Image(systemName: "chevron.right").foregroundColor(Color(.systemGray))
                                        
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
                    else {
                        VStack {
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text("Secteurs avec voies de **niveau \(String(level))**")
////                                    .foregroundColor(.gray)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                            }
//
//                                .padding(.horizontal)
//                                .padding(.bottom)
                            
                            Divider() //.padding(.leading)
                            
                            ForEach(Area.allWithLevel(level).filter{$0.problemsCount >= 5}.prefix(20)) { areaWithCount in
                                
                                NavigationLink {
                                    AreaView(area: areaWithCount.area, mapState: mapState, appTab: $appTab, linkToMap: true)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(areaWithCount.area.name)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            
                                        }
                                        
                                        Spacer()
                                        
                                        if level <= 5 && areaWithCount.area.circuits.filter{$0.dangerous && $0.averageGrade < Grade("6a")}.count > 0 {
                                            Image(systemName: "exclamationmark.circle").font(.title3)
                                                .foregroundColor(.orange)
                                        }
                                        
                                        Text("\(areaWithCount.problemsCount)").foregroundColor(Color(.systemGray))
                                        
                                        Image(systemName: "chevron.right").foregroundColor(Color(.systemGray))
                                        
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
//                .padding(.horizontal)
                .padding(.bottom)
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
