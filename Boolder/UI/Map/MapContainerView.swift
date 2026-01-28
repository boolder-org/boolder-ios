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
    
    @Environment(AppState.self) private var appState: AppState
    @Environment(MapState.self) private var mapState: MapState
    
    
    // TODO: make this more DRY
    @State private var presentDownloads = false
    @State private var presentDownloadsPlaceholder = false
    @State private var presentTopoShowAllLines = false
    
    @Namespace private var topoTransitionNamespace
    
    var body: some View {
        @Bindable var mapState = mapState
        
        ZStack {
            mapbox
            
            // fake view acting as an anchor point for poi sheet
            Color.clear.frame(width: 10, height: 10).allowsHitTesting(false)
                .poiActionSheet(selectedPoi: $mapState.selectedPoi)
            
            aboveTheSheetBar
            
//            circuitButtons
            
            circuitStartButton
            
            fabButtonsContainer
                .zIndex(10)
            
            SearchView()
                .zIndex(20)
                .opacity(mapState.selectedArea != nil ? 0 : 1)
            
            AreaToolbarView()
                .zIndex(30)
                .opacity(mapState.selectedArea != nil ? 1 : 0)
            
        }
        .onChange(of: appState.selectedProblem) { oldValue, newValue in
            if let problem = appState.selectedProblem {
                mapState.selectAndPresentAndCenterOnProblem(problem)
                mapState.presentAreaView = false
            }
        }
        .onChange(of: appState.selectedArea) { oldValue, newValue in
            if let area = appState.selectedArea {
                mapState.selectArea(area)
                mapState.centerOnArea(area)
            }
        }
        .onChange(of: appState.selectedCircuit) { oldValue, newValue in
            if let circuitWithArea = appState.selectedCircuit {
                mapState.selectArea(circuitWithArea.area)
                mapState.selectAndCenterOnCircuit(circuitWithArea.circuit)
                mapState.displayCircuitStartButton = true
                mapState.presentAreaView = false
            }
        }
    }
    
    var mapbox : some View {
        @Bindable var mapState = mapState
        return MapboxView(mapState: mapState)
            .modify {
                if #available(iOS 26, *) {
                    $0.edgesIgnoringSafeArea(.vertical)
                }
                else {
                    $0.edgesIgnoringSafeArea(.top)
                }
            }
            .ignoresSafeArea(.keyboard)
            .modify {
                if #available(iOS 26, *) {
                    $0 // Sheet presented via overlay for iOS 26
                }
                else {
                    $0.sheet(isPresented: $mapState.presentProblemDetails) {
                        ProblemDetailsView(
                            problem: $mapState.selectedProblem,
                            topoTransitionNamespace: topoTransitionNamespace
                        )
                        .presentationDetents([detent])
                        .presentationBackgroundInteraction(
                            .enabled(upThrough: detent)
                        )
                        .presentationDragIndicator(.hidden)
                    }
                }
            }
    }
    
    var detent: PresentationDetent {
        if UIScreen.main.bounds.height <= 667 { // iPhone SE (all generations) & iPhone 8 and earlier
            return .height(420)
        }
        else {
            return .medium
        }
    }
    
    var offsetToBeOnTopOfSheet: CGFloat {
        if UIScreen.main.bounds.height <= 667 { // iPhone SE (all generations) & iPhone 8 and earlier
            if #available(iOS 26, *) {
                return -80
            }
            else {
                return -104
            }
        }
        else {
            return -48
        }
    }
    
    var aboveTheSheetBar : some View {
        Group {
            HStack {
                Spacer()
                
                showAllLinesButton
            }
            .padding(.horizontal, 4)
            .opacity(mapState.selectedArea != nil && mapState.presentProblemDetails ? 1 : 0)
            .offset(CGSize(width: 0, height: offsetToBeOnTopOfSheet - 8)) // FIXME: might break in the future (we assume the sheet is exactly half the screen height)
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
                                .modify {
                                    if #available(iOS 26, *) {
                                        $0.padding(2)
                                    } else {
                                        $0.padding(10)
                                    }
                                }
                        }
                        .font(.body.weight(.semibold))
                        .modify {
                            if #available(iOS 26, *) {
                                $0.buttonStyle(.glass).buttonBorderShape(.circle)
                                    .foregroundColor(Color(circuit.color.uicolorForSystemBackground))
                            } else {
                                $0
                                    .accentColor(Color(circuit.color.uicolorForSystemBackground))
                                    .background(Color.systemBackground)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
                                    )
                                    .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    if(mapState.canGoToNextCircuitProblem) {
                        
                        Button(action: {
                            mapState.selectCircuit(circuit)
                            mapState.goToNextCircuitProblem()
                        }) {
                            Image(systemName: "arrow.right")
                                .modify {
                                    if #available(iOS 26, *) {
                                        $0.padding(2)
                                    } else {
                                        $0.padding(10)
                                    }
                                }
                        }
                        .font(.body.weight(.semibold))
                        .modify {
                            if #available(iOS 26, *) {
                                $0.buttonStyle(.glass).buttonBorderShape(.circle)
                                    .foregroundColor(Color(circuit.color.uicolorForSystemBackground))
                            } else {
                                $0
                                    .accentColor(Color(circuit.color.uicolorForSystemBackground))
                                    .background(Color.systemBackground)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
                                    )
                                    .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .offset(CGSize(width: 0, height: offsetToBeOnTopOfSheet)) // FIXME: might break in the future (we assume the sheet is exactly half the screen height)
            }
        }
    }
    
    var circuitStartButton : some View {
        Group {
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
                            .modify {
                                if #available(iOS 26, *) {
                                    $0.buttonStyle(.glassProminent).tint(Color(circuit.color.uicolorForSystemBackground))
                                    //.foregroundColor(Color(circuit.color.uicolorForSystemBackground))
                                } else {
                                    $0
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
                            }
                            
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    var fabButtonsContainer: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing) {
                Spacer()
                
                if #available(iOS 26.0, *) {
                    GlassEffectContainer {
                        fabButtons
                    }
                } else {
                    fabButtons
                }
            }
            .padding(.trailing)
        }
        .padding(.bottom)
        .ignoresSafeArea(.keyboard)
    }
    
    var fabButtons: some View {
        Group {
            Group {
                if let cluster = mapState.selectedCluster {
                    DownloadButtonView(cluster: cluster, presentDownloads: $presentDownloads, clusterDownloader: ClusterDownloader(cluster: cluster, mainArea: areaBestGuess(in: cluster) ?? cluster.mainArea))
                }
                else {
                    DownloadButtonPlaceholderView(presentDownloadsPlaceholder: $presentDownloadsPlaceholder)
                    
                }
            }
            .foregroundColor(.primary)
            .modify {
                if #available(iOS 26, *) {
                    $0.glassEffect(.regular.interactive(), in: Circle())
                }
                else {
                    $0.buttonStyle(FabButton())
                }
            }
            
            Button {
                print("location")
                mapState.centerOnCurrentLocation()
            } label: {
                Image(systemName: "location")
//                    .frame(width: 22, height: 22)
                    .padding(12)
                    .foregroundColor(.primary)
                    
//                    .offset(x: -1, y: 0)
                //                        .font(.system(size: 20, weight: .regular))
            }
            .modify {
                if #available(iOS 26, *) {
                    $0.glassEffect(.regular.interactive(), in: .circle)
                }
                else {
                    $0.buttonStyle(FabButton())
                }
            }
        }
    }
    
    var showAllLinesButton: some View {
        @Bindable var mapState = mapState
        
        return Button {
            presentTopoShowAllLines = true
        } label: {
            Image(systemName: "arrow.trianglehead.branch")
                .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
                .padding(4)
                .foregroundColor(.primary)
        }
        .modify {
            if #available(iOS 26, *) {
                $0.buttonStyle(.glass)
                    .buttonBorderShape(.circle)
            }
            else {
                $0.buttonStyle(FabButton())
            }
        }
        .fullScreenCover(isPresented: $presentTopoShowAllLines) {
            TopoFullScreenView(problem: $mapState.selectedProblem, initialShowAllLines: true)
                .modify {
                    if #available(iOS 18, *) {
                        $0.navigationTransition(.zoom(sourceID: "topo-\(mapState.selectedProblem.topoId ?? 0)", in: topoTransitionNamespace))
                    }
                    else {
                        $0
                    }
                }
        }
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
