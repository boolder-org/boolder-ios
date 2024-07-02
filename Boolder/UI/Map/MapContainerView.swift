//
//  MapView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 12/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreLocation

struct MapContainerView: View {
    @EnvironmentObject var odrManager: ODRManager
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @EnvironmentObject var appState: AppState
    @StateObject private var mapState = MapState()
    
    @State private var presentDownloads = false
    
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
                    if #available(iOS 16.4, *) {
                        $0
                            .presentationDetents([.medium])
                            .presentationBackgroundInteraction(
                                .enabled(upThrough: .medium)
                            )
                            .presentationDragIndicator(.hidden) // TODO: use heights?
                    }
                    else if #available(iOS 16, *) {
                        $0
                            .presentationDetents(undimmed: [.medium])
                            .presentationDragIndicator(.hidden) // TODO: use heights?
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
    
    // FIXME: change name
    var locateButton : some View {
        HStack {
            Spacer()
            
            VStack {
                Spacer()
                
//                Button(action: {
//                    
//                }) {
//                    Text("cluster")
//                }
//                .accentColor(.primary)
//                .background(Color.systemBackground)
//                .clipShape(Circle())
//                .overlay(
//                    Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
//                )
//                .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
//                .padding(.horizontal)
                
                if let cluster = mapState.selectedCluster {
                    
                    Button(action: {
                        presentDownloads = true
                    }) {
                        
                        Image(systemName: "arrow.down.circle")
                            .padding(12)
                        //                        .offset(x: -1, y: 0)
                    }
                    .accentColor(.primary)
                    .background(Color.systemBackground)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
                    )
                    .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                    .padding(.horizontal)
                    
                    .sheet(isPresented: $presentDownloads) {
                        DownloadsView(cluster: cluster, area: mapState.selectedArea)
                            .modify {
                                if #available(iOS 16, *) {
                                    $0.presentationDetents([.medium, .large])
                                }
                                else {
                                    $0
                                }
                            }
                    }
                }
                
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
