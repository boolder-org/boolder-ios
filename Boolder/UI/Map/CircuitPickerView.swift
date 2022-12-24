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
    
    let viewModel: AreaViewModel
    
    var body: some View {
        List {
            Section {
                ForEach(viewModel.circuits) { circuit in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        viewModel.mapState.selectAndCenterOnCircuit(circuit)
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
        .navigationTitle(viewModel.area.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Fermer")
                    .padding(.vertical)
                    .font(.body)
            }
        )
    }
}

//struct CircuitPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        CircuitPickerView()
//    }
//}
