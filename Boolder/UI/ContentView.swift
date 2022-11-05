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
    @State private var selectedProblem: Problem = Problem() // FIXME: use nil as default
    @State private var presentProblemDetails = false
    @State private var presentSearch = false
    @State private var centerOnCurrentLocationCount = 0 // to be able to trigger a map refresh anytime we want
    @State private var centerOnProblem: Problem? = nil
    @State private var centerOnProblemCount = 0 // to be able to trigger a map refresh anytime we want
    @State private var selectedPoi: Poi? = nil
    @State private var presentPoiActionSheet = false
    @State private var applyFilters = false
    
    // TODO: move somewhere else
    static let algoliaController = AlgoliaController()

    var body: some View {
        TabView {
            
            ZStack {
                MapboxView(
                    selectedProblem: $selectedProblem,
                    presentProblemDetails: $presentProblemDetails,
                    centerOnProblem: $centerOnProblem,
                    centerOnProblemCount: $centerOnProblemCount,
                    selectedPoi: $selectedPoi,
                    presentPoiActionSheet: $presentPoiActionSheet,
                    applyFilters: $applyFilters
                )
                    .edgesIgnoringSafeArea(.top)
                    .background(
                        PoiActionSheet(
                            name: (selectedPoi?.name ?? ""),
                            location: (selectedPoi?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)),
                            googleUrl: URL(string: selectedPoi?.googleUrl ?? ""),
                            navigationMode: false,
                            presentPoiActionSheet: $presentPoiActionSheet
                        )
                    )
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            applyFilters.toggle()
                        }) {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                
                                Text("Filtres")
                                    .fixedSize(horizontal: true, vertical: true)
                            }
                            .padding(.vertical, 12)
                        }
                        Button(action: {
                            presentSearch = true
                        }) {
                            HStack {
//                                Image(systemName: "slider.horizontal.3")
                                
                                Text("Search")
                                    .fixedSize(horizontal: true, vertical: true)
                            }
                            .padding(.vertical, 12)
                        }
                    }
                    .padding(.bottom, 24)
                }
                .zIndex(10)
            }
            .sheet(isPresented: $presentSearch) {
                NavigationView {
                    AlgoliaView(
                        searchBoxController: ContentView.algoliaController.searchBoxController,
                        problemHitsController: ContentView.algoliaController.problemHitsController,
                        areaHitsController:ContentView.algoliaController.areaHitsController,
                        centerOnProblem: $centerOnProblem,
                        centerOnProblemCount: $centerOnProblemCount,
                        selectedProblem: $selectedProblem,
                        presentProblemDetails: $presentProblemDetails
                    )
                }
                .onAppear() {
                    ContentView.algoliaController.searcher.search()
                }
                
            }
            .sheet(isPresented: $presentProblemDetails) {
                ProblemDetailsView(
                    problem: $selectedProblem
                )
                .modify {
                    if #available(iOS 16, *) {
                        $0.presentationDetents([.medium, .large]).presentationDragIndicator(.hidden) // TODO: use heights?
                    }
                    else {
                        $0
                    }
                }
                
            }
            .tabItem {
                Label("Carte", systemImage: "map")
            }

            
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
        }
        
        
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
