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
    
    var body: some View {
        @Bindable var mapState = mapState
        
        ZStack {
            mapbox
            
            // fake view acting as an anchor point for poi sheet
            Color.clear.frame(width: 10, height: 10).allowsHitTesting(false)
                .poiActionSheet(selectedPoi: $mapState.selectedPoi)
            
            aboveSheetNavigationButtons
                .opacity(mapState.presentProblemDetails ? 1 : 0)
            
            circuitStartButton
            
            fabButtonsContainer
                .zIndex(10)
            
            if mapState.selectedArea == nil {
                searchButtonOverlay
                    .zIndex(20)
            }
            
            AreaToolbarView()
                .zIndex(30)
                .opacity(mapState.selectedArea != nil ? 1 : 0)
        }
        .sheet(isPresented: $mapState.presentSearch) {
            SearchSheetView()
        }
        .onChange(of: mapState.presentProblemDetails) { oldValue, newValue in
            if !newValue {
                mapState.deselectTopo()
            }
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
                        ProblemDetailsView()
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
            if #available(iOS 26, *) {
                return -32
            }
            else {
                return -48
            }
        }
    }
    
    var aboveSheetNavigationButtons : some View {
        VStack {
            HStack {
                if let circuit = mapState.selectedCircuit, circuit.id == mapState.selectedProblem?.circuitId {
                    if mapState.presentProblemDetails {
                        fullScreenButton
                    }
                    
                    Spacer()
                    
                    if #available(iOS 26.0, *) {
                        GlassEffectContainer {
                            circuitButtonsContent(circuit: circuit)
                        }
                    } else {
                        circuitButtonsContent(circuit: circuit)
                    }
                } else {
                    Spacer()
                    
                    if mapState.presentProblemDetails {
                        fullScreenButton
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .offset(CGSize(width: 0, height: offsetToBeOnTopOfSheet)) // FIXME: might break in the future (we assume the sheet is exactly half the screen height)
    }
    
    var fullScreenButton: some View {
        Button(action: {
            mapState.requestTopoFullScreenPresentation()
        }) {
            Image(systemName: "arrow.down.left.and.arrow.up.right")
                .adaptiveCircleButtonIcon()
        }
        .adaptiveCircleButtonStyle()
    }
    
    func circuitButtonsContent(circuit: Circuit) -> some View {
        HStack(spacing: 0) {
            Button(action: {
                if mapState.canGoToPreviousCircuitProblem {
                    mapState.goToPreviousCircuitProblem()
                }
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: UIFontMetrics.default.scaledValue(for: 20)))
                    .padding(12)
            }
            .font(.body.weight(.semibold))
            .opacity(mapState.canGoToPreviousCircuitProblem ? 1 : 0.3)
            
            Button(action: {
                if mapState.canGoToNextCircuitProblem {
                    mapState.goToNextCircuitProblem()
                }
            }) {
                Image(systemName: "arrow.right")
                    .font(.system(size: UIFontMetrics.default.scaledValue(for: 20)))
                    .padding(12)
            }
            .font(.body.weight(.semibold))
            .opacity(mapState.canGoToNextCircuitProblem ? 1 : 0.3)
        }
        .foregroundColor(Color(circuit.color.uicolorForSystemBackground))
        .adaptiveCapsuleStyle()
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
    
    var searchButtonOverlay: some View {
        VStack {
            HStack {
                Button {
                    mapState.presentProblemDetails = false
                    mapState.presentSearch = true
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(.secondaryLabel))
                        Text("search.placeholder")
                            .foregroundColor(Color(.secondaryLabel))
                        Spacer()
                    }
                    .frame(maxWidth: 400)
                    .modify {
                        if #available(iOS 26, *) {
                            $0.padding(.vertical, 4)
                        } else {
                            $0
                                .padding(10)
                                .padding(.horizontal, 25)
                        }
                    }
                }
                .modify {
                    if #available(iOS 26, *) {
                        $0.buttonStyle(.glass)
                    } else {
                        $0
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color(.secondaryLabel).opacity(0.5), radius: 5)
                    }
                }
                .contentShape(Rectangle())
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Spacer()
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
            .adaptiveFabStyle()
            
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
            .adaptiveFabStyle()
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
