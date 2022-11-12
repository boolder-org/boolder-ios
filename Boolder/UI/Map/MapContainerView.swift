//
//  MapView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 12/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreLocation

struct MapContainerView: View {
    @EnvironmentObject var odrManager: ODRManager
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject var mapState: MapState
    
    var body: some View {
        ZStack {
            MapboxView(mapState: mapState)
                .edgesIgnoringSafeArea(.top)
                .ignoresSafeArea(.keyboard)
                .background(
                    PoiActionSheet(
                        name: (mapState.selectedPoi?.name ?? ""),
                        location: (mapState.selectedPoi?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)),
                        googleUrl: URL(string: mapState.selectedPoi?.googleUrl ?? ""),
                        navigationMode: false,
                        presentPoiActionSheet: $mapState.presentPoiActionSheet
                    )
                )
                .sheet(isPresented: $mapState.presentProblemDetails) {
                    ProblemDetailsView(
                        problem: $mapState.selectedProblem,
                        mapState: mapState
                    )
                    // FIXME: there is a bug with SwiftUI not passing environment correctly to modal views (only on iOS14?)
                    // remove these lines as soon as it's fixed
                    .environment(\.managedObjectContext, managedObjectContext)
                    .environmentObject(odrManager)
                    .modify {
                        if #available(iOS 16, *) {
                            $0.presentationDetents([.medium]).presentationDragIndicator(.hidden) // TODO: use heights?
                        }
                        else {
                            $0
                        }
                    }
                }
            
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
                        Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
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
                        Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
                    )
                    .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                    .padding(.horizontal)
                    
                }
            }
            .padding(.bottom)
            .ignoresSafeArea(.keyboard)
            .zIndex(10)
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
            
            SearchView(mapState: mapState)
                .zIndex(20)
        }
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
