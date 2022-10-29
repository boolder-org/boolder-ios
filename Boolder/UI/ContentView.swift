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
    @State private var applyFilters = false
    
    var body: some View {
        TabView {
            ZStack {
                MapboxView(selectedProblem: $selectedProblem, presentProblemDetails: $presentProblemDetails, applyFilters: $applyFilters)
                VStack {
                    Spacer()
                    Button(action: {
                        applyFilters.toggle()
//                        print("button")
//                        print(applyFilters)
                    }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")

                            Text("Filtres")
                                .fixedSize(horizontal: true, vertical: true)
                        }
                        .padding(.vertical, 12)
                    }
                        .padding(.bottom, 24)
                }
                .zIndex(10)
            }
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
