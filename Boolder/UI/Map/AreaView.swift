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
    @Binding var appTab: ContentView.Tab
    
    var body: some View {
        List {
            Section {
                if NSLocale.websiteLocale == "fr", let descriptionFr = viewModel.area.descriptionFr {
                    Text(descriptionFr)
                }
                else if let descriptionEn = viewModel.area.descriptionEn {
                    Text(descriptionEn)
                }
                
                if let url = viewModel.area.parkingUrl, let name = viewModel.area.parkingShortName, let distance = viewModel.area.parkingDistance {
                    
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
                HStack {
                    Text("Niveaux")
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        ForEach(1..<8) { level in
                            Text(String(level))
                            //                            .padding(10)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.systemBackground)
                                .background(viewModel.area.levels[level]! ? Color.appGreen : Color.gray.opacity(0.5))
                            
                            //                            .aspectRatio(1, contentMode: .fill)
                                .cornerRadius(4)
//                                .padding(.horizontal, 1)
                        }
                    }
                }
                
                NavigationLink {
                    AreaProblemsView(viewModel: viewModel, appTab: $appTab)
                } label: {
                    HStack {
                        Text("Voies")
                        Spacer()
                        Text("\(viewModel.problemsCount)")
                    }
                }
            }
            Section {
                ForEach(viewModel.circuits) { circuit in
                    NavigationLink {
                        CircuitView(circuit: circuit, mapState: viewModel.mapState, appTab: $appTab)
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
        .navigationTitle(viewModel.area.name)
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
