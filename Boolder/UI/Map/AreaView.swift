//
//  AreaView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/12/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import Charts

struct AreaView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let area: Area
    @EnvironmentObject var appState: AppState
    let linkToMap: Bool
    
    @State private var circuits = [Circuit]()
    @State private var popularProblems = [Problem]()
    @State private var showChart = false
    @State private var chartData: [Level] = []
    
    var body: some View {
        ZStack {
            List {
                infos
                
                problems
                
                if(circuits.count > 0) {
                    circuitsList
                }
                
                if(popularProblems.count > 0) {
                    
                    Section(header: Text("area.problems.popular")) {
                        ForEach(popularProblems) { problem in
                            Button {
                                appState.selectedProblem = problem
                                appState.tab = .map
                            } label: {
                                HStack {
                                    ProblemCircleView(problem: problem)
                                    Text(problem.localizedName)
                                    Spacer()
                                    Text(problem.grade.string)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                        
                    }
                }
                
                if(linkToMap) {
                    // leave room for sticky footer
                    Section(header: Text("")) {
                        EmptyView()
                    }
                    .padding(.bottom, 24)
                }
            }
            
            if(linkToMap) {
                VStack {
                    Spacer()
                    
                    Button {
                        appState.selectedArea = area
                        appState.tab = .map
                    } label: {
                        Text("area.see_on_the_map")
                            .font(.body.weight(.semibold))
                            .padding(.vertical)
                    }
                    .buttonStyle(LargeButton())
                    .padding()
                }
            }

        }
        .onAppear {
            circuits = area.circuits
            popularProblems = area.popularProblems
            
            chartData = [
                .init(name: "1", count: min(150, area.level1Count)),
                .init(name: "2", count: min(150, area.level2Count)),
                .init(name: "3", count: min(150, area.level3Count)),
                .init(name: "4", count: min(150, area.level4Count)),
                .init(name: "5", count: min(150, area.level5Count)),
                .init(name: "6", count: min(150, area.level6Count)),
                .init(name: "7", count: min(150, area.level7Count)),
                .init(name: "8", count: min(150, area.level8Count)),
            ]
        }
        .navigationTitle(area.name)
        .navigationBarTitleDisplayMode(.inline)
        .modify {
            if(linkToMap) {
                $0
            }
            else {
                $0.navigationBarItems(
                    leading: Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("area.close")
                            .padding(.vertical)
                            .font(.body)
                    }
                )
            }
        }
        
    }
    
    var infos: some View {
        Section {
            NavigationLink {
                AreaDetailsView(area: area, linkToMap: linkToMap)
            } label: {
                HStack {
                    Text("area.infos")
                    Spacer()
                    
                    if area.warningEn != nil {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.orange)
                            .font(.title3)
                    }
                }
            }
        }
    }
    
    var problems: some View {
        Section {
            NavigationLink {
                AreaProblemsView(area: area)
            } label: {
                HStack {
                    Text("area.problems")
                    Spacer()
                    Text("\(area.problemsCount)")
                }
            }
            
            VStack {
                Button {
                    showChart.toggle()
                } label: {
                    HStack {
                        Text("area.levels")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        AreaLevelsBarView(area: area)
                    }
                }

                if showChart {
                    if #available(iOS 16.0, *) {
                        Chart {
                            ForEach(chartData) { shape in
                                BarMark(
                                    x: .value("area.chart.level", shape.name),
                                    y: .value("area.chart.problems", shape.count)
                                )
                            }
                        }
                        .chartYScale(domain: 0...150)
                        .foregroundColor(.levelGreen)
                        .frame(height: 150)
                        .padding(.vertical)
                        .clipShape(Rectangle())
                    }
                }
            }
        }
    }
    
    var circuitsList: some View {
        Section {
            ForEach(circuits) { circuit in
                NavigationLink {
                    CircuitView(area: area, circuit: circuit)
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
    
    struct Level: Identifiable {
        var name: String
        var count: Int
        var id = UUID()
    }
}

//struct AreaView_Previews: PreviewProvider {
//    static var previews: some View {
//        AreaView(viewModel: AreaViewModel(areaId: 1))
//    }
//}
