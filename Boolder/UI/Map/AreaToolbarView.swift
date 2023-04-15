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
    @Binding var appTab: ContentView.Tab
    
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
                                
                            Image(systemName: "info.circle")
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
                        AreaView(area: mapState.selectedArea!, mapState: mapState, appTab: $appTab, linkToMap: false)
                    }
                }

            }
            .padding(.horizontal)
            
            HStack {
                if(circuits.count > 0) {
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
                            .modify {
                                if #available(iOS 16, *) {
                                    $0.presentationDetents([.medium]).presentationDragIndicator(.hidden) // TODO: use heights?
                                }
                                else {
                                    $0
                                }
                            }
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
                                .modify {
                                    if #available(iOS 16, *) {
                                        $0.presentationDetents([.medium]).presentationDragIndicator(.hidden) // TODO: use heights?
                                    }
                                    else {
                                        $0
                                    }
                                }
                        }
                
                Button {
                    mapState.filters.popular.toggle()
                    mapState.filtersRefresh() // TODO: simplify refresh logic
                } label: {
                    HStack {
                        Image(systemName: "heart")
//                        Text("Populaire")
                    }
                    .font(.callout.weight(.regular))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundColor(mapState.filters.popular ? Color(UIColor.systemBackground) : .primary)
                    .background(mapState.filters.popular ? Color.appGreen : Color(UIColor.systemBackground))
                    .cornerRadius(32)
                }
                
                Button {
                    mapState.filters.favorite.toggle()
                    mapState.filtersRefresh() // TODO: simplify refresh logic
                } label: {
                    HStack {
                        Image(systemName: "star")
//                        Text("Projet")
                    }
                    .font(.callout.weight(.regular))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundColor(mapState.filters.favorite ? Color(UIColor.systemBackground) : .primary)
                    .background(mapState.filters.favorite ? Color.appGreen : Color(UIColor.systemBackground))
                    .cornerRadius(32)
                }
                
                Spacer()

            }
            .padding(.top, 8)
            .padding(.horizontal)
            .opacity(mapState.presentProblemDetails ? 0 : 1)
            
            Spacer()
        }
    }
    
    var circuitFilterActive : Bool {
        mapState.selectedCircuit != nil && circuitBelongsToArea
    }
    
    var filtersActive : Bool {
        mapState.filters.filtersCount() > 0 || circuitFilterActive
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
