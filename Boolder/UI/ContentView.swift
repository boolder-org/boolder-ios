//
//  ContentView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreLocation
//import ImageViewer

struct ContentView: View {
    @StateObject private var appState = AppState()
    
    // TODO: move somewhere else
    static let algoliaController = AlgoliaController()
    
    var body: some View {
        TabView(selection: $appState.tabSelection) {
            
            ZStack {
                MapboxView(appState: appState)
                .edgesIgnoringSafeArea(.top)
                .background(
                    PoiActionSheet(
                        name: (appState.selectedPoi?.name ?? ""),
                        location: (appState.selectedPoi?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)),
                        googleUrl: URL(string: appState.selectedPoi?.googleUrl ?? ""),
                        navigationMode: false,
                        presentPoiActionSheet: $appState.presentPoiActionSheet
                    )
                )
                
                HStack {
                    Spacer()
                    
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            appState.centerOnCurrentLocationCount += 1
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
                            appState.presentSearch = true
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
                            appState.presentFilters = true
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .padding(12)
                        }
                        .accentColor(appState.filters.filtersCount() >= 1 ? .systemBackground : .primary)
                        .background(appState.filters.filtersCount() >= 1 ? Color.appGreen : .systemBackground)
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
            .sheet(isPresented: $appState.presentProblemDetails) {
                ProblemDetailsView(
                    problem: $appState.selectedProblem
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
                    .sheet(isPresented: $appState.presentSearch) {
                        NavigationView {
                            SearchView(
                                searchBoxController: ContentView.algoliaController.searchBoxController,
                                problemHitsController: ContentView.algoliaController.problemHitsController,
                                areaHitsController: ContentView.algoliaController.areaHitsController,
                                appState: appState
                            )
                        }
                        .onAppear() {
                            ContentView.algoliaController.searcher.search()
                        }
                    }
            )
            // temporary hack to make multi sheets work on iOS14
            .background(
                EmptyView()
                    .sheet(isPresented: $appState.presentFilters, onDismiss: {
                        appState.filtersRefreshCount += 1
                    }) {
                        FiltersView(presentFilters: $appState.presentFilters, filters: $appState.filters)
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
            .tag(1)
            
            DiscoverView(tabSelection: $appState.tabSelection, centerOnArea: $appState.centerOnArea, centerOnAreaCount: $appState.centerOnAreaCount)
                .tabItem {
                    Label("tabs.discover", systemImage: "sparkles")
                }
                .tag(2)
        }
//        .overlay(ImageViewer(image: $appState.image, viewerShown: $appState.showImageViewer))
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
