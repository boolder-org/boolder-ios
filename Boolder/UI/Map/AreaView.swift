//
//  AreaView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/12/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI


struct AreaView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let viewModel: AreaViewModel
    
    var body: some View {
        List {
            Section {
                ForEach(viewModel.circuits) { circuit in
                    NavigationLink {
                        CircuitView(circuit: circuit, mapState: viewModel.mapState)
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
            
            Section {
                ForEach(viewModel.problems) { problem in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        viewModel.mapState.selectAndPresentAndCenterOnProblem(problem)
                    } label: {
                        HStack {
                            ProblemCircleView(problem: problem)
                            Text(problem.nameWithFallback)
                            Spacer()
                            Text(problem.grade.string)
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

//struct AreaView_Previews: PreviewProvider {
//    static var previews: some View {
//        AreaView(viewModel: AreaViewModel(areaId: 1))
//    }
//}
