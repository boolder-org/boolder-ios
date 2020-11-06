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
                        Text("Favoris")
                            .font(.title3).bold()
                            .padding(.top, 16)
                        
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
