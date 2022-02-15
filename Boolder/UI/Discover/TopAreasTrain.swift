//
//  TopAreasTrain.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 14/02/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopAreasTrain: View {
    @EnvironmentObject var dataStore: DataStore
    
    @State var presentArea = false
    let gray = Color(red: 107/255, green: 114/255, blue: 128/255)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                VStack(alignment: .leading) {
                    
                    Divider()
                    
                    NavigationLink(
                        destination: AreaView(),
                        isActive: $presentArea,
                        label: {
                            HStack {
                                Text("Rocher Canon")
                                    .font(.body)
                                    .foregroundColor(Color.appGreen)
                                Text("(15 min)")
                                    .font(.callout)
                                    .foregroundColor(Color(.tertiaryLabel))
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                dataStore.areaId = 1
                                dataStore.filters = Filters()
                                presentArea = true
                            }
                        }
                    )
                    
                    Divider()
                    
                    NavigationLink(
                        destination: AreaView(),
                        isActive: $presentArea,
                        label: {
                            HStack {
                                Text("Rocher Saint Germain")
                                    .font(.body)
                                    .foregroundColor(Color.appGreen)
                                Text("(20 min)")
                                    .font(.callout)
                                    .foregroundColor(Color(.tertiaryLabel))
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                dataStore.areaId = 24
                                dataStore.filters = Filters()
                                presentArea = true
                            }
                        }
                    )
                    
                    Divider()
                    
                    NavigationLink(
                        destination: AreaView(),
                        isActive: $presentArea,
                        label: {
                            HStack {
                                Text("Cuvier")
                                    .font(.body)
                                    .foregroundColor(Color.appGreen)
                                Text("(30 min)")
                                    .font(.callout)
                                    .foregroundColor(Color(.tertiaryLabel))
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                dataStore.areaId = 4
                                dataStore.filters = Filters()
                                presentArea = true
                            }
                        }
                    )
                    
                    Divider()
                    
                    NavigationLink(
                        destination: AreaView(),
                        isActive: $presentArea,
                        label: {
                            HStack {
                                Text("Apremont")
                                    .font(.body)
                                    .foregroundColor(Color.appGreen)
                                Text("(35 min)")
                                    .font(.callout)
                                    .foregroundColor(Color(.tertiaryLabel))
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                dataStore.areaId = 7
                                dataStore.filters = Filters()
                                presentArea = true
                            }
                        }
                    )
                    
                    Divider()
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                .padding(.vertical, 8)
                
                Text("top_areas.train.description")
                    .font(.body)
                    .foregroundColor(gray)
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .navigationTitle("top_areas.train.title")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

struct TopAreasTrain_Previews: PreviewProvider {
    static var previews: some View {
        TopAreasTrain()
    }
}
