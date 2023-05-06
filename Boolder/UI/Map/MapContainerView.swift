//
//  MapView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 12/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreLocation
import CoreData

struct MapContainerView: View {
    @EnvironmentObject var odrManager: ODRManager
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @EnvironmentObject var appState: AppState
    @StateObject private var mapState = MapState()
    
    var body: some View {
        ZStack {
            mapbox
            
            circuitButtons
            
            locateButton
                .zIndex(10)
            
            SearchView(mapState: mapState)
                .zIndex(20)
                .opacity(mapState.selectedArea != nil ? 0 : 1)
            
            AreaToolbarView(mapState: mapState)
                .zIndex(30)
                .opacity(mapState.selectedArea != nil ? 1 : 0)
        }
        .onAppear {
            loadTop7a()
        }
        .onChange(of: appState.selectedProblem) { newValue in
            if let problem = appState.selectedProblem {
                mapState.selectAndPresentAndCenterOnProblem(problem)
                mapState.presentAreaView = false
            }
        }
        .onChange(of: appState.selectedArea) { newValue in
            if let area = appState.selectedArea {
                mapState.selectArea(area)
                mapState.centerOnArea(area)
            }
        }
        .onChange(of: appState.selectedCircuit) { newValue in
            if let circuitWithArea = appState.selectedCircuit {
                mapState.selectArea(circuitWithArea.area)
                mapState.selectAndCenterOnCircuit(circuitWithArea.circuit)
                mapState.displayCircuitStartButton = true
                mapState.presentAreaView = false
            }
        }
    }
    
    func loadTop7a() {
        print("load 7a")
        if favorites().isEmpty {
            let ids = [15552,15555,15553,15658,15625,15560,224,230,10873,10869,245,243,237,9074,14558,14199,14179,14136,14343,1739,1703,10045,10042,1088,915,914,881,1032,5397,5326,5325,1856,1840,1861,1816,1913,2021,2003,2094,2087,11310,2668,2857,2542,2545,2543,2527,8680,8801,7807,2542,1582,1462,1455,1579,1526,1435,13478,13484,13468,13467,13074,12998,13070,13011,13042,13040,13030,2893,2911,2902,2889,3091,3092,3161,3186,11425,6342,6344,3257,3255,3283,3288,3331,3409,4534,4551,4581,690,5091,5106,5124,5088,5127,7878,3825,3803,4787,9237,9177,9302,9345,2315,2214,7756,2352,8131,8126]
            
            ids.forEach { id in
                let favorite = Favorite(context: managedObjectContext)
                favorite.id = UUID()
                favorite.problemId = Int64(id)
                favorite.createdAt = Date()
                
                do {
                    try managedObjectContext.save()
                } catch {
                    // handle the Core Data error
                }
            }
            
            print("done")
        }
        else {
            print("nothing to load")
        }
    }
    
    func favorites() -> [Favorite] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        request.sortDescriptors = []
        
        do {
            return try context.fetch(request)
        } catch {
            fatalError("Failed to fetch favorites: \(error)")
        }
    }
    
    var mapbox : some View {
        MapboxView(mapState: mapState)
            .edgesIgnoringSafeArea(.top)
            .ignoresSafeArea(.keyboard)
            .background(
                PoiActionSheet(
                    name: (mapState.selectedPoi?.name ?? ""),
                    googleUrl: URL(string: mapState.selectedPoi?.googleUrl ?? ""),
                    presentPoiActionSheet: $mapState.presentPoiActionSheet
                )
            )
            .sheet(isPresented: $mapState.presentProblemDetails) {
                ProblemDetailsView(
                    problem: $mapState.selectedProblem,
                    mapState: mapState
                )
                // TODO: there is a bug with SwiftUI not passing environment correctly to modal views (only on iOS14?)
                // remove these lines as soon as it's fixed
                .environment(\.managedObjectContext, managedObjectContext)
                .environmentObject(odrManager)
                .modify {
                    if #available(iOS 16, *) {
                        $0.presentationDetents(undimmed: [.medium]).presentationDragIndicator(.hidden) // TODO: use heights?
                    }
                    else {
                        $0
                    }
                }
            }
    }
    
    var circuitButtons : some View {
        Group {
            if let circuitId = mapState.selectedProblem.circuitId, let circuit = Circuit.load(id: circuitId), mapState.presentProblemDetails {
                HStack(spacing: 0) {
                    
                    if(mapState.canGoToPreviousCircuitProblem) {
                        Button(action: {
                            mapState.selectCircuit(circuit)
                            mapState.goToPreviousCircuitProblem()
                        }) {
                            Image(systemName: "arrow.left")
                                .padding(10)
                        }
                        .font(.body.weight(.semibold))
                        .accentColor(Color(circuit.color.uicolorForSystemBackground))
                        .background(Color.systemBackground)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
                        )
                        .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    if(mapState.canGoToNextCircuitProblem) {
                        
                        Button(action: {
                            mapState.selectCircuit(circuit)
                            mapState.goToNextCircuitProblem()
                        }) {
                            Image(systemName: "arrow.right")
                                .padding(10)
                        }
                        .font(.body.weight(.semibold))
                        .accentColor(Color(circuit.color.uicolorForSystemBackground))
                        .background(Color.systemBackground)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
                        )
                        .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                        .padding(.horizontal)
                    }
                }
                .offset(CGSize(width: 0, height: -44)) // FIXME: might break in the future (we assume the sheet is exactly half the screen height)
            }
            
            if mapState.displayCircuitStartButton {
                if let circuit = mapState.selectedCircuit, let start = circuit.firstProblem {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Button {
                                mapState.selectAndPresentAndCenterOnProblem(start)
                                mapState.displayCircuitStartButton = false
                            } label: {
                                HStack {
                                    Text("map.circuit_start")
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .font(.body.weight(.semibold))
                            .accentColor(Color(circuit.color.uicolorForSystemBackground))
                            .background(Color.systemBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                            .overlay(
                                RoundedRectangle(cornerRadius: 32).stroke(Color(.secondaryLabel), lineWidth: 0.25)
                            )
                            .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                            
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    var locateButton : some View {
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
                    Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
                )
                .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                .padding(.horizontal)
                
            }
        }
        .padding(.bottom)
        .ignoresSafeArea(.keyboard)
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
