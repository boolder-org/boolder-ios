//
//  ContentView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedProblem: Problem = Problem() // FIXME: use nil as default
    @State private var presentProblemDetails = false
    @State private var areaResourcesDownloaded = false
    
    var body: some View {
        TabView {
            MapboxView(selectedProblem: $selectedProblem, presentProblemDetails: $presentProblemDetails)
                .edgesIgnoringSafeArea(.top)
                .sheet(isPresented: $presentProblemDetails) {
                    ProblemDetailsView(
                        problem: $selectedProblem,
                        areaResourcesDownloaded: $areaResourcesDownloaded
                    )
                }
                .tabItem {
                    Label("Carte", systemImage: "map")
                }
            
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "list.dash")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
