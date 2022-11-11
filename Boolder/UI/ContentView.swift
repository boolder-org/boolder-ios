//
//  ContentView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var mapState = MapState()
    @State private var presentSearch = false
    @State private var tabSelection = Tab.map
    
    var body: some View {
        TabView(selection: $tabSelection) {
            
            ZStack {
                MapboxView(mapState: mapState)
                    .edgesIgnoringSafeArea(.top)
                    .background(
                        PoiActionSheet(
                            name: (mapState.selectedPoi?.name ?? ""),
                            location: (mapState.selectedPoi?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)),
                            googleUrl: URL(string: mapState.selectedPoi?.googleUrl ?? ""),
                            navigationMode: false,
                            presentPoiActionSheet: $mapState.presentPoiActionSheet
                        )
                    )
                
                HStack {
                    Spacer()
                    
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            mapState.centerOnCurrentLocation()
                        }) {
                            Image(systemName: "location")
                                .padding(12)
                                .offset(x: -1, y: 0)
                        }
                        .accentColor(.primary)
                        .background(Color.systemBackground)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.gray, lineWidth: 0.25)
                        )
                        .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                        .padding(.horizontal)
                        
                        Button(action: {
                            presentSearch = true
                        }) {
                            Image(systemName: "magnifyingglass")
                                .padding(12)
                        }
                        .accentColor(.primary)
                        .background(Color.systemBackground)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.gray, lineWidth: 0.25)
                        )
                        .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                        .padding(.horizontal)
                        
                        Button(action: {
                            mapState.presentFilters = true
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .padding(12)
                        }
                        .accentColor(mapState.filters.filtersCount() >= 1 ? .systemBackground : .primary)
                        .background(mapState.filters.filtersCount() >= 1 ? Color.appGreen : .systemBackground)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.gray, lineWidth: 0.25)
                        )
                        .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                        .padding(.horizontal)
                        
                    }
                }
                .padding(.bottom)
                .zIndex(10)
            }
            .sheet(isPresented: $mapState.presentProblemDetails) {
                ProblemDetailsView(
                    problem: $mapState.selectedProblem,
                    mapState: mapState
                )
                .modify {
                    if #available(iOS 16, *) {
                        $0.presentationDetents([.medium]).presentationDragIndicator(.hidden) // TODO: use heights?
                    }
                    else {
                        $0
                    }
                }
            }
            // temporary hack to make multi sheets work on iOS14
            .background(
                EmptyView()
                    .sheet(isPresented: $presentSearch) {
                        SearchView(mapState: mapState)
                    }
            )
            // temporary hack to make multi sheets work on iOS14
            .background(
                EmptyView()
                    .sheet(isPresented: $mapState.presentFilters, onDismiss: {
                        mapState.filtersRefresh()
                        // TODO: update $mapState.filters only on dismiss
                    }) {
                        FiltersView(presentFilters: $mapState.presentFilters, filters: $mapState.filters)
                            .modify {
                                if #available(iOS 16, *) {
                                    $0.presentationDetents([.medium]).presentationDragIndicator(.hidden) // TODO: use heights?
                                }
                                else {
                                    $0
                                }
                            }
                    }
            )
            .tabItem {
                Label("tabs.map", systemImage: "map")
            }
            .tag(Tab.map)
            
            DiscoverView(tabSelection: $tabSelection, mapState: mapState)
                .tabItem {
                    Label("tabs.discover", systemImage: "sparkles")
                }
                .tag(Tab.discover)
            
            TickList(tabSelection: $tabSelection, mapState: mapState)
                .tabItem {
                    Label("Mes voies", systemImage: "bookmark")
                }
                .tag(Tab.saved)
        }
    }
    
    enum Tab {
        case map
        case discover
        case saved
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
