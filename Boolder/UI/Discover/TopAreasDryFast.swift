//
//  TopAreasDryFast.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 14/02/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopAreasDryFast: View {
    @Environment(\.openURL) var openURL
    
    @Binding var tabSelection: Int
    @Binding var centerOnArea: Area?
    @Binding var centerOnAreaCount: Int
    
    let gray = Color(red: 107/255, green: 114/255, blue: 128/255)
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    VStack(alignment: .leading, spacing: 32) {
                        
                        Text("top_areas.dry_fast.description")
                            .font(.body)
                            .foregroundColor(gray)
                        
                        LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())], spacing: 8) {
                            
                            ForEach(areas) { area in
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
                    .padding(.vertical, 8)
                    
                    HStack(alignment: .top) {
                        Image(systemName: "exclamationmark.triangle.fill").font(.body)
                        Text("top_areas.dry_fast.warning").font(.body)
                        Spacer()
                    }
                    .foregroundColor(Color.orange.opacity(0.8))
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
                    
                    HStack(alignment: .top, spacing: 4) {
                        Text("top_areas.dry_fast.useful_link")
                            .foregroundColor(gray)
                        
                        Button(action: {
                            openURL(URL(string: "https://www.facebook.com/people/Bleau-Meteo/100055389702633/")!)
                        }) {
                            Text("Bleau Météo")
                                .foregroundColor(Color.appGreen)
                        }
                    }
                    
                }
                .padding(.horizontal)
                .padding(.top)
            }
        }
        .navigationTitle("top_areas.dry_fast.title")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    var areas: [Area] {
        [16, 10, 2, 15, 7].map{Area.loadArea(id: $0)!}.sorted {
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }
    }
}

//struct TopAreasDryFast_Previews: PreviewProvider {
//    static var previews: some View {
//        TopAreasDryFast()
//    }
//}
