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
    
    let area: Area
    let circuit: Circuit
    @EnvironmentObject var appState: AppState
    @Binding var appTab: ContentView.Tab
    
    var body: some View {
        ZStack {
            List {
                if(circuit.beginnerFriendly || circuit.dangerous) {
                    Section {
                        if(circuit.beginnerFriendly) {
                            HStack {
                                Image(systemName: "face.smiling").font(.title3)
                                Text("area.circuit.beginner")
                            }
                            .foregroundColor(.green)
                        }
                        if(circuit.dangerous) {
                            HStack {
                                Image(systemName: "exclamationmark.circle").font(.title3)
                                Text("area.circuit.dangerous")
                            }
                            .foregroundColor(.orange)
                        }
                    }
                }
                
                
                Section {
                    ForEach(circuit.problems) { problem in
                        Button {
                            appTab = .map
                            appState.selectedProblem = problem
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
                
                // leave room for sticky footer
                Section(header: Text("")) {
                    EmptyView()
                }
                .padding(.bottom, 24)
            }
            
            VStack {
                Spacer()
                
                Button {
                    appState.selectedCircuit = AppState.CircuitWithArea(circuit: circuit, area: area)
                    appTab = .map
                } label: {
                    Text("area.see_on_the_map")
                        .font(.body.weight(.semibold))
                        .padding(.vertical)
                }
                .buttonStyle(LargeButton())
                .padding()
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
