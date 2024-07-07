//
//  ContentView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @StateObject var appState = AppState()
    
    var body: some View {
        TabView(selection: $appState.tab) {
            
            MapContainerView()
                .tabItem {
                    Label("tabs.map", systemImage: "map")
                }
                .tag(AppState.Tab.map)
            
            DiscoverView()
                .tabItem {
                    Label("tabs.discover", systemImage: "sparkles")
                }
                .tag(AppState.Tab.discover)
            
            TickList()
                .tabItem {
                    Label("tabs.ticklist", systemImage: "bookmark")
                }
                .tag(AppState.Tab.ticklist)
            
            ContributeView()
                .tabItem {
                    Label("tabs.contribute", systemImage: "person.2")
                }
                .tag(AppState.Tab.contribute)
        }
        .environmentObject(appState)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
