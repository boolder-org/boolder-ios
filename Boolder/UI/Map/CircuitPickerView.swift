//
//  CircuitPickerView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/12/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct CircuitPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    let area: Area
    @Environment(MapState.self) private var mapState: MapState
    
    @State private var circuits = [Circuit]()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(circuits) { circuit in
                        Button {
                            dismiss()
                            mapState.clearFilters()
                            mapState.selectAndCenterOnCircuit(circuit)
                            mapState.displayCircuitStartButton = true
                        } label: {
                            HStack {
                                CircleView(number: "", color: circuit.color.uicolor, height: 20)
                                Text(circuit.color.longName)
                                Spacer()
                                if(circuit.beginnerFriendly) {
                                    Image(systemName: "face.smiling")
                                        .foregroundColor(.green)
                                        .font(.title3)
                                }
                                if(circuit.dangerous) {
                                    Image(systemName: "exclamationmark.circle")
                                        .foregroundColor(.orange)
                                        .font(.title3)
                                }
                                Text(circuit.averageGrade.string)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                
            }
            .task {
                circuits = area.circuits
            }
            .navigationTitle("Circuits")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    dismiss()
                    mapState.unselectCircuit()
                    mapState.clearFilters()
                }) {
                    Text("filters.clear")
                        .padding(.vertical)
                        .font(.body)
                }
            )
        }
    }
}

//struct CircuitPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        CircuitPickerView()
//    }
//}
