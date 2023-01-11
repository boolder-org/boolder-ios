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
    
    @ObservedObject var mapState: MapState
    @Binding var appTab: ContentView.Tab
    
    var body: some View {
        ZStack {
            Mapbox()
            
            FiltersToolbarView(mapState: mapState)
                .zIndex(10)
            
            if let circuitId = mapState.selectedProblem.circuitId, let circuit = Circuit.load(id: circuitId), mapState.presentProblemDetails {
                HStack(spacing: 0) {
                    
                    if(mapState.canGoToPreviousCircuitProblem) {
                        Button(action: {
                            mapState.selectCircuit(circuit)
                            mapState.goToPreviousCircuitProblem()
                        }) {
                            Image(systemName: "arrow.left")
                                .padding(10)
                            //                                .offset(x: -1, y: 0)
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
                .offset(CGSize(width: 0, height: -44)) // TODO: make sure it works on all device sizes (we assume the sheet is exactly half the screen height, which may break in the future)
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
//                                    CircleView(number: "1", color: circuit.color.uicolor, height: 24)
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
            
            
            SearchView(mapState: mapState)
                .zIndex(20)
                .opacity(mapState.selectedArea != nil ? 0 : 1)
            
            AreaToolbarView(mapState: mapState, appTab: $appTab)
                .zIndex(30)
                .opacity(mapState.selectedArea != nil ? 1 : 0)
            
//            CircuitToolbarView(mapState: mapState)
//                .zIndex(40)
//                .opacity(mapState.selectedCircuit != nil ? 1 : 0)
        }
    }
    
    func Mapbox() -> some View {
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
                // FIXME: there is a bug with SwiftUI not passing environment correctly to modal views (only on iOS14?)
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
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
