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
    
    let area: Area
    let mapState: MapState
    @Binding var appTab: ContentView.Tab
    
    @State private var circuits = [Circuit]()
    @State private var problemsCount = 0
    @State private var popularProblems = [Problem]()
    
    var body: some View {
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
                
                HStack {
                    Text("Niveaux")
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        ForEach(1..<8) { level in
                            Text(String(level))
                                .frame(width: 20, height: 20)
                                .foregroundColor(.systemBackground)
                                .background(area.levels[level]! ? Color(UIColor(red: 5/255, green: 150/255, blue: 105/255, alpha: 0.8)) : Color.gray.opacity(0.5))
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            if(circuits.count > 0) {
                Section {
                    ForEach(circuits) { circuit in
                        NavigationLink {
                            CircuitView(circuit: circuit, mapState: mapState, appTab: $appTab)
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
                                if(problem.featured) {
                                    Image(systemName: "heart.fill").foregroundColor(.pink)
                                }
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
        }
        .onAppear {
            circuits = area.circuits
            problemsCount = area.problemsCount
            popularProblems = area.popularProblems
        }
        .navigationTitle(area.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                // FIXME: don't use button when screen is pushed inside a navigationview
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
