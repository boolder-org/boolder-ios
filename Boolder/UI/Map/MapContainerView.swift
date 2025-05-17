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
    
    @State private var zoomScale: CGFloat = 1

    @State private var presentFullScreen = false
    @Namespace private var animation
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    var body: some View {
            ZStack {
                mapbox
                
//                VStack {
//                    Spacer()
//                    Color.white
//                        .frame(height: 83)
//                        
//                }
//                .edgesIgnoringSafeArea(.bottom)
//                .zIndex(100)
                
                
                
                
                //                .overlay(
                //                    DraggableSheet()
                //                )
                
                //            circuitButtons
                
                //            browseButtons
                
                //            if !mapState.showAllStarts && mapState.presentProblemDetails {
                //                VStack(spacing: 0) {
                //                    Spacer()
                //                    //                selectedStart
                //                    
                //                    infosCard
                ////                        .background(.thinMaterial)
                //                        .background(Color.white)
                //                        .clipShape(RoundedRectangle(cornerRadius: 12))
                //                        .overlay(
                //                            RoundedRectangle(cornerRadius: 12)
                //                                .stroke(Color(.secondaryLabel), lineWidth: 0.5)
                //                        )
                //                        .padding(8)
                //                }
                //                    .offset(CGSize(width: 0, height: -290)) // FIXME: don't hardcode value
                //            }
                
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
                
                if mapState.presentProblemDetails {
                    VStack {
                        Spacer()
                        
//                        Button {
//                            presentFullScreen = true
//                        } label: {
//                            Text("full screen")
//                        }
                        
//                        if mapState.presentProblemDetails && !mapState.anyStartSelected {
//                            HStack {
//                                Text(mapState.selectedProblem.localizedName)
//                                    .font(.body.weight(.regular))
//                                
//                                Spacer()
//                                HStack(spacing: 8) {
//                                    Button {
//                                        
//                                    } label: {
//                                        Image(systemName: "ellipsis")
////                                            .font(.caption.weight(.semibold))
//                                            .font(.body.weight(.semibold))
////                                            .padding(8)
//                                            .foregroundColor(.gray)
//                                            .frame(width: 24, height: 24)
//                                            .background(Color(.systemGray5))
//                                            .clipShape(Circle())
//                                    }
//                                    
//                                    Button {
//                                        mapState.showAllStarts = true
//                                    } label: {
//                                        Image(systemName: "xmark")
////                                            .padding(8)
////                                            .font(.caption.weight(.semibold))
//                                            .font(.body.weight(.semibold))
//                                            .foregroundColor(.gray)
//                                            .frame(width: 24, height: 24)
//                                            .background(Color(.systemGray5))
//                                            .clipShape(Circle())
//                                    }
//                                }
//                            }
//                            
//                            .padding(8)
//                            .background{Color.white}
//                            .clipShape(RoundedRectangle(cornerRadius: 8))
//                            .padding(.horizontal, 8)
////                            .padding(.bottom, 8)
//                        }
                        
//                        ZoomableScrollView(zoomScale: $zoomScale) {
                            TopoView(
                                topo: mapState.selectedProblem.topo!,
                                problem: $mapState.selectedProblem,
                                mapState: mapState,
                                zoomScale: $zoomScale
                            )
                            .matchedTransitionSource(id: "photo", in: animation)
//                        }
                        .background(Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .aspectRatio(4/3, contentMode: .fit)
                        .padding(.horizontal, 8)
                    }
                    .offset(y: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                isDragging = true
                                dragOffset = gesture.translation.height
                            }
                            .onEnded { gesture in
                                isDragging = false
                                let threshold: CGFloat = 20 // Adjust this value to change the snap threshold
                                
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if abs(gesture.translation.height) < threshold {
                                        // Snap back if threshold not met
                                        dragOffset = 0
                                    } else {
                                        // Snap to the direction of the drag
//                                        dragOffset = gesture.translation.height > 0 ? threshold : -threshold
                                        dragOffset = 0
                                        
                                        let verticalAmount = gesture.translation.height
                                        if abs(verticalAmount) > threshold { // Threshold to avoid tiny movements
                                            if verticalAmount > 0 {
                                                // Sliding down
                                                print("Sliding down: \(verticalAmount)")
                                                mapState.presentProblemDetails = false
                                            } else {
                                                // Sliding up
                                                print("Sliding up: \(abs(verticalAmount))")
                                                presentFullScreen = true
                                            }
                                        }
                                    }
                                }
                            }
                    )
                    .simultaneousGesture(
                        MagnificationGesture()
                            .onChanged { scale in
                                presentFullScreen = true
                            }
//                            .onEnded { scale in
//                                presentFullScreen = true
//                            }
                    )
                    
                    .padding(.bottom, 16)
                    .zIndex(.infinity)
                }

                
//                if mapState.presentProblemDetails { //} selectedProblem != Problem.empty {
//                    GeometryReader { geo in
//                        VStack {
//                            Spacer()
//                            
//                            VStack(spacing: 0) {
//                                
//                                if mapState.presentProblemDetails && !mapState.showAllStarts {
//                                    infosCard
//                                        .background(Color.white)
//                                }
//                                
//                                
//                                ZStack(alignment: .topTrailing) {
//                                    
//                                    TopoView(
//                                        problem: $mapState.selectedProblem,
//                                        mapState: mapState,
//                                        selectedDetent: $selectedDetent
//                                    )
//                                    .frame(width: geo.size.width, height: geo.size.width * 3/4)
//                                    .toolbar(.hidden, for: .tabBar)
////                                    .onAppear {
////                                        mapState.showAllStarts = true
////                                    }
//                                    .modify {
//                                        if #available(iOS 18.0, *) {
//                                            $0.matchedTransitionSource(id: "photo", in: namespace)
//                                        } else {
//                                            // Fallback on earlier versions
//                                        }
//                                    }
//                                    .navigationDestination(isPresented: $mapState.presentStartSheet)
//                                    {
//                                            TopoView(
//                                                problem: $mapState.selectedProblem,
//                                                mapState: mapState,
//                                                selectedDetent: $selectedDetent
//                                            )
//                                            .modify {
//                                                if #available(iOS 18.0, *) {
//                                                    $0
//                                                        .matchedTransitionSource(id: "photo", in: namespace) // reuse same ID/namespace
//                                                        .navigationTransition(.zoom(sourceID: "photo", in: namespace))
//                                                } else {
//                                                    // Fallback on earlier versions
//                                                }
//                                                
//                                            }
//                                            .navigationTitle(problem.localizedName)
//                                            .navigationBarTitleDisplayMode(.inline)
//                                            
//                                            
//                                        }
//                                    
//                                    //                        .clipShape(RoundedRectangle(cornerRadius: 8))
//                                    //                        .zIndex(10)
//                                    
//                                    Button {
//                                        mapState.presentProblemDetails = false
//                                    } label: {
//                                        Image(systemName: "xmark.circle.fill")
//                                            .font(Font.title2.weight(.semibold))
//                                            .foregroundColor(Color(.secondaryLabel))
//                                            .padding()
//                                        //                                        .padding(.horizontal, 16)
//                                    }
//                                }
//                            }
//                        }
//                        //                .padding(8)
//                        
//                    }
//                    .zIndex(40)
//                }
                
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
    
    var infosCard: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                
                ProblemCircleView(problem: problem)
                
                Text(problem.localizedName)
                    .font(.body)
                //                            .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .fixedSize(horizontal: false, vertical: true)
                    .minimumScaleFactor(0.5)
                
//                Spacer()
                
                if(problem.sitStart) {
                    Image(systemName: "figure.rower")
//                    Text("problem.sit_start")
//                        .font(.body)
                }

                    Text(problem.grade.string)
                        .font(.body)
                
                Spacer()
                
                Button {
                    mapState.showAllStarts = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(Font.title2.weight(.semibold))
                        .foregroundColor(Color(.secondaryLabel))
                }

            }
            
