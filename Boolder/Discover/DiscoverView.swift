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
            LazyVStack {
                
                VStack(alignment: .leading) {
                    Text("Récents")
                        .font(.title3).bold()
                        .padding(.top, 30)
                    
                    NavigationLink(
                        destination: AreaView(),
                        label: {
                            Text("Rocher Canon")
                                .font(.title3)
                                .foregroundColor(Color.green)
                        })
                    
                    NavigationLink(
                        destination: AreaView(),
                        label: {
                            Text("Cuvier")
                            .font(.title3)
                            .foregroundColor(Color.green)
                        })
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                .padding()
                
                VStack {
                    AreaRowView()
                    AreaRowView()
                        .padding(.bottom, 20)
                }
                .listRowInsets(EdgeInsets())
            }
            .navigationBarTitle(Text("Secteurs"), displayMode: .inline)
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
