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
                
                //                    Text("Secteurs pour les débutants")
                //                        .font(.title2).bold()
                //                        .padding(.top, 16)
                //                        .padding(.bottom, 8)
                //                        .padding(.horizontal)
                
                VStack {
                    Divider() //.padding(.leading)
                    
                    ForEach(areasForBeginners) { areaWithCount in
                        
                        NavigationLink {
                            AreaView(area: areaWithCount.area, mapState: mapState, appTab: $appTab, linkToMap: true)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(areaWithCount.area.name)
                                    //                                                    .font(.body.weight(.semibold))
                                    //                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                    //                                            .background(Color.blue)
                                    
                                }
                                
                                Spacer()
                                
                                //                                    Text("\(areaWithCount.problemsCount)").foregroundColor(Color(.systemGray))
                                //
                                
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
            .padding(.vertical)
        }
        .onAppear{
            areasForBeginners = Area.forBeginners
        }
        
        .navigationTitle("Idéal pour débuter")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct TopAreasBeginnerView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopAreasBeginnerView()
//    }
//}
