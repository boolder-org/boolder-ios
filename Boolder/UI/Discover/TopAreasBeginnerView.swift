//
//  TopAreasBeginnerView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 06/01/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopAreasBeginnerView: View {
    @Environment(AppState.self) private var appState: AppState
    
    @State private var areasForBeginners = [Area]()
    
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
                    
                    ForEach(areasForBeginners) { area in
                        
                        NavigationLink {
                            AreaView(area: area, linkToMap: true)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(area.name)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                
                                HStack {
                                    ForEach(area.circuits.filter{$0.beginnerFriendly}) { circuit in
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
        .task{
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
