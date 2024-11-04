//
//  AreaToolbarView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/12/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct AreaToolbarView: View {
    @ObservedObject var mapState: MapState
    
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: []) var favorites: FetchedResults<Favorite>
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    @State private var showingAlertFavorite = false
    @State private var showingAlertTicked = false
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Button {
                        mapState.unselectArea()
                        mapState.presentProblemDetails = false
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(Font.body.weight(.semibold))
                            .foregroundColor(Color(.secondaryLabel))
                            .padding(.horizontal, 16)
                    }
                    
                    Spacer()
                    
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
                    }
                    
                    Spacer()
                    
                    Color.white.opacity(0)
                        .frame(height: 20)
                        .frame(maxWidth: 40)
                        .layoutPriority(-1)
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color(.secondaryLabel).opacity(0.5), radius: 5)
                .padding(.top, 8)
                .sheet(isPresented: $mapState.presentAreaView) {
                    NavigationView {
                        AreaView(area: mapState.selectedArea!, linkToMap: false)
                    }
                }

            }
            .padding(.horizontal)
            
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
                            .font(.callout.weight(.regular))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundColor(circuitFilterActive ? Color(UIColor.systemBackground) : .primary)
                            .background(circuitFilterActive ? Color.appGreen : Color(UIColor.systemBackground))
                            .cornerRadius(32)
                        }
                        .sheet(isPresented: $mapState.presentCircuitPicker, onDismiss: {
                            
                        }) {
                            CircuitPickerView(area: mapState.selectedArea!, mapState: mapState)
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
                        .font(.callout.weight(.regular))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundColor(mapState.filters.gradeRange != nil ? Color(UIColor.systemBackground) : .primary)
                        .background(mapState.filters.gradeRange != nil ? Color.appGreen : Color(UIColor.systemBackground))
                        .cornerRadius(32)
                    }
                    .sheet(isPresented: $mapState.presentFilters, onDismiss: {
                        mapState.filtersRefresh() // TODO: simplify refresh logic
                    }) {
                        FiltersView(presentFilters: $mapState.presentFilters, filters: $mapState.filters, mapState: mapState)
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
                        .font(.callout.weight(.regular))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundColor(mapState.filters.popular ? Color(UIColor.systemBackground) : .primary)
                        .background(mapState.filters.popular ? Color.appGreen : Color(UIColor.systemBackground))
                        .cornerRadius(32)
                    }
                    
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
                        .font(.callout.weight(.regular))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundColor(mapState.filters.favorite ? Color(UIColor.systemBackground) : .primary)
                        .background(mapState.filters.favorite ? Color.appGreen : Color(UIColor.systemBackground))
                        .cornerRadius(32)
                    }
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
                        .font(.callout.weight(.regular))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundColor(mapState.filters.ticked ? Color(UIColor.systemBackground) : .primary)
                        .background(mapState.filters.ticked ? Color.appGreen : Color(UIColor.systemBackground))
                        .cornerRadius(32)
                    }
                    .alert(isPresented: $showingAlertTicked) {
                        Alert(title: Text("filters.no_ticks_alert.title"), message: Text("filters.no_ticks_alert.message"), dismissButton: .default(Text("OK")))
                    }
                    
                    Spacer()
                }

            }
            .padding(.top, 8)
            .opacity(mapState.presentProblemDetails ? 0 : 1)
            
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

//struct AreaToolbarView_Previews: PreviewProvider {
//    static var previews: some View {
//        AreaToolbarView()
//    }
//}
