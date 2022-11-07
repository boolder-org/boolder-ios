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
    @State private var centerOnArea: AreaItem? = nil
    @State private var centerOnAreaCount = 0 // to be able to trigger a map refresh anytime we want
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
                    centerOnArea: $centerOnArea,
                    centerOnAreaCount: $centerOnAreaCount,
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
                    HStack(spacing: 16) {
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
                    }
                    
                    .accentColor(.primary)
                    .padding(.horizontal, 16)
                    .background(Color.systemBackground)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.25))
                    .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                    .padding(.bottom)
//                    .padding()
                }
                .zIndex(10)
                
                HStack {
                    Spacer()
                    
                    VStack {
                        Spacer()
                        
                        Button(action: {
//                            centerOnCurrentLocationCount += 1
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
                    }
                }
                .padding(.bottom)
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
                        centerOnArea: $centerOnArea,
                        centerOnAreaCount: $centerOnAreaCount,
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
                        $0.presentationDetents([.medium]).presentationDragIndicator(.hidden) // TODO: use heights?
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
