//
//  AreaView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct AreaView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showList = false
    @State private var selectedProblem: ProblemAnnotation? = nil
    @State private var presentProblemDetails = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ProblemListView(selectedProblem: $selectedProblem, presentProblemDetails: $presentProblemDetails)
                .zIndex(showList ? 1 : 0)
                
                MapView(selectedProblem: $selectedProblem, presentProblemDetails: $presentProblemDetails)
                    .edgesIgnoringSafeArea(.bottom)
                    .zIndex(showList ? 0 : 1)
                    .sheet(isPresented: $presentProblemDetails) {
                        ProblemDetailsView(problem: self.selectedProblem ?? ProblemAnnotation())
                    }
                
                VStack {
                    Spacer()
                    FabFiltersView()
                        .padding(.bottom, 24)
                }
                .zIndex(10)
                
//                NavigationLink(destination: ProblemDetailsView(problem: self.selectedProblem ?? ProblemAnnotation()), isActive: $presentProblemDetails) { EmptyView() }
                
            }
            .navigationBarTitle("Rocher Canon", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(showList ? "Carte" : "Liste") {
                    self.showList.toggle()
                }
            )
        }
        .accentColor(Color.green)
    }
}

struct AreaView_Previews: PreviewProvider {
    static var previews: some View {
        AreaView()
            .environmentObject(DataStore())
    }
}
