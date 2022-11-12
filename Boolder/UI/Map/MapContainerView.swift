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
    @ObservedObject var mapState: MapState
    @State private var isEditing: Bool = false
    
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
            
            SearchView(mapState: mapState, isEditing: $isEditing)
            
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
            .zIndex(10)
            .opacity(isEditing ? 0 : 1)
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
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
