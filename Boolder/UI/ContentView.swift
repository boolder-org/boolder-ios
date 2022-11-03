//
//  ContentView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var odrManager: ODRManager
    @EnvironmentObject var dataStore: DataStore
    let offlineModeActivated = UserDefaults.standard.bool(forKey: "OfflineModeActivated") // FIXME: react to change of value?
    
    @State private var selectedProblem: Problem = Problem() // FIXME: use nil as default
    @State private var presentProblemDetails = false
    @State private var applyFilters = false
    
    static let algoliaController = AlgoliaController()
    
    // FIXME: move somewhere
    private var allAreasTags: Set<String> {
        // FIXME: don't use dataStore
        let array = dataStore.areas.filter { $0.published }.map{ "area-\($0.id)" }
        return Set(array)
    }
    
    var body: some View {
        TabView {
            
            ZStack {
                MapboxView(selectedProblem: $selectedProblem, presentProblemDetails: $presentProblemDetails, applyFilters: $applyFilters)
                    .edgesIgnoringSafeArea(.top)
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
            // FIXME: make code DRY
            .onAppear {
                if offlineModeActivated {
                    odrManager.requestResources(tags: allAreasTags, onSuccess: {
                        print("done")
                    }, onFailure: { error in
                        print("On-demand resource error")
                        
                        // FIXME: implement UI, log errors
                        switch error.code {
                        case NSBundleOnDemandResourceOutOfSpaceError:
                            print("You don't have enough space available to download this resource.")
                        case NSBundleOnDemandResourceExceededMaximumSizeError:
                            print("The bundle resource was too big.")
                        case NSBundleOnDemandResourceInvalidTagError:
                            print("The requested tag does not exist.")
                        default:
                            print(error.description)
                        }
                    })
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
//            
//            NavigationView {
//                AlgoliaView(searchBoxController: ContentView.algoliaController.searchBoxController,
//                            hitsController: ContentView.algoliaController.hitsController)
//            }
////            .onAppear {
////                ContentView.algoliaController.searcher.search()
////                }
//            .tabItem {
//                Label("Search", systemImage: "magnifyingglass")
//            }
            
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
        }
        
        
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
