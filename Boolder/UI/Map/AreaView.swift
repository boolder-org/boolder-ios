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
    let mapState: MapState
    @Binding var appTab: ContentView.Tab
    let linkToMap: Bool
    
    @State private var circuits = [Circuit]()
    @State private var problemsCount = 0
    @State private var popularProblems = [Problem]()
    @State private var showChart = false
    @State private var data: [Level] = []
    
    // TODO: refactor
    struct Level: Identifiable {
        var name: String
        var count: Int
        var id = UUID()
    }
    
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
                                mapState.presentAreaView = false
                                appTab = .map
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
                        mapState.selectArea(area)
                        mapState.centerOnArea(area)
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

        }
        .onAppear {
            circuits = area.circuits
            problemsCount = area.problemsCount
            popularProblems = area.popularProblems
            
            data = area.levelsCount
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
                AreaDetailsView(area: area, mapState: mapState, appTab: $appTab, linkToMap: linkToMap)
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
                AreaProblemsView(area: area, mapState: mapState, appTab: $appTab)
            } label: {
                HStack {
                    Text("area.problems")
                    Spacer()
                    Text("\(problemsCount)")
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
                        
                        HStack(spacing: 2) {
                            ForEach(area.levelsCount) { level in
                                Text(String(level.name))
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.systemBackground)
                                    .background(level.count >= 20 ? Color.levelGreen : Color.gray.opacity(0.5))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }

                if showChart {
                    if #available(iOS 16.0, *) {
                        Chart {
                            ForEach(data) { shape in
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
                    CircuitView(area: area, circuit: circuit, mapState: mapState, appTab: $appTab)
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
}

//struct AreaView_Previews: PreviewProvider {
//    static var previews: some View {
//        AreaView(viewModel: AreaViewModel(areaId: 1))
//    }
//}
