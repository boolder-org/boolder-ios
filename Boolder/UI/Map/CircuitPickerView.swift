//
//  CircuitPickerView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/12/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct CircuitPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let area: Area
    let mapState: MapState
    
    @State private var circuits = [Circuit]()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(circuits) { circuit in
                        Button {
                            presentationMode.wrappedValue.dismiss()
                            mapState.clearFilters()
                            mapState.selectAndCenterOnCircuit(circuit)
                            mapState.displayCircuitStartButton = true
                            //                        viewModel.mapState.selectAndPresentAndCenterOnProblem(problem)
                        } label: {
                            HStack {
                                CircleView(number: "", color: circuit.color.uicolor, height: 20)
                                Text(circuit.color.longName)
                                Spacer()
                                Text(circuit.averageGrade.string)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                
            }
            .onAppear {
                circuits = area.circuits
            }
            .navigationTitle("Circuits")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    mapState.unselectCircuit()
                    mapState.clearFilters()
                }) {
                    Text("Effacer")
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
