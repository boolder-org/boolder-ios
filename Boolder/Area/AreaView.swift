//
//  AreaView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreData

struct AreaView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var presentationMode // required because of a bug with iOS 13: https://stackoverflow.com/questions/58512344/swiftui-navigation-bar-button-not-clickable-after-sheet-has-been-presented
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var showList = false
    @State private var selectedProblem: Problem = Problem() // FIXME: use nil as default
    @State private var presentProblemDetails = false
    @State private var selectedPoi: Poi? = nil
    @State private var presentPoiActionSheet = false
    @State private var centerOnCurrentLocationCount = 0
    
    var body: some View {
        ZStack {
            ProblemListView(selectedProblem: $selectedProblem, presentProblemDetails: $presentProblemDetails)
                .zIndex(showList ? 1 : 0)
            
            MapView(selectedProblem: $selectedProblem, presentProblemDetails: $presentProblemDetails, selectedPoi: $selectedPoi, presentPoiActionSheet: $presentPoiActionSheet, centerOnCurrentLocationCount: $centerOnCurrentLocationCount)
                .edgesIgnoringSafeArea(.bottom)
                .zIndex(showList ? 0 : 1)
                .sheet(isPresented: $presentProblemDetails) {
                    ProblemDetailsView(problem: $selectedProblem)
                        // FIXME: there is a bug with SwiftUI not passing environment correctly to modal views
                        // remove these lines as soon as it's fixed
                        .environmentObject(dataStore)
                        .environment(\.managedObjectContext, managedObjectContext)
                        .accentColor(Color.green)
                }
                .background(
                    PoiActionSheet(
                        description: (selectedPoi?.description ?? ""),
                        location: (selectedPoi?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)),
                        navigationMode: true,
                        presentPoiActionSheet: $presentPoiActionSheet
                    )
                )
            
            VStack {
                Spacer()
                FabFiltersView(filters: dataStore.filters)
                    .padding(.bottom, 24)
            }
            .zIndex(10)
            
            if !showList {
                HStack {
                    Spacer()
                    
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            centerOnCurrentLocationCount += 1
                        }) {
                            Image(systemName: "location")
                            .padding(12)
                            .offset(x: -1, y: 0)
                        }
                        .accentColor(Color(.label))
                        .background(Color(UIColor.systemBackground))
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.gray, lineWidth: 0.25)
                        )
                        .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                        .padding()
                    }
                }
                .padding(.bottom, 28)
                .zIndex(10)
            }
        }
        .navigationBarTitle(Text(dataStore.areas[dataStore.areaId]!), displayMode: .inline)
        .navigationBarItems(
            trailing: Button(action: {
                showList.toggle()
            }) {
                Text(showList ? "area.map" : "area.list")
                    .font(.body)
                    .padding(.vertical)
                    .padding(.leading)
            }
        )
//        .onAppear {
//        #if DEBUG
//            // delete all favorites
//            let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
//            let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
//            do { try managedObjectContext.execute(DelAllReqVar) }
//            catch { print(error) }
//
//            // delete all ticks
//            let ReqVar2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Tick")
//            let DelAllReqVar2 = NSBatchDeleteRequest(fetchRequest: ReqVar2)
//            do { try managedObjectContext.execute(DelAllReqVar2) }
//            catch { print(error) }
//        #endif
//        }
    }
}

struct AreaView_Previews: PreviewProvider {
    static var previews: some View {
        AreaView()
            .environmentObject(DataStore())
    }
}
