//
//  AreaView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreData
import CoreLocation

struct AreaView: View {
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var odrManager: ODRManager
    @Environment(\.presentationMode) var presentationMode // required because of a bug with iOS 13: https://stackoverflow.com/questions/58512344/swiftui-navigation-bar-button-not-clickable-after-sheet-has-been-presented
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var presentList = false
    @State private var selectedProblem: Problem = Problem() // FIXME: use nil as default
    @State private var presentProblemDetails = false
    @State private var selectedPoi: Poi? = nil
    @State private var presentPoiActionSheet = false
    @State private var presentNewTopoSheet = false
    
    @State private var centerOnCurrentLocationCount = 0 // to be able to trigger a map refresh anytime we want
    @State private var centerOnProblem: Problem? = nil
    @State private var centerOnProblemCount = 0 // to be able to trigger a map refresh anytime we want
    
    @State private var areaResourcesDownloaded = false
    
    var body: some View {
        ZStack {
            
            MapView(
                selectedProblem: $selectedProblem,
                presentProblemDetails: $presentProblemDetails,
                selectedPoi: $selectedPoi,
                presentPoiActionSheet: $presentPoiActionSheet,
                centerOnCurrentLocationCount: $centerOnCurrentLocationCount,
                centerOnProblem: $centerOnProblem,
                centerOnProblemCount: $centerOnProblemCount,
                pickedProblems: $newTopoEntry.problems,
                pickerModeEnabled: $newTopoEntry.pickerModeEnabled
            )
                .edgesIgnoringSafeArea(.bottom)
                .sheet(isPresented: $presentProblemDetails) {
                    ProblemDetailsView(
                        problem: $selectedProblem,
                        areaResourcesDownloaded: $areaResourcesDownloaded
                    )
                        // FIXME: there is a bug with SwiftUI not passing environment correctly to modal views
                        // remove these lines as soon as it's fixed
                        .environmentObject(dataStore)
                        .environmentObject(odrManager)
                        .environment(\.managedObjectContext, managedObjectContext)
                }
                .background(
                    PoiActionSheet(
                        description: (selectedPoi?.description ?? ""),
                        location: (selectedPoi?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)),
                        navigationMode: false,
                        presentPoiActionSheet: $presentPoiActionSheet
                    )
                )
                .background(
                    EmptyView()
                        .sheet(isPresented: $presentNewTopoSheet) {
                            NewTopoView(topoEntry: newTopoEntry)
                                .environment(\.managedObjectContext, managedObjectContext)
                        }
                )
                .background(
                    EmptyView()
                        .sheet(isPresented: $presentList) {
                            ProblemListView(centerOnProblem: $centerOnProblem, centerOnProblemCount: $centerOnProblemCount, selectedProblem: $selectedProblem, presentProblemDetails: $presentProblemDetails)
                                .environment(\.managedObjectContext, managedObjectContext)
                        }
                )
            
            VStack {
                Spacer()
                FabFiltersView(filters: dataStore.filters)
                    .padding(.bottom, 24)
            }
            .zIndex(10)
            
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
                    .accentColor(.primary)
                    .background(Color.systemBackground)
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
            
            
            #if DEVELOPMENT
            HStack {
                VStack {
                    Spacer()
                    
                    VStack {
                        ForEach(newTopoEntry.problems) { problem in
                            ProblemCircleView(problem: problem)
                        }
                    }
                    
                    Button(action: {
                        presentNewTopoSheet = true
                    }) {
                        Image(systemName: newTopoEntry.pickerModeEnabled ? "camera.fill" : "camera")
                            .padding(12)
                    }
                    .accentColor(.primary)
                    .foregroundColor(newTopoEntry.pickerModeEnabled ? Color.white : .primary)
                    .background(newTopoEntry.pickerModeEnabled ? Color.appGreen : Color.systemBackground)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.gray, lineWidth: 0.25)
                    )
                    .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                    .padding()
                }
                
                Spacer()
            }
            .padding(.bottom, 28)
            .zIndex(10)
            #endif
        }
        .navigationBarTitle(Text(dataStore.area(withId: dataStore.areaId)!.name), displayMode: .inline)
        .navigationBarItems(
            trailing: Button(action: {
                presentList = true
            }) {
                Text("area.list")
                    .padding(.vertical)
                    .padding(.leading)
            }
        )
        .onAppear{
            odrManager.requestResources(tag: "area-\(dataStore.areaId)", onSuccess: {
                areaResourcesDownloaded = true
                
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
    
    // this view model lives here to be able to use the map as a problem picker (for NewTopoView)
    // it works but it's not super clean
    // TODO: create a dedicated picker screen to move this logic away from the main map
    @StateObject private var newTopoEntry = TopoEntry()
}

struct AreaView_Previews: PreviewProvider {
    static var previews: some View {
        AreaView()
            .environmentObject(DataStore())
    }
}
