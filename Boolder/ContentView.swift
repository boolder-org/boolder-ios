//
//  ContentView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var areaDataSource = ProblemDataSource(circuitFilter: .red, filters: Filters())
    @State private var showList = false
    @State private var selectedProblem: ProblemAnnotation? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                ProblemListView(areaDataSource: self.areaDataSource, selectedProblem: $selectedProblem)
                .zIndex(showList ? 1 : 0)
                
                MapView(areaDataSource: self.areaDataSource, selectedProblem: $selectedProblem)
                    .edgesIgnoringSafeArea(.bottom)
                    .zIndex(showList ? 0 : 1)
                
                VStack {
                    Spacer()
                    FabFiltersView()
                        .padding(.bottom, 24)
                }
                .zIndex(10)
                
            }
            .navigationBarTitle("Rocher Canon", displayMode: .inline)
            .navigationBarItems(leading:
            Button("Test") {
                self.selectedProblem = nil
                self.areaDataSource = ProblemDataSource(circuitFilter: .yellow, filters: Filters())
            },
            trailing:
                Button(showList ? "Carte" : "Liste") {
                    self.showList.toggle()
                }
            )
        }
        .accentColor(Color.green)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
