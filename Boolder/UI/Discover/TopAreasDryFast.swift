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
    
    @Environment(AppState.self) private var appState: AppState

    @State private var areas = [Area]()
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    VStack(alignment: .leading, spacing: 32) {
                        
                        VStack {
                            Text("top_areas.dry_fast.description")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading) {
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top, spacing: 0) {
                                    
                                    Color.white.opacity(0)
                                        .frame(width: 0, height: 1)
                                        .padding(.leading, 8)
                                    
                                    ForEach(areas) { area in
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
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.vertical, 8)
                    
                    VStack(alignment: .leading) {
                        
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
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                openURL(URL(string: "https://www.facebook.com/people/Bleau-Meteo/100055389702633/")!)
                            }) {
                                Text("Bleau Météo")
                                    .foregroundColor(Color.appGreen)
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                }
                .padding(.top)
            }
            .task {
                areas = Area.all.filter{$0.dryFast}
            }
        }
        .navigationTitle("top_areas.dry_fast.title")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

//struct TopAreasDryFast_Previews: PreviewProvider {
//    static var previews: some View {
//        TopAreasDryFast()
//    }
//}
