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
    @EnvironmentObject var odrManager: ODRManager
    @Environment(\.presentationMode) var presentationMode // required because of a bug with iOS 13: https://stackoverflow.com/questions/58512344/swiftui-navigation-bar-button-not-clickable-after-sheet-has-been-presented
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var showList = false
    @State private var selectedProblem: Problem = Problem() // FIXME: use nil as default
    @State private var presentProblemDetails = false
    @State private var selectedPoi: Poi? = nil
    @State private var presentPoiActionSheet = false
    @State private var presentPhotoCaptureSheet = false
    
    // FIXME: rename
    // FIXME: move to a view whose responsibility is to pick problems for NewTopoView
    @State var mapModeSelectedProblems: [Problem] = [] // FIXME: rename to "record mode", and replace by a set
    @State var recordMode = false
    @State private var capturedPhoto: UIImage? = nil
    @State private var newTopoLocation: CLLocation? = nil
    @State private var newTopoHeading: CLHeading? = nil
    @State private var newTopoComments = ""
    
    @State private var centerOnCurrentLocationCount = 0 // to be able to trigger a map refresh anytime we want
    @State private var centerOnProblem: Problem? = nil
    @State private var centerOnProblemCount = 0 // to be able to trigger a map refresh anytime we want
    
    @State private var areaResourcesDownloaded = false
    
    var body: some View {
        ZStack {
            ProblemListView(selectedProblem: $selectedProblem, presentProblemDetails: $presentProblemDetails)
                .zIndex(showList ? 1 : 0)
            
            MapView(
                selectedProblem: $selectedProblem,
                presentProblemDetails: $presentProblemDetails,
                selectedPoi: $selectedPoi,
                presentPoiActionSheet: $presentPoiActionSheet,
                centerOnCurrentLocationCount: $centerOnCurrentLocationCount,
                centerOnProblem: $centerOnProblem,
                centerOnProblemCount: $centerOnProblemCount,
                mapModeSelectedProblems: $mapModeSelectedProblems,
                recordMode: $recordMode
            )
                .edgesIgnoringSafeArea(.bottom)
                .zIndex(showList ? 0 : 1)
                .sheet(isPresented: $presentProblemDetails) {
                    ProblemDetailsView(
                        problem: $selectedProblem,
                        centerOnProblem: $centerOnProblem,
                        centerOnProblemCount: $centerOnProblemCount,
                        showList: $showList,
                        areaResourcesDownloaded: $areaResourcesDownloaded
                    )
                        // FIXME: there is a bug with SwiftUI not passing environment correctly to modal views
                        // remove these lines as soon as it's fixed
                        .environmentObject(dataStore)
                        .environmentObject(odrManager)
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
                .background(
                    EmptyView()
                        .sheet(isPresented: $presentPhotoCaptureSheet) {
                            NewTopoView(
                                capturedPhoto: $capturedPhoto,
                                location: $newTopoLocation,
                                heading: $newTopoHeading,
                                comments: $newTopoComments,
                                mapModeSelectedProblems: $mapModeSelectedProblems,
                                recordMode: $recordMode
                            )
                                .accentColor(Color.green)
                        }
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
            
            #if DEVELOPMENT
            if !showList {
                HStack {
                    VStack {
                        Spacer()
                        
                        VStack {
                            ForEach(mapModeSelectedProblems) { problem in
                                ProblemCircleView(problem: problem)
                            }
                        }
                        
                        Button(action: {
                            presentPhotoCaptureSheet = true
                        }) {
                            Image(systemName: recordMode ? "camera.fill" : "camera")
                                .padding(12)
                        }
                        .accentColor(Color(.label))
                        .foregroundColor(recordMode ? Color.white : Color(.label))
                        .background(recordMode ? Color.green : Color(UIColor.systemBackground))
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
            }
            #endif
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
