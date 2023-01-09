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
    
    @State private var trainStations = [Poi]()
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading) {
                    
                    ForEach(trainStations) { trainStation in
                       HStack {
                            Text(trainStation.name)
                                .font(.title2).bold()
                            
                            Spacer()
                            
                            Button(action: {
                                openURL(URL(string: "https://www.horaires-de-trains.fr/horaires-Paris_Gare_de_Lyon-Bois_le_Roi.html")!)
                            }) {
                                Image(systemName: "ellipsis.circle")
                                    .foregroundColor(Color.appGreen)
                            }
                        }
                       .padding(.horizontal)
                        
                        VStack {
                            
                            Divider()
                            
                            ForEach(trainStation.poiRoutes.filter{$0.transport == .bike}) { poiRoute in
                                if let area = Area.load(id: poiRoute.areaId) {
                                    NavigationLink {
                                        AreaView(area: area, mapState: mapState, appTab: $appTab, linkToMap: true)
                                    } label: {
                                        HStack {
                                            
                                            Text(area.name)
                                            
                                            Spacer()
                                            
//                                            Image(systemName: "bicycle")
                                            Text("\(poiRoute.distanceInMinutes) min")
                                            
                                            Image(systemName: "chevron.right")
                                        }
                                        .foregroundColor(.primary)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal)
                                    }

                                    Divider().padding(.leading)
                                }
                            }
                            
                        }
                        .padding(.bottom, 24)
                    }
                }
                .padding(.vertical)
            }
            .onAppear {
                trainStations = Poi.all.filter{$0.type == .trainStation}.filter{$0.poiRoutes.count > 0}
            }
        }
        .navigationTitle("top_areas.train.title")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

//struct TopAreasTrain_Previews: PreviewProvider {
//    static var previews: some View {
//        TopAreasTrain()
//    }
//}
