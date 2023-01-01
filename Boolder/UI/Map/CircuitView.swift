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
    @Binding var appTab: ContentView.Tab
    
    var body: some View {
        List {
            if(circuit.beginnerFriendly || circuit.dangerous) {
                Section {
                    if(circuit.beginnerFriendly) {
                        HStack {
                            Image(systemName: "face.smiling").font(.title3)
                            Text("Ce circuit convient aux débutants")
                        }
                        .foregroundColor(.green)
                    }
                    if(circuit.dangerous) {
                        HStack {
                            Image(systemName: "exclamationmark.circle").font(.title3)
                            Text("Ce circuit est dangereux")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            
            
            Section {
                ForEach(circuit.problems) { problem in
                    Button {
                        //                presentationMode.wrappedValue.dismiss()
                        mapState.presentAreaView = false
                        appTab = .map
                        mapState.selectAndPresentAndCenterOnProblem(problem)
                    } label: {
                        HStack {
                            ProblemCircleView(problem: problem)
                            Text(problem.nameWithFallback)
                            Spacer()
                            if(problem.featured) {
                                Image(systemName: "heart.fill").foregroundColor(.pink)
                            }
                            Text(problem.grade.string)
                        }
                        .foregroundColor(.primary)
                    }
                }
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
