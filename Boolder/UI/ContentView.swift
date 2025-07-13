//
//  ContentView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var appState = AppState()
    
    var body: some View {
        TabView(selection: $appState.tab) {
            
            Tab("tabs.map", systemImage: "map", value: .map) {
                MapContainerView()
            }
            
            Tab("tabs.discover", systemImage: "sparkles", value: .discover) {
                DiscoverView()
            }
            
            Tab("tabs.ticklist", systemImage: "bookmark", value: .ticklist) {
                TickList()
            }
            
            Tab("Search", systemImage: "magnifyingglass", value: .search, role: .search) {
                EmptyView()
            }
                
        }
        .environment(appState)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
