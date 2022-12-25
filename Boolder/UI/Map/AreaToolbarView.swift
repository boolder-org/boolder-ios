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
    
    @State private var presentAreaView = false
    
    var body: some View {
        VStack {
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
                
                Text(mapState.selectedArea?.name ?? "")
                    .lineLimit(1)
                    .truncationMode(.head)
//                    .frame(maxWidth: 400)
                    .padding(.vertical, 10)
//                    .padding(.horizontal, 25)
                    .onTapGesture {
                        mapState.presentProblemDetails = false
                        presentAreaView = true
                    }
//                    .background(Color.red)
                
                Button {
                    mapState.presentProblemDetails = false
                    presentAreaView = true
                } label: {
                    Image(systemName: "info.circle")
//                        .background(Color.red)
//                        .foregroundColor(.green)
//                        .padding(.leading, 10)
//                        .disabled(true)
                }
                
                Spacer()
                
                // quick hack to be able to center the text
                Image(systemName: "chevron.left")
                    .font(Font.body.weight(.semibold))
                    .foregroundColor(Color(.secondaryLabel))
                    .padding(.horizontal, 16)
                    .opacity(0)
                
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color(.secondaryLabel).opacity(0.5), radius: 5)
            .padding(.horizontal)
            .padding(.top, 8)
            .sheet(isPresented: $presentAreaView) {
                NavigationView {
                    AreaView(viewModel: AreaViewModel(area: mapState.selectedArea!, mapState: mapState))
                }
            }
            
            HStack {
                
                Button(action: {
                    mapState.presentFilters = true
                }) {
                    
                    Label("Niveau", systemImage: "chevron.down")
                }
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
                
                // TODO: hide if there is no circuit in the selected area
                
                Button(action: {
                    mapState.presentProblemDetails = false
                    mapState.presentCircuitPicker = true
                    
                }) {
                    HStack {
                        Label("Circuit", systemImage: "chevron.down")
//                        if let circuit = mapState.selectedCircuit, circuitBelongsToArea {
//                            CircleView(number: "", color: circuit.color.uicolor, height: 16)
//                        }
                    }
                }
                .sheet(isPresented: $mapState.presentCircuitPicker, onDismiss: {
                    
                }) {
                    CircuitPickerView(viewModel: AreaViewModel(area: mapState.selectedArea!, mapState: mapState))
                        .modify {
                            if #available(iOS 16, *) {
                                $0.presentationDetents([.medium]).presentationDragIndicator(.hidden) // TODO: use heights?
                            }
                            else {
                                $0
                            }
                        }
                }
                
//                if mapState.selectedCircuit != nil {
//                    Button {
//                        mapState.goToNextCircuitProblem()
//                    } label: {
//                        Text("suivant")
//                    }
//                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            
            Spacer()
        }
    }
    
    var circuitBelongsToArea : Bool {
        guard let area = mapState.selectedArea else { return false }
        
        let areaViewModel = AreaViewModel(area: area, mapState: mapState)
        
        if let circuit = mapState.selectedCircuit {
            return areaViewModel.circuits.contains(where: { $0.id == circuit.id })
        }
        
        return false
    }
}

//struct AreaToolbarView_Previews: PreviewProvider {
//    static var previews: some View {
//        AreaToolbarView()
//    }
//}
