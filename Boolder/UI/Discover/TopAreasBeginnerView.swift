//
//  TopAreasBeginnerView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 06/01/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopAreasBeginnerView: View {
    @Binding var appTab: ContentView.Tab
    let mapState: MapState
    
    @State private var areasForBeginners = [AreaWithCount]()
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading) {
                
                Text("discover.top_areas.level.beginner.intro")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                VStack {
                    Divider()
                    
                    ForEach(areasForBeginners) { areaWithCount in
                        
                        NavigationLink {
                            AreaView(area: areaWithCount.area, mapState: mapState, appTab: $appTab, linkToMap: true)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(areaWithCount.area.name)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                
                                HStack {
                                    ForEach(areaWithCount.area.circuits.filter{$0.beginnerFriendly}) { circuit in
                                        CircleView(number: "", color: circuit.color.uicolor, showStroke: false, height: 16)
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
            .padding(.vertical)
        }
        .onAppear{
            areasForBeginners = Area.forBeginners
        }
        
        .navigationTitle("discover.top_areas.level.beginner_friendly")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct TopAreasBeginnerView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopAreasBeginnerView()
//    }
//}
