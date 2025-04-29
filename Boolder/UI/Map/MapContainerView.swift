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
    
    @State private var selectedDetent: PresentationDetent = smallDetent
    static let maxDetent = PresentationDetent.fraction(0.90)
    static let smallDetent = PresentationDetent.height(UIScreen.main.bounds.width*3/4 + 96)
    
    var body: some View {
        
        ZStack {
            mapbox
//                .overlay(
//                    DraggableSheet()
//                )
            
//            circuitButtons
            
//            browseButtons
            
            Group {
                
                fabButtons
                    .zIndex(10)
                
                SearchView(mapState: mapState)
                    .zIndex(20)
                    .opacity(mapState.selectedArea != nil ? 0 : 1)
                
                AreaToolbarView(mapState: mapState)
                    .zIndex(30)
                    .opacity(mapState.selectedArea != nil ? 1 : 0)
            }
            .opacity(selectedDetent == MapContainerView.maxDetent ? 0 : 1)
            
            if mapState.presentProblemDetails { //} selectedProblem != Problem.empty {
                VStack {
                    Spacer()
                    TopoView(
                        problem: $mapState.selectedProblem,
                        mapState: mapState,
                        selectedDetent: $selectedDetent
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(8)
                .zIndex(40)
            }
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
//            .background(
//                CustomNoClipSheet(
//                    isPresented: $mapState.presentProblemDetails,
//                    detents: [.medium()],
//                    prefersGrabber: false)
//                {
//                    ProblemDetailsView(
//                        problem: $mapState.selectedProblem,
//                        mapState: mapState,
//                        selectedDetent: $selectedDetent
//                    )
//                }
//            )
        
    }
    
//    var detent: PresentationDetent {
//        if UIScreen.main.bounds.height <= 667 { // iPhone SE (all generations) & iPhone 8 and earlier
//            return .height(420)
//        }
//        else {
//            return .medium
//        }
//    }
    
    var offsetToBeOnTopOfSheet: CGFloat {
        if UIScreen.main.bounds.height <= 667 { // iPhone SE (all generations) & iPhone 8 and earlier
            return -104
        }
        else {
            return -48
        }
    }
    
    var browseButtons : some View {
        Group {
            
            if mapState.presentProblemDetails, let boulderId = mapState.selectedProblem.topo?.boulderId {
                HStack(spacing: 0) {
                    
                    if let previous = Boulder(id: boulderId).previous(before: mapState.selectedProblem) {
                        Button(action: {
                            mapState.selectStart(previous)
                        }) {
                            Image(systemName: "arrow.left")
                                .padding(10)
                        }
                        .font(.body.weight(.semibold))
                        .accentColor(.black)
                        .background(Color.systemBackground)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
                        )
                        .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    if let next = Boulder(id: boulderId).next(after: mapState.selectedProblem) {
                        
                        Button(action: {
                            
                                mapState.selectStart(next)
                            
                        }) {
                            Image(systemName: "arrow.right")
                                .padding(10)
                        }
                        .font(.body.weight(.semibold))
                        .accentColor(.black)
                        .background(Color.systemBackground)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
                        )
                        .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                        .padding(.horizontal)
                    }
                }
                .offset(CGSize(width: 0, height: offsetToBeOnTopOfSheet)) // FIXME: might break in the future (we assume the sheet is exactly half the screen height)
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
                .offset(CGSize(width: 0, height: offsetToBeOnTopOfSheet)) // FIXME: might break in the future (we assume the sheet is exactly half the screen height)
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
    
    var fabButtons: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing) {
                Spacer()
                
                if let cluster = mapState.selectedCluster {
                    DownloadButtonView(cluster: cluster, presentDownloads: $presentDownloads, clusterDownloader: ClusterDownloader(cluster: cluster, mainArea: areaBestGuess(in: cluster) ?? cluster.mainArea))
                }
                else {
                    DownloadButtonPlaceholderView(presentDownloadsPlaceholder: $presentDownloadsPlaceholder)

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

/// A UIHostingController subclass that turns off all masks on itself and its container views.
class NoClipHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Disable clipping on the hosting view and its superviews
        func disableClipping(_ v: UIView?) {
            v?.clipsToBounds = false
            v?.layer.masksToBounds = false
        }

        disableClipping(view)
        disableClipping(view.superview)
        disableClipping(view.superview?.superview)
    }
}

/// A SwiftUI wrapper that presents its `content` as a custom iOS sheet,
/// but with clipping completely turned off.
struct CustomNoClipSheet<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let detents: [UISheetPresentationController.Detent]
    let prefersGrabber: Bool
    let content: () -> Content
    
    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        var parent: CustomNoClipSheet
        var isPresented: Bool = false
        
        init(_ parent: CustomNoClipSheet) {
            self.parent = parent
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            if isPresented {
                parent.isPresented = false
                isPresented = false
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiVC: UIViewController, context: Context) {
        // Only handle presentation/dismissal if the state has actually changed
        if isPresented != context.coordinator.isPresented {
            if isPresented && uiVC.presentedViewController == nil {
                // Wrap the SwiftUI content in our no-clip hosting controller
                let sheetVC = NoClipHostingController(rootView:
                    content()
                        .edgesIgnoringSafeArea(.all)
                        .environment(\.managedObjectContext, (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
                )

                // Configure the native sheet controller
                if let sheet = sheetVC.sheetPresentationController {
                    sheet.detents = detents
                    sheet.prefersGrabberVisible = prefersGrabber
                    sheet.preferredCornerRadius = 0
                    sheet.largestUndimmedDetentIdentifier = .medium
                    sheet.delegate = context.coordinator
                }

                sheetVC.view.clipsToBounds = false
                sheetVC.view.layer.masksToBounds = false

                uiVC.present(sheetVC, animated: true) {
                    context.coordinator.isPresented = true
                }
            } else if !isPresented && uiVC.presentedViewController != nil {
                uiVC.dismiss(animated: true) {
                    context.coordinator.isPresented = false
                }
            }
        }
    }
}
