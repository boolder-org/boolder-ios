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
                        mapState.selectedArea = nil
                        mapState.presentProblemDetails = false
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(Font.body.weight(.semibold))
                            .foregroundColor(Color(.secondaryLabel))
                            .padding(.horizontal, 16)
                        //                        .disabled(true)
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
                    
//                    Button(action: {
//                        mapState.presentFilters = true
//                    }) {
//                        Image(systemName: "slider.vertical.3")
//                            .padding(4)
//                    }
//                    .accentColor(filtersActive ? .systemBackground : Color.appGreen)
//                    .background(filtersActive ? Color.appGreen : .systemBackground)
//                    .cornerRadius(4)
//                    .padding(.horizontal)
//                    .sheet(isPresented: $mapState.presentFilters, onDismiss: {
//                        mapState.filtersRefresh()
//                        // TODO: update $mapState.filters only on dismiss
//                    }) {
//                        FiltersView(presentFilters: $mapState.presentFilters, filters: $mapState.filters, viewModel: AreaViewModel(area: mapState.selectedArea!, mapState: mapState))
//                            .modify {
//                                if #available(iOS 16, *) {
//                                    $0.presentationDetents([.medium]).presentationDragIndicator(.hidden) // TODO: use heights?
//                                }
//                                else {
//                                    $0
//                                }
//                            }
//                    }
                    

                    Button {

                    } label: {
                        Image(systemName: "chevron.left")
                            .font(Font.body.weight(.semibold))
                            .foregroundColor(Color(.secondaryLabel))
                            .padding(.horizontal, 16)
                            .opacity(0)
                        //                        .disabled(true)
                    }
                    
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
            
//            if let circuit = mapState.selectedCircuit {
//                HStack {
//                    Button {
//                        mapState.unselectCircuit()
//                    } label: {
//                        Label(circuit.color.shortName, systemImage: "xmark")
//                    }
//
//                    Button {
//                        mapState.goToNextCircuitProblem()
//                    } label: {
//                        Label("Suivant", systemImage: "chevron.right")
//                    }
//                    .padding(.horizontal)
//
//                }
//                .padding(.horizontal)
//            }
            
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
                        Text(mapState.filters.gradeRange?.description ?? "Niveaux")
                    }
                    .font(.callout.weight(.regular))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundColor(mapState.filters.gradeRange != nil ? Color(UIColor.systemBackground) : .primary)
                    .background(mapState.filters.gradeRange != nil ? Color.appGreen : Color(UIColor.systemBackground))
                    .cornerRadius(32)
                }
                        .sheet(isPresented: $mapState.presentFilters, onDismiss: {
                            mapState.filtersRefresh() // FIXME: simplify refresh logic
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
    
//    var circuitsWithIndex : [Circuit] {
//        Array(zip(circuits.indices, circuits))
//    }
}

//struct AreaToolbarView_Previews: PreviewProvider {
//    static var previews: some View {
//        AreaToolbarView()
//    }
//}
