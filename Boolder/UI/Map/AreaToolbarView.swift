//
//  AreaToolbarView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/12/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct AreaToolbarView: View {
    @Environment(MapState.self) private var mapState: MapState
    
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: []) var favorites: FetchedResults<Favorite>
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    @State private var presentSearch = false
    @State private var presentAllFilters = false
    @State private var showingAlertFavorite = false
    @State private var showingAlertTicked = false
    
    var body: some View {
        @Bindable var mapState = mapState

        return VStack {
            HStack(spacing: 12) {
                Button {
                    mapState.presentProblemDetails = false
                    presentSearch = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .adaptiveCircleButtonIcon()
                }
                .adaptiveCircleButtonStyle()
                .sheet(isPresented: $presentSearch) {
                    SearchSheetView()
                }
                
                Button {
                    if(mapState.presentProblemDetails) {
                        mapState.presentProblemDetails = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // to avoid a weird race condition
                            mapState.presentAreaView = true
                        }
                    }
                    else {
                        mapState.presentAreaView = true
                    }
                } label: {
                    HStack {
                        Text(mapState.selectedArea?.name ?? "")
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.head)
                        
                        if let area = mapState.selectedArea {
                            if let _ = area.warningFr, let _ = area.warningEn {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.yellow)
                            }
                            
                            Image(systemName: "info.circle")
                        }
                    }
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                }
                .modify {
                    if #available(iOS 26, *) {
                        $0.glassEffect()
                    }
                    else {
                        $0
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color(.secondaryLabel).opacity(0.5), radius: 5)
                    }
                }
                .sheet(isPresented: $mapState.presentAreaView) {
                    NavigationView {
                        AreaView(area: mapState.selectedArea!, linkToMap: false)
                    }
                }
                
                Button {
                    mapState.presentProblemDetails = false
                    presentAllFilters = true
                } label: {
                    Image(systemName: filtersActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .adaptiveCircleButtonIcon()
                }
                .adaptiveCircleButtonStyle()
                .sheet(isPresented: $presentAllFilters, onDismiss: {
                    mapState.filtersRefresh()
                }) {
                    AllFiltersView()
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.hidden)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 8) {
                    Spacer()
                    
                    // `mapState.selectedArea == nil` is a hack to avoid losing position in the horizontal filters scrollview when zooming in and out
                    if(circuits.count > 0 || mapState.selectedArea == nil) {
                        Button {
                            mapState.presentCircuitPicker = true
                            mapState.clearFilters()
                        } label: {
                            HStack {
                                Image("circuit")
                                Text(circuitFilterActive ? mapState.selectedCircuit!.color.shortName : "Circuits")
                            }
                            .filterLabelStyle(isActive: circuitFilterActive)
                        }
                        .filterButtonStyle(isActive: circuitFilterActive)
                        .sheet(isPresented: $mapState.presentCircuitPicker, onDismiss: {
                            
                        }) {
                            CircuitPickerView(area: mapState.selectedArea!)
                                .presentationDetents([.medium]).presentationDragIndicator(.hidden) // TODO: use heights?
                        }
                    }
                    
                    Button {
                        mapState.presentFilters = true
                        mapState.unselectCircuit()
                    } label: {
                        HStack {
                            Image(systemName: "chart.bar")
                            Text(mapState.filters.gradeRange?.description ?? NSLocalizedString("filters.levels", comment: ""))
                        }
                        .filterLabelStyle(isActive: mapState.filters.gradeRange != nil)
                    }
                    .filterButtonStyle(isActive: mapState.filters.gradeRange != nil)
                    .sheet(isPresented: $mapState.presentFilters, onDismiss: {
                        mapState.filtersRefresh() // TODO: simplify refresh logic
                    }) {
                        FiltersView(presentFilters: $mapState.presentFilters, filters: $mapState.filters)
                            .presentationDetents([.medium]).presentationDragIndicator(.hidden) // TODO: use heights?
                    }
                    
                    Button {
                        let previous = mapState.filters.popular
                        mapState.clearFilters()
                        mapState.unselectCircuit()
                        mapState.filters.popular = !previous
                        mapState.filtersRefresh()
                    } label: {
                        HStack {
                            Image(systemName: "heart")
                            Text("filters.popular")
                        }
                        .filterLabelStyle(isActive: mapState.filters.popular)
                    }
                    .filterButtonStyle(isActive: mapState.filters.popular)
                    
                    Button {
                        if(favorites.isEmpty) {
                            if mapState.filters.favorite {
                                mapState.filters.favorite = false
                                mapState.filtersRefresh()
                            }
                            else {
                                showingAlertFavorite = true
                            }
                        }
                        else {
                            let previous = mapState.filters.favorite
                            mapState.clearFilters()
                            mapState.unselectCircuit()
                            mapState.filters.favorite = !previous
                            mapState.filtersRefresh()
                        }
                        
                    } label: {
                        HStack {
                            Image(systemName: "star")
                            Text("filters.favorite")
                        }
                        .filterLabelStyle(isActive: mapState.filters.favorite)
                    }
                    .filterButtonStyle(isActive: mapState.filters.favorite)
                    .alert(isPresented: $showingAlertFavorite) {
                        Alert(title: Text("filters.no_favorites_alert.title"), message: Text("filters.no_favorites_alert.message"), dismissButton: .default(Text("OK")))
                    }
                    
                    Button {
                        if(ticks.isEmpty) {
                            if mapState.filters.ticked {
                                mapState.filters.ticked = false
                                mapState.filtersRefresh()
                            }
                            else {
                                showingAlertTicked = true
                            }
                        }
                        else {
                            let previous = mapState.filters.ticked
                            mapState.clearFilters()
                            mapState.unselectCircuit()
                            mapState.filters.ticked = !previous
                            mapState.filtersRefresh()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("filters.ticked")
                        }
                        .filterLabelStyle(isActive: mapState.filters.ticked)
                    }
                    .filterButtonStyle(isActive: mapState.filters.ticked)
                    .alert(isPresented: $showingAlertTicked) {
                        Alert(title: Text("filters.no_ticks_alert.title"), message: Text("filters.no_ticks_alert.message"), dismissButton: .default(Text("OK")))
                    }
                    
                    Spacer()
                }

            }
            .scrollClipDisabled()
            .padding(.top, 8)
            .opacity(mapState.presentProblemDetails || filtersActive ? 0 : 1)
            
            Spacer()
        }
    }
    
    var circuitFilterActive : Bool {
        mapState.selectedCircuit != nil && circuitBelongsToArea
    }
    
    var filtersActive : Bool {
        mapState.filters.filtersCount > 0 || circuitFilterActive
    }
    
    var circuitBelongsToArea : Bool {
        guard let area = mapState.selectedArea else { return false }
        
        if let circuit = mapState.selectedCircuit {
            return area.circuits.contains(where: { $0.id == circuit.id })
        }
        
        return false
    }
    
    var circuits : [Circuit] {
        guard let area = mapState.selectedArea else { return [] }
        
        return area.circuits
    }
}

private extension View {
    func filterLabelStyle(isActive: Bool) -> some View {
        self
            .font(.callout.weight(.regular))
            .modify {
                if #available(iOS 26, *) {
                    $0
                }
                else {
                    $0
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundColor(isActive ? Color(UIColor.systemBackground) : .primary)
                        .background(isActive ? Color.appGreen : Color(UIColor.systemBackground))
                        .cornerRadius(32)
                }
            }
    }
    
    func filterButtonStyle(isActive: Bool) -> some View {
        self.modify {
            if #available(iOS 26, *) {
                if isActive {
                    $0.buttonStyle(.glassProminent)
                }
                else {
                    $0.buttonStyle(.glass)
                }
            }
            else {
                $0
            }
        }
    }
}
