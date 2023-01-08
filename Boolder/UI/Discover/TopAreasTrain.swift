//
//  TopAreasTrain.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 14/02/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopAreasTrain: View {
    @Environment(\.openURL) var openURL
    
    @Binding var appTab: ContentView.Tab
    let mapState: MapState
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Gare de Bois-le-Roi")
                                .font(.title2).bold()
//                                .padding(.bottom, 2)
                            
                            Text("Secteurs à moins de 20 min en vélo :")
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
                                    
                                    ForEach(areasFromBoisLeRoi) { area in
                                        NavigationLink {
                                            AreaView(area: area, mapState: mapState, appTab: $appTab, linkToMap: true)
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
                        
                        VStack(alignment: .leading) {
                            
                            HStack(alignment: .top, spacing: 4) {
                                Button(action: {
                                    openURL(URL(string: "https://www.horaires-de-trains.fr/horaires-Paris_Gare_de_Lyon-Bois_le_Roi.html")!)
                                }) {
                                    Text("Horaires depuis Paris Gare de Lyon")
                                        .foregroundColor(Color.appGreen)
                                }
                            }
//                            .padding(.vertical)
                        }
                        .padding(.horizontal)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.vertical, 8)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Gare Fontainebleau Avon")
                                .font(.title2).bold()
//                                .padding(.bottom, 2)
                            
                            Text("Secteurs à moins de 20 min en vélo :")
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
                                    
                                    ForEach(areasFromAvon) { area in
                                        NavigationLink {
                                            AreaView(area: area, mapState: mapState, appTab: $appTab, linkToMap: true)
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
                        
                        VStack(alignment: .leading) {
                            
                            HStack(alignment: .top, spacing: 4) {
                                Button(action: {
                                    openURL(URL(string: "https://www.horaires-de-trains.fr/horaires-Paris_Gare_de_Lyon-Fontainebleau_Avon.html")!)
                                }) {
                                    Text("Horaires depuis Paris Gare de Lyon")
                                        .foregroundColor(Color.appGreen)
                                }
                            }
//                            .padding(.vertical)
                        }
                        .padding(.horizontal)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.vertical, 8)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Gare Montigny-sur-Loing")
                                .font(.title2).bold()
//                                .padding(.bottom, 2)
                            
                            Text("Secteurs à moins de 20 min en vélo :")
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
                                    
                                    ForEach(areasFromMontigny) { area in
                                        NavigationLink {
                                            AreaView(area: area, mapState: mapState, appTab: $appTab, linkToMap: true)
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
                        
                        VStack(alignment: .leading) {
                            
                            HStack(alignment: .top, spacing: 4) {
                                Button(action: {
                                    openURL(URL(string: "https://www.horaires-de-trains.fr/horaires-Paris_Gare_de_Lyon-Montigny_Sur_Loing.html")!)
                                }) {
                                    Text("Horaires depuis Paris Gare de Lyon")
                                        .foregroundColor(Color.appGreen)
                                }
                            }
//                            .padding(.vertical)
                        }
                        .padding(.horizontal)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.vertical, 8)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Gare de Nemours Saint Pierre")
                                .font(.title2).bold()
//                                .padding(.bottom, 2)
                            
                            Text("Secteurs à moins de 10 min en vélo :")
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
                                    
                                    ForEach(areasFromNemours) { area in
                                        NavigationLink {
                                            AreaView(area: area, mapState: mapState, appTab: $appTab, linkToMap: true)
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
                        
                        VStack(alignment: .leading) {
                            
                            HStack(alignment: .top, spacing: 4) {
                                Button(action: {
                                    openURL(URL(string: "https://www.horaires-de-trains.fr/horaires-Paris_Gare_de_Lyon-Nemours_Saint_Pierre.html")!)
                                }) {
                                    Text("Horaires depuis Paris Gare de Lyon")
                                        .foregroundColor(Color.appGreen)
                                }
                            }
//                            .padding(.vertical)
                        }
                        .padding(.horizontal)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.vertical, 8)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Gare de Malesherbes")
                                .font(.title2).bold()
//                                .padding(.bottom, 2)
                            
                            Text("Secteurs à moins de 20 min en vélo :")
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
                                    
                                    ForEach(areasFromMalesherbes) { area in
                                        NavigationLink {
                                            AreaView(area: area, mapState: mapState, appTab: $appTab, linkToMap: true)
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
                        
                        VStack(alignment: .leading) {
                            
                            HStack(alignment: .top, spacing: 4) {
                                Button(action: {
                                    openURL(URL(string: "https://www.horaires-de-trains.fr/horaires-Paris_Gare_de_Lyon-Malesherbes.html")!)
                                }) {
                                    Text("Horaires depuis Paris Gare de Lyon")
                                        .foregroundColor(Color.appGreen)
                                }
                            }
//                            .padding(.vertical)
                        }
                        .padding(.horizontal)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.vertical, 8)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("top_areas.train.title")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    var areasFromBoisLeRoi: [Area] {
        [1,24].map{Area.load(id: $0)}.compactMap{$0}
    }
    
    var areasFromAvon: [Area] {
        [50,53,33,52].map{Area.load(id: $0)}.compactMap{$0}
    }
    
    var areasFromMontigny: [Area] {
        [51,68].map{Area.load(id: $0)}.compactMap{$0}
    }
    
    var areasFromNemours: [Area] {
        [32].map{Area.load(id: $0)}.compactMap{$0}
    }
    
    var areasFromMalesherbes: [Area] {
        [23].map{Area.load(id: $0)}.compactMap{$0}
    }
}

//struct TopAreasTrain_Previews: PreviewProvider {
//    static var previews: some View {
//        TopAreasTrain()
//    }
//}
