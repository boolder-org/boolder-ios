//
//  ContentView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var mapState = MapState()
    @State private var appTab = Tab.map
    
//    @State private var text: String = ""
    @State private var isEditing: Bool = false
    
    static let algoliaController = AlgoliaController()
    @ObservedObject var searchBoxController = Self.algoliaController.searchBoxController
    @ObservedObject var problemHitsController = Self.algoliaController.problemHitsController
    @ObservedObject var areaHitsController = Self.algoliaController.areaHitsController
    @ObservedObject var errorController = Self.algoliaController.errorController
    
    var body: some View {
        TabView(selection: $appTab) {
            
            ZStack {
                MapboxView(mapState: mapState)
                    .edgesIgnoringSafeArea(.top)
                    .ignoresSafeArea(.keyboard)
                    .background(
                        PoiActionSheet(
                            name: (mapState.selectedPoi?.name ?? ""),
                            location: (mapState.selectedPoi?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)),
                            googleUrl: URL(string: mapState.selectedPoi?.googleUrl ?? ""),
                            navigationMode: false,
                            presentPoiActionSheet: $mapState.presentPoiActionSheet
                        )
                    )
             
                Color.systemBackground
                    .edgesIgnoringSafeArea(.top)
                    .opacity(isEditing ? 1 : 0)
                
                VStack {
                    HStack {
                      TextField("search.placeholder", text: $searchBoxController.query, onCommit: {
                          searchBoxController.submit()
                        isEditing = false
                      })
                      .padding(10)
                      .padding(.horizontal, 25)
                      .overlay(
                        HStack {
                          Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(.secondaryLabel))
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 10)
                            .disabled(true)
                          if isEditing && !searchBoxController.query.isEmpty {
                            Button(action: {
                                searchBoxController.query = ""
                                   },
                                   label: {
                                    Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(Color(.secondaryLabel))
                                      .padding(.horizontal, 10)
                                      .padding(.vertical, 4)
                                   })
                          }
                        }
                      )
                      .onTapGesture {
                        isEditing = true
                      }
                      .background(isEditing ? Color("ImageBackground") : Color(.systemBackground))
                      .cornerRadius(12)
//                      .transition(.move(edge: .trailing))
//                      .animation(.default)
                      .shadow(color: Color(.secondaryLabel).opacity(isEditing ? 0 : 0.5), radius: 5)
                        
                      if isEditing {
                        Button(action: {
                            dismiss()
                               },
                               label: {
                                Text("search.cancel")
                               })
                        .padding(.horizontal, 4)
                        .transition(.move(edge: .trailing)) // FIXME: better out transition 
                        .animation(.default)
                      }
                    }
                    .disableAutocorrection(true)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    VStack(spacing: 0) {
                        if errorController.requestError {
                            Spacer()
                            Text("search.request_error").foregroundColor(.gray)
                            Spacer()
                        }
                        else if searchBoxController.query.count == 0 {
                            VStack {
                                VStack(spacing: 16) {
                                    Text("search.examples")
                                        .foregroundColor(Color.secondary)
                                    
                                    ForEach(["Cul de Chien", "La Marie-Rose", "Apremont"], id: \.self) { query in
                                        Button {
                                            searchBoxController.query = query
                                        } label: {
                                            Text(query).foregroundColor(.appGreen)
                                        }
                                    }
                                }
                                .padding(.top, 100)

                                Spacer()
                            }
                        }
                        else if(areaHitsController.hits.count == 0 && problemHitsController.hits.count == 0) {
                            Spacer()
                            Text("search.no_results").foregroundColor(.gray)
                            Spacer()
                        }
                        else {
                            Results()
                        }
                    }
                    .opacity(isEditing ? 1 : 0)
                    
//                    Spacer()
                }
