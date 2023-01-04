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
    
    struct Level: Identifiable {
        var name: String
        var count: Int
        var id = UUID()
    }

    @State private var data: [Level] = [
        .init(name: "1", count: 0),
        .init(name: "2", count: 0),
        .init(name: "3", count: 0),
        .init(name: "4", count: 0),
        .init(name: "5", count: 0),
        .init(name: "6", count: 0),
        .init(name: "7", count: 0),
        .init(name: "8", count: 0),
    ]
    
    var body: some View {
        ZStack {
            List {
                Section {
                    
                    if NSLocale.websiteLocale == "fr", let descriptionFr = area.descriptionFr {
                        Text(descriptionFr)
                    }
                    else if let descriptionEn = area.descriptionEn {
                        Text(descriptionEn)
                    }
                    
                    if let url = area.parkingUrl, let name = area.parkingShortName, let distance = area.parkingDistance {
                        
                        NavigationLink {
                            List {
                                HStack {
                                    Text("Parking")
                                    Spacer()
                                    Image(systemName: "p.square.fill")
                                        .foregroundColor(Color(UIColor(red: 0.16, green: 0.37, blue: 0.66, alpha: 1.00)))
                                        .font(.title2)
                                    Text(name)
                                    
                                    //                                Image(systemName: "arrow.up.forward.square").foregroundColor(Color.gray)
                                }
                                HStack {
                                    Text("Marche d'approche")
                                    Spacer()
                                    Text("\(Int(round(Double(distance/80)))) min")
                                }
                            }
                            .navigationTitle(Text("Accès"))
                        } label: {
                            Text("Accès")
                        }
                        
                        
                        
                    }
                }
                
                Section {
                    NavigationLink {
                        AreaProblemsView(area: area, mapState: mapState, appTab: $appTab)
                    } label: {
                        HStack {
                            Text("Voies")
                            Spacer()
                            Text("\(problemsCount)")
                        }
                    }
                    
                    VStack {
                        Button {
                            showChart.toggle()
                        } label: {
                            HStack {
                                Text("Niveaux")
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
                                            x: .value("Level", shape.name),
                                            y: .value("Problems", shape.count)
                                        )
                                    }
                                }
                                .chartYScale(domain: 0...150)
                                .foregroundColor(.levelGreen)
                                .frame(height: 200)
                                .padding(.horizontal)
                                .padding(.vertical)
                                .clipShape(Rectangle())
                            }
                        }
                    }
                }
                
                if(circuits.count > 0) {
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
                                            .foregroundColor(.red)
                                            .font(.title3)
                                    }
                                    Text(circuit.averageGrade.string)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                    }
                }
                
                if(popularProblems.count > 0) {
                    
                    Section(header:
                                //                        HStack {
                            //                Image(systemName: "heart.fill").foregroundColor(.pink)
                            Text("Populaires")
                            //            }
                    ) {
                        
                        ForEach(popularProblems) { problem in
                            Button {
                                //                        presentationMode.wrappedValue.dismiss()
                                mapState.presentAreaView = false
                                appTab = .map
                                mapState.selectAndPresentAndCenterOnProblem(problem)
                            } label: {
                                HStack {
                                    ProblemCircleView(problem: problem)
                                    Text(problem.nameWithFallback)
                                    Spacer()
                                    //                                if(problem.featured) {
                                    //                                    Image(systemName: "heart.fill").foregroundColor(.pink)
                                    //                                }
                                    Text(problem.grade.string)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                        
                    }
                    
                    //                Section {
                    //                    NavigationLink {
                    //                        AreaProblemsView(viewModel: viewModel, appTab: $appTab)
                    //                    } label: {
                    //                        HStack {
                    //                            Text("Toutes les voies")
                    //                            Spacer()
                    //                            Text("\(viewModel.problemsCount)")
                    //                        }
                    //                    }
                    //                }
                }
                
                if(linkToMap) {
                    // leave room for sticky footer
                    Section(header: Text("")) {
                        EmptyView()
                    }
                    .padding(.bottom, 40)
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
                        Text("Voir sur la carte")
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
                        Text("Fermer")
                            .padding(.vertical)
                            .font(.body)
                    }
                )
            }
        }
        
    }
    
}

//struct AreaView_Previews: PreviewProvider {
//    static var previews: some View {
//        AreaView(viewModel: AreaViewModel(areaId: 1))
//    }
//}
