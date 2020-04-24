//
//  ContentView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let areaDataSource = ProblemDataSource(circuitFilter: .red, filters: Filters())
    @State private var showList = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if showList {
                    List {
                        ForEach(areaDataSource.annotations, id: \.id) { (problem: ProblemAnnotation) in
                            HStack {
                                Text(problem.displayLabel)
                                    .font(.headline)
                                    .foregroundColor(Color(problem.displayColor()))
                                    .frame(minWidth: 30, alignment: .leading)
                                Text(problem.name ?? "-")
                                Spacer()
                                Text(problem.grade?.string ?? "-")
                            }
                        }
                    }
                }
                else {
                    Text("carte")
                }
            }
            .navigationBarTitle("Rocher Canon", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(showList ? "Carte" : "Liste") {
                    self.showList.toggle()
                }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
