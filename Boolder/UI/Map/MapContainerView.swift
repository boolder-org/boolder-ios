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
    static let smallDetent = PresentationDetent.height(80) // PresentationDetent.height(UIScreen.main.bounds.width*3/4 + 96)
    
    @State private var zoomScale: CGFloat = 1

    @State private var presentFullScreen = false
    @Namespace private var animation
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    @State private var showTopoButtons = false
    
    @Environment(\.openURL) var openURL

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
                        .opacity(mapState.presentProblemDetails ? 0 : 1)
                    
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
//                            mapState.showAllStarts = true
//                            
//                        } label: {
//                            Text("all starts")
//                        }
                        
                        if false { //} !mapState.anyStartSelected && problem != Problem.empty {
                            
                            HStack {
                                Spacer()
                                
                                HStack {
                                    Text(problem.localizedName)
                                        .font(.body)
                                    
                                    Text(problem.grade.string)
                                        .font(.body)
                                }
                                
                                Spacer()
                                
                                Button(action: {

                                }) {
                                    HStack(alignment: .center, spacing: 8) {
                                        Image(systemName: "ellipsis")
//                                        Text("Bleau.info").fixedSize(horizontal: true, vertical: true)
                                    }
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.5), in: Circle())
                                }
//                                .buttonStyle(Pill(fill: true))
                            }
                            .padding(8)
                            .background(Color.systemBackground)
                            .clipShape(.rect(cornerRadius: 8))
                            .padding(.horizontal, 8)
                        }
                        
                        
//                        ZoomableScrollView(zoomScale: $zoomScale) {
//                            TopoView(
//                                topo: mapState.selectedProblem.topo!,
//                                problem: $mapState.selectedProblem,
//                                mapState: mapState,
//                                zoomScale: $zoomScale
//                            )
                        if !presentFullScreen {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    topoViewWithButtons
                                }
                                .scrollTargetLayout()
                            }
                            .contentMargins(.horizontal, 8, for: .scrollContent)
                            .scrollTargetBehavior(.viewAligned)
//                            .onScrollPhaseChange { old, new, context in
//                                print("phase change")
////                                print(new)
////                                print(context)
//                                if new == .interacting {
//                                    mapState.showAllStarts = true
//                                }
//                            }
                        } else {
                            Rectangle()
                            .background(Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .aspectRatio(4/3, contentMode: .fit)
                            .opacity(0)
                            .padding(.horizontal, 8)
                        }
                        
                    }
                    .offset(y: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                isDragging = true
                                dragOffset = gesture.translation.height
                                
                                if gesture.translation.height < -20 {
                                    animatePresentFullScreen()
                                }
                                
                                if abs(gesture.translation.width) > 20 {
                                    mapState.showAllStarts = true
                                }
                            }
                            .onEnded { gesture in
                                isDragging = false
                                let threshold: CGFloat = 50 // Adjust this value to change the snap threshold
                                
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
                                animatePresentFullScreen()
                            }
//                            .onEnded { scale in
//                                presentFullScreen = true
//                            }
                    )
                    
                    .padding(.bottom, 16)
                    .zIndex(40)
                }
                    
                if presentFullScreen {
                    BoulderFullScreenView(mapState: mapState, presentFullScreen: $presentFullScreen, animation: animation)
//                        .opacity(presentFullScreen ? 1 : 0)
                        .zIndex(50)
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

    func tapOnBackground() {
//        withAnimation(.easeIn(duration: 0.5)) {
            showTopoButtons = true
//        }
        
        // Hide buttons after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            withAnimation(.easeOut(duration: 0.5)) {
                showTopoButtons = false
//            }
        }
        
        mapState.showAllStarts = true
    }
    
    func animatePresentFullScreen() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            presentFullScreen = true
        }
    }
    
    var topoViewWithButtons: some View {
        TopoView(
            //                                topo: mapState.selectedProblem.topo!,
            problem: $mapState.selectedProblem,
            mapState: mapState,
            zoomScale: $zoomScale,
            onBackgroundTap: {
                tapOnBackground()
            })
        
        .matchedGeometryEffect(id: "photo", in: animation)
        .containerRelativeFrame(.horizontal, count: 1, spacing: 8)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            HStack {
                if mapState.showAllStarts {
                    
                    
                    Button {
                        animatePresentFullScreen()
                    } label: {
                        //                    Image(systemName: "arrow.down.backward.and.arrow.up.forward")
                        //                        .font(.headline)
                        //                        .foregroundColor(.primary)
                        //                        .padding(8)
                        //                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        //                        .padding(8)
                        Image(systemName: "chevron.up")
                            .font(.headline)
                            .frame(width: 12, height: 12)
                            .foregroundColor(.primary)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                            .padding(8)
                    }
                }
                
                Spacer()
                
//                Button {
//                    mapState.presentProblemDetails = false
//                } label: {
//                    Image(systemName: "xmark")
//                        .font(.headline)
//                        .frame(width: 16, height: 16)
//                        .foregroundColor(.primary)
//                        .padding(8)
//                        .background(.ultraThinMaterial, in: Circle())
//                        .padding(8)
//                }
                
                if !mapState.anyStartSelected && problem != Problem.empty {
                    Button {
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.headline)
                            .frame(width: 12, height: 12)
                            .foregroundColor(.primary)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                            .padding(8)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//            .opacity(showTopoButtons ? 1 : 0)
        }
//                                    .aspectRatio(4/3, contentMode: .fit)
        
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
//            .onChange(of: presentFullScreen) { old, newValue in
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    sheetPresented = newValue
//                }
//            }
        

            
//           .fullScreenCover(isPresented: $presentFullScreen) {
//               BoulderFullScreenView(mapState: mapState, animation: animation)
//               
//           }
            
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
