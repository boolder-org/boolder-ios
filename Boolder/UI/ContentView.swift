//
//  ContentView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import Turbo

let baseURL = URL(string: "https://turbo-native-demo.glitch.me/")!

let mapViewController = UIHostingController(rootView: MapContainerView())
let discoverViewController = UIHostingController(rootView: DiscoverView())
let ticklistViewController = UIHostingController(rootView: TickList())

struct ContentView: View {
    @StateObject var appState = AppState()
    private let navigator = TurboNavigator()
    
    var body: some View {
            TabBarController(viewControllers: [mapViewController, discoverViewController, ticklistViewController, navigator.rootViewController], selectedTab: $appState.selectedTab)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    mapViewController.tabBarItem = UITabBarItem(title: "Carte", image: UIImage(systemName: "map"), tag: 0)
                    discoverViewController.tabBarItem = UITabBarItem(title: "Découvrir", image: UIImage(systemName: "sparkles"), tag: 1)
                    ticklistViewController.tabBarItem = UITabBarItem(title: "Mes voies", image: UIImage(systemName: "bookmark"), tag: 2)
                    navigator.rootViewController.tabBarItem = UITabBarItem(title: "Contribuer", image: UIImage(systemName: "person.2"), tag: 3)
                    
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = UIColor.systemBackground
                    navigator.rootViewController.navigationBar.standardAppearance = appearance
                    if #available(iOS 15.0, *) {
                        navigator.rootViewController.navigationBar.scrollEdgeAppearance = appearance
                    }
                    
                    navigator.rootViewController.tabBarItem.title = "Coucou"
                    navigator.rootViewController.navigationItem.title = "Coucou2"
                    
                    
//                    appState.selectedTab = 1
                    
                    navigator.route(baseURL)
                }
                .environmentObject(appState)
        }
    
    
//    var body: some View {
//        TabView(selection: $appState.tab) {
//            
//            MapContainerView()
//                .tabItem {
//                    Label("tabs.map", systemImage: "map")
//                }
//                .tag(AppState.Tab.map)
//            
//            DiscoverView()
//                .tabItem {
//                    Label("tabs.discover", systemImage: "sparkles")
//                }
//                .tag(AppState.Tab.discover)
//            
//            TickList()
//                .tabItem {
//                    Label("tabs.ticklist", systemImage: "bookmark")
//                }
//                .tag(AppState.Tab.ticklist)
//            
//            // TODO: remove (when?)
//            ContributeView()
//                .tabItem {
//                    Label("tabs.contribute", systemImage: "person.2")
//                }
//                .tag(AppState.Tab.contribute)
//                .modify {
//                    if #available(iOS 15, *) {
//                        if(!appState.badgeContributeWasSeen) {
//                            $0.badge("new")
//                        }
//                        else {
//                            $0
//                        }
//                    }
//                    else {
//                        $0
//                    }
//                }
//        }
//        .environmentObject(appState)
//    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
