//
//  ContentView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MapboxView()
                .edgesIgnoringSafeArea(.top)
                .tabItem {
                    Label("Carte", systemImage: "map")
                }
            
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "list.dash")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
