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
    @State private var presentSearch = false
    @State private var applyFilters = false
    
    var body: some View {
        TabView {
            
            ZStack {
                MapboxView(selectedProblem: $selectedProblem, presentProblemDetails: $presentProblemDetails, applyFilters: $applyFilters)
                    .edgesIgnoringSafeArea(.top)
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            applyFilters.toggle()
                        }) {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                
                                Text("Filtres")
                                    .fixedSize(horizontal: true, vertical: true)
                            }
                            .padding(.vertical, 12)
                        }
                        Button(action: {
                            presentSearch = true
                        }) {
                            HStack {
//                                Image(systemName: "slider.horizontal.3")
                                
                                Text("Search")
                                    .fixedSize(horizontal: true, vertical: true)
                            }
                            .padding(.vertical, 12)
                        }
                    }
                    .padding(.bottom, 24)
                }
                .zIndex(10)
            }
            .sheet(isPresented: $presentSearch) {
                NavigationView {
                    SearchView()
                }
                
            }
            .sheet(isPresented: $presentProblemDetails) {
                ProblemDetailsView(
                    problem: $selectedProblem
                )
                .modify {
                    if #available(iOS 16, *) {
                        $0.presentationDetents([.medium, .large]).presentationDragIndicator(.hidden) // TODO: use heights?
                    }
                    else {
                        $0
                    }
                }
                
            }
            .tabItem {
                Label("Carte", systemImage: "map")
            }

            
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
        }
        
        
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