//            HStack(alignment: .firstTextBaseline) {
//                
//                if(problem.sitStart) {
//                    Image(systemName: "figure.rower")
//                    Text("problem.sit_start")
//                        .font(.body)
//                }
//                
//                Spacer()
//
//            }
        }
        
        .padding(.horizontal)
        .padding(.vertical)
    }
    
    var problem : Problem {
        mapState.selectedProblem
    }
    
    var selectedStart: some View {
        
                HStack {
                    
                    
                    Spacer()
                    
                    HStack {
                        ProblemCircleView(problem: problem, isDisplayedOnPhoto: true)
                        
                        Text(problem.localizedName)
                            .font(.body)
                        Text(problem.grade.string)
                            .font(.body)
                    }
                    
                    Spacer()
                    
                    Button {
                        mapState.showAllStarts = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(Font.body.weight(.semibold))
                            .foregroundColor(Color(.secondaryLabel))
                        //                                        .padding(.horizontal, 16)
                    }
                    
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(.regularMaterial)
                //                            .clipShape(RoundedRectangle(cornerRadius: 8))
                //                            .zIndex(20)
            
        
    }
    
    @State private var sheetPresented = true
    
    var mapbox : some View {
        MapboxView(mapState: mapState)
            .edgesIgnoringSafeArea(.all)
            .ignoresSafeArea(.keyboard)
            .background(
                PoiActionSheet(
                    name: (mapState.selectedPoi?.name ?? ""),
                    googleUrl: URL(string: mapState.selectedPoi?.googleUrl ?? ""),
                    presentPoiActionSheet: $mapState.presentPoiActionSheet
                )
            )
//            .sheet(isPresented: $sheetPresented) {
//                VStack {
//                    if false { // mapState.selectedProblem != Problem.empty {
//                        HStack {
//                            Text(mapState.selectedProblem.localizedName)
//                                .font(.title2.weight(.semibold))
//                            Spacer()
//                        }
//                        .padding(.horizontal)
//                    }
//                    else {
//                        Text("12 problems")
//                    }
//                }
//                    .presentationDetents([.height(70), .large])
//                    .presentationBackgroundInteraction(.enabled)
//            }
            
           .fullScreenCover(isPresented: $presentFullScreen) {
               BoulderFullScreenView(mapState: mapState, animation: animation)
               
           }
            
//            .background(
//                CustomNoClipSheet(
//                    isPresented: $mapState.presentProblemDetails,
//                    detents: [.medium()], // [UISheetPresentationController.Detent.custom { _ in 340 }],  // FIXME: make DRY
//                    prefersGrabber: false)
//                {
//                    ProblemDetailsView(
//                        problem: $mapState.selectedProblem,
//                        mapState: mapState,
//                        selectedDetent: $selectedDetent
//                    )
////                    VStack {
////                        TopoView(
////                            problem: $mapState.selectedProblem,
////                            mapState: mapState,
////                            selectedDetent: $selectedDetent
////                        )
////                        
////                        PageControlView(numberOfPages: 5, currentPage: 1)
////                        
////                        Spacer()
////                    }
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
                            .background(.thinMaterial)
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
                    let customDetent = UISheetPresentationController.Detent.custom { _ in 354 } // UISheetPresentationController.Detent.medium() // UISheetPresentationController.Detent.custom { _ in 340 } // FIXME: make DRY
                    sheet.detents = [customDetent]
                    sheet.prefersGrabberVisible = prefersGrabber
                    sheet.preferredCornerRadius = 0
                    sheet.largestUndimmedDetentIdentifier = customDetent.identifier
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
