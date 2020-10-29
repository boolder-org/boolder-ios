//
//  DiscoverView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/10/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct DiscoverView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    
                    VStack(alignment: .leading) {
                        
                        VStack(alignment: .leading) {
//                            Text("On grimpe où ?")
//                                .font(.title2)
//                                .fontWeight(.bold)
//                                .padding(.bottom, 4)
                            
                            Text("Choisissez le secteur qui vous convient parmi notre sélection.")
                                .font(.body)
                            
                        }
                        .foregroundColor(Color.white)
                        
                        
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(16)
                    .padding()
                    
                    
                    VStack(alignment: .leading) {
                        Text("Favoris")
                            .font(.title3).bold()
//                            .padding(.top, 8)
                        
                        Divider()
                        
                        NavigationLink(
                            destination: AreaView(),
                            label: {
                                HStack {
                                    Text("Rocher Canon")
                                        .font(.title3)
                                        .foregroundColor(Color.green)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                }
                                
                            })
                        
                        Divider()
                        
                        NavigationLink(
                            destination: AreaView(),
                            label: {
                                HStack {
                                    Text("Cuvier")
                                        .font(.title3)
                                        .foregroundColor(Color.green)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                }
                            })
                        
                        Divider()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.horizontal)
                    
                    VStack {
                        AreaRowView()
                        AreaRowView()
                            .padding(.bottom, 20)
                    }
    //                .listRowInsets(EdgeInsets())
                }
                .navigationBarTitle(Text("On grimpe où ?"))
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(Color.green)
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
