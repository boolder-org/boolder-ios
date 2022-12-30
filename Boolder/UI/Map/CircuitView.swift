//
//  CircuitView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 30/12/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct CircuitView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let circuit: Circuit
    let mapState: MapState
    
    var body: some View {
        List(circuit.problems) { problem in
            Button {
//                presentationMode.wrappedValue.dismiss()
                mapState.presentAreaView = false
                mapState.selectAndPresentAndCenterOnProblem(problem)
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
        .navigationTitle(Text(circuit.color.longName))
    }
}

//struct CircuitView_Previews: PreviewProvider {
//    static var previews: some View {
//        CircuitView()
//    }
//}
