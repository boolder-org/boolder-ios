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
    @State private var appTab = Tab.map
    
    var body: some View {
        TabView(selection: $appTab) {
            
            MapContainerView(appTab: $appTab)
                .tabItem {
                    Label("tabs.map", systemImage: "map")
                }
                .tag(Tab.map)
            
//            DiscoverView(appTab: $appTab, mapState: mapState)
//                .tabItem {
//                    Label("tabs.discover", systemImage: "sparkles")
//                }
//                .tag(Tab.discover)
            
            TickList(appTab: $appTab)
                .tabItem {
                    Label("tabs.ticklist", systemImage: "bookmark")
                }
                .tag(Tab.ticklist)
        }
        .environmentObject(appState)
    }
    
    enum Tab {
        case map
        case discover
        case ticklist
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
