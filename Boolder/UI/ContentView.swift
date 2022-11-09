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
    @State private var selectedProblem: Problem = Problem.empty // TODO: use nil instead
    @State private var presentProblemDetails = false
    @State private var presentSearch = false
    @State private var centerOnCurrentLocationCount = 0 // to be able to trigger a map refresh anytime we want
    @State private var centerOnProblem: Problem? = nil
    @State private var centerOnProblemCount = 0 // to be able to trigger a map refresh anytime we want
    @State private var centerOnArea: Area? = nil
    @State private var centerOnAreaCount = 0 // to be able to trigger a map refresh anytime we want
    @State private var selectedPoi: Poi? = nil
    @State private var presentPoiActionSheet = false
    @State private var presentFilters = false
    @State var filters: Filters = Filters()
    @State private var filtersRefreshCount = 0
    
    @State private var tabSelection = 1
    
    // TODO: move somewhere else
    static let algoliaController = AlgoliaController()

    var body: some View {
        TabView(selection: $tabSelection) {
            
            ZStack {
                MapboxView(
                    selectedProblem: $selectedProblem,
                    presentProblemDetails: $presentProblemDetails,
                    centerOnProblem: $centerOnProblem,
                    centerOnProblemCount: $centerOnProblemCount,
                    centerOnArea: $centerOnArea,
                    centerOnAreaCount: $centerOnAreaCount,
                    centerOnCurrentLocationCount: $centerOnCurrentLocationCount,
                    selectedPoi: $selectedPoi,
                    presentPoiActionSheet: $presentPoiActionSheet,
                    filters: $filters,
                    refreshFiltersCount: $filtersRefreshCount
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
                
//                VStack {
//                    Spacer()
//                    HStack(spacing: 16) {
//                        Button(action: {
//                            applyFilters.toggle()
//                        }) {
//                            HStack {
//                                Image(systemName: "slider.horizontal.3")
//
//                                Text("Filtres")
//                                    .fixedSize(horizontal: true, vertical: true)
//                            }
//                            .padding(.vertical, 12)
//                        }
//                    }
//
//                    .accentColor(.primary)
//                    .padding(.horizontal, 16)
//                    .background(Color.systemBackground)
//                    .cornerRadius(10)
//                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.25))
//                    .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
//                    .padding(.bottom)
////                    .padding()
//                }
//                .zIndex(10)
                
                HStack {
                    Spacer()
                    
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            centerOnCurrentLocationCount += 1
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
//                                .offset(x: -1, y: 0)
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
                            presentFilters = true
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .padding(12)
                            // .offset(x: -1, y: 0)
                        }
                        .accentColor(filters.filtersCount() >= 1 ? .systemBackground : .primary)
                        .background(filters.filtersCount() >= 1 ? Color.appGreen : .systemBackground)
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
            // temporary hack to make multi sheets work on iOS14
            .background(
                EmptyView()
                    .sheet(isPresented: $presentSearch) {
                        NavigationView {
                            SearchView(
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
            )
            // temporary hack to make multi sheets work on iOS14
            .background(
                EmptyView()
                    .sheet(isPresented: $presentFilters, onDismiss: {
                        filtersRefreshCount += 1
                    }) {
                        FiltersView(presentFilters: $presentFilters, filters: $filters)
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

            
            DiscoverView(tabSelection: $tabSelection, centerOnArea: $centerOnArea, centerOnAreaCount: $centerOnAreaCount)
                .tabItem {
                    Label("tabs.discover", systemImage: "sparkles")
                }
                .tag(2)
        }
        
        
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
