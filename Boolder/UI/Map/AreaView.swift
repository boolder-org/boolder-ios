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
                Text("Bas Cuvier est un secteur mythique, parmi les plus connus de Fontainebleau. La réception téléphonique est très mauvaise dans tout le secteur, pensez à télécharger le topo en mode hors-ligne. Février 2022 : la peinture du circuit orange est presque complètement effacée.")
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
                    AreaProblemsView(viewModel: viewModel)
                } label: {
                    HStack {
                        Text("\(viewModel.problemsCount) voies")
                    }
                }
            }
            Section {
                ForEach(viewModel.circuits) { circuit in
                    NavigationLink {
                        CircuitView(circuit: circuit, mapState: viewModel.mapState)
                    } label: {
                        HStack {
                            CircleView(number: "", color: circuit.color.uicolor, height: 20)
                            Text(circuit.color.longName)
                            Spacer()
                            if(circuit.beginnerFriendly) {
                                Image(systemName: "face.smiling").foregroundColor(.green)
                            }
                            if(circuit.dangerous) {
                                Image(systemName: "exclamationmark.triangle").foregroundColor(.red)
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