//                .background(Color.red)
//                .zIndex(20)
                
                HStack {
                    Spacer()
                    
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            mapState.centerOnCurrentLocation()
                        }) {
                            Image(systemName: "location")
                                .padding(12)
                                .offset(x: -1, y: 0)
                        }
                        .accentColor(.primary)
                        .background(Color.systemBackground)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.gray, lineWidth: 0.25)
                        )
                        .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                        .padding(.horizontal)
                        
                        Button(action: {
                            mapState.presentFilters = true
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .padding(12)
                        }
                        .accentColor(mapState.filters.filtersCount() >= 1 ? .systemBackground : .primary)
                        .background(mapState.filters.filtersCount() >= 1 ? Color.appGreen : .systemBackground)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.gray, lineWidth: 0.25)
                        )
                        .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                        .padding(.horizontal)
                        
                    }
                }
                .padding(.bottom)
                .zIndex(10)
                .opacity(isEditing ? 0 : 1)
            }
            .sheet(isPresented: $mapState.presentProblemDetails) {
                ProblemDetailsView(
                    problem: $mapState.selectedProblem,
                    mapState: mapState
                )
                .modify {
                    if #available(iOS 16, *) {
                        $0.presentationDetents([.medium]).presentationDragIndicator(.hidden) // TODO: use heights?
                    }
                    else {
                        $0
                    }
                }
            }
            // temporary hack to make multi sheets work on iOS14
            .background(
                EmptyView()
                    .sheet(isPresented: $mapState.presentFilters, onDismiss: {
                        mapState.filtersRefresh()
                        // TODO: update $mapState.filters only on dismiss
                    }) {
                        FiltersView(presentFilters: $mapState.presentFilters, filters: $mapState.filters)
                            .modify {
                                if #available(iOS 16, *) {
                                    $0.presentationDetents([.medium]).presentationDragIndicator(.hidden) // TODO: use heights?
                                }
                                else {
                                    $0
                                }
                            }
                    }
            )
            .tabItem {
                Label("tabs.map", systemImage: "map")
            }
            .tag(Tab.map)
            
            DiscoverView(appTab: $appTab, mapState: mapState)
                .tabItem {
                    Label("tabs.discover", systemImage: "sparkles")
                }
                .tag(Tab.discover)
            
            TickList(appTab: $appTab, mapState: mapState)
                .tabItem {
                    Label("tabs.ticklist", systemImage: "bookmark")
                }
                .tag(Tab.ticklist)
        }
    }
    
    private func Results() -> some View {
        List {
            if(areaHitsController.hits.count > 0) {
                Section(header: Text("search.areas")) {
                    ForEach(areaHitsController.hits, id: \.self) { (hit: AreaItem?) in
                        if let id = Int(hit?.objectID ?? "") {
                            
                            Button {
                                dismiss()
                                
                                if let area = Area.load(id: id) {
                                    mapState.centerOnArea(area)
                                }
                            } label: {
                                HStack {
                                    Text(hit?.name ?? "").foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }
            }
            if(problemHitsController.hits.count > 0) {
                Section(header: Text("search.problems")) {
                    ForEach(problemHitsController.hits, id: \.self) { hit in
                        if let id = Int(hit?.objectID ?? ""), let problem = Problem.load(id: id), let hit = hit {
                            
                            Button {
                                dismiss()
                                
                                mapState.selectAndPresentAndCenterOnProblem(problem)
                            } label: {
                                HStack {
                                    ProblemCircleView(problem: problem)
                                    Text(hit.name).foregroundColor(.primary)
                                    Text(hit.grade).foregroundColor(.gray).padding(.leading, 2)
                                    Spacer()
                                    Text(hit.area_name).foregroundColor(.gray).font(.caption)
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.grouped)
        .gesture(DragGesture()
            .onChanged({ _ in
                UIApplication.shared.dismissKeyboard()
            })
        )
    }
    
    func dismiss() {
        isEditing = false
        searchBoxController.query = ""
        
        UIApplication.shared.dismissKeyboard()
    }
    
    enum Tab {
        case map
        case discover
        case ticklist
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}


// FIXME: is there a cleaner way?
// https://stackoverflow.com/a/58988238/230309
extension UIApplication {
      func dismissKeyboard() {
          sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
      }
  }
