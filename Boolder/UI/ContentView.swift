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
            
            
            // TODO: remove after June 2023 (?)
            ClimbingBusView()
                .tabItem {
                    Label("Bus", systemImage: "bus")
                }
                .tag(AppState.Tab.bus)
                .modify {
                    if #available(iOS 15, *) {
                        if(!appState.badgeClimbingBusWasSeen) {
                            $0.badge("new")
                        }
                        else {
                            $0
                        }
                    }
                    else {
                        $0
                    }
                }
            
            TickList()
                .tabItem {
                    Label("tabs.ticklist", systemImage: "bookmark")
                }
                .tag(AppState.Tab.ticklist)
        }
        .environmentObject(appState)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
