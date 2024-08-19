//
//  MapView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 12/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreLocation

import TipKit

struct MapContainerView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @EnvironmentObject var appState: AppState
    @StateObject private var mapState = MapState()
    
    // TODO: make this more DRY
    @State private var presentDownloads = false
    @State private var presentDownloadsPlaceholder = false
    
    var body: some View {
        
        ZStack {
            mapbox
            
            if mapState.presentProblemDetails {
                prevNextButtons
            }
            
//            circuitButtons
            
            fabButtons
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
    
    var prevNextButtons : some View {
        Group {
            HStack(spacing: 8) {
                
                Spacer()
                
                if let previous = mapState.selectedProblem.previousAdjacent {
                
                    Button(action: {
                        mapState.selectProblem(previous)
                    }) {
                        Image(systemName: "arrow.left")
                            .padding(10)
                    }
                    .font(.body.weight(.semibold))
                    .accentColor(.primary)
                    .background(Color.systemBackground)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
                    )
                    .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                    //                        .padding(.horizontal)
                }
                
                if let next = mapState.selectedProblem.nextAdjacent {
                    
                    Button(action: {
                        mapState.selectProblem(next)
                    }) {
                        Image(systemName: "arrow.right")
                            .padding(10)
                    }
                    .font(.body.weight(.semibold))
                    .accentColor(.primary)
                    .background(Color.systemBackground)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
                    )
                    .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                    //                        .padding(.horizontal)
                }
            }
            .padding(.horizontal)
            .offset(CGSize(width: 0, height: -44)) // FIXME: might break in the future (we assume the sheet is exactly half the screen height)
            
        }
    }
    
    var circuitButtons : some View {
        Group {
            if let circuitId = mapState.selectedProblem.circuitId, let circuit = Circuit.load(id: circuitId), mapState.presentProblemDetails {
                HStack(spacing: 8) {
                    
//                    Spacer()
                    
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
//                        .padding(.horizontal)
                    }
                    
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
//                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
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
    
    let tip = DownloadAnnouncementTip()
    
    var fabButtons: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing) {
                Spacer()
                
                if let cluster = mapState.selectedCluster {
                    DownloadButtonView(cluster: cluster, presentDownloads: $presentDownloads, clusterDownloader: ClusterDownloader(cluster: cluster, mainArea: areaBestGuess(in: cluster) ?? cluster.mainArea))
                        .padding(.leading, 44) // to make the tip appear in the right location
                        .modify
                    {
                        if userDidUseOldOfflineMode {
                            if #available(iOS 17.0, *) {
                                $0.popoverTip(tip)
                                    .onChange(of: presentDownloads) { _, presented in
                                        if presented {
                                            tip.invalidate(reason: .actionPerformed)
                                        }
                                    }
                            }
                            else {
                                $0
                            }
                        }
                        else {
                            $0
                        }
                    }
                        
                }
                else {
                    DownloadButtonPlaceholderView(presentDownloadsPlaceholder: $presentDownloadsPlaceholder)
                        .modify
                    {
                        if #available(iOS 17.0, *) {
                            $0.onChange(of: presentDownloadsPlaceholder) { _, presented in
                                if presented {
                                    tip.invalidate(reason: .actionPerformed)
                                }
                            }
                        }
                        else {
                            $0
                        }
                    }
                }
                
                Button(action: {
                    mapState.centerOnCurrentLocation()
                }) {
                    Image(systemName: "location")
                        .offset(x: -1, y: 0)
//                        .font(.system(size: 20, weight: .regular))
                }
                .buttonStyle(FabButton())
                
            }
            .padding(.trailing)
        }
        .padding(.bottom)
        .ignoresSafeArea(.keyboard)
    }
    
    // TODO: remove after October 2024
    private var userDidUseOldOfflineMode: Bool {
        if let data = UserDefaults.standard.data(forKey: "offline-photos/areasIds"),
           let decodedSet = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            return decodedSet.count > 0
        }
        
        return false
    }
    
    private func areaBestGuess(in cluster: Cluster) -> Area? {
        if let selectedArea = mapState.selectedArea {
            return selectedArea
        }
        
        if let zoom = mapState.zoom, let center = mapState.center {
            if zoom > 12.5 {
                if let area = closestArea(in: cluster, from: CLLocation(latitude: center.latitude, longitude: center.longitude)) {
                    return area
                }
            }
        }
        
        return nil
    }
    
    private func closestArea(in cluster: Cluster, from center: CLLocation) -> Area? {
        cluster.areas.sorted {
            $0.center.distance(from: center) < $1.center.distance(from: center)
        }.first
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
