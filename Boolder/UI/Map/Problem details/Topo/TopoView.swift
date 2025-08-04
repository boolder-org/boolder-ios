//
//  TopoView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 21/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopoView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var problem: Problem
    @Environment(MapState.self) private var mapState: MapState
    @State private var lineDrawPercentage: CGFloat = 1.0
    @State private var photoStatus: PhotoStatus = .initial
    @State private var showMissingLineNotice = false
    
    @Binding var zoomScale: CGFloat
    var onBackgroundTap: (() -> Void)?
    
    @State private var bounceAnimation = false
    
    struct ProblemWithGroup: Identifiable {
        let problem: Problem
        let inGroup: Bool
        
        internal var id: Int { problem.id }
    }
    
    var body: some View {
        let allProblems = problem.startGroups.flatMap { group in
            group.problems.map { p in
                ProblemWithGroup(problem: p, inGroup: group.mainGroup)
            }
        }
        let indexedProblems = Array(allProblems.enumerated())
        
        return ZStack(alignment: .center) {
            if case .ready(let image) = photoStatus  {
                Group {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    if problem.line?.coordinates != nil {
                        LineView(problem: problem, drawPercentage: $lineDrawPercentage, counterZoomScale: counterZoomScale)
                        
                        GeometryReader { geo in
                            if let middlePoint = problem.overlayBadgePosition {
                                GradeBadgeView(number: problem.grade.string, sitStart: problem.sitStart, color: problem.circuitUIColorForPhotoOverlay)
                                    .scaleEffect(counterZoomScale.wrappedValue)
                                    .position(x: middlePoint.x * geo.size.width, y: middlePoint.y * geo.size.height)
                                    .zIndex(.infinity)
                            }
                            
                            if problem.sitStart {
                                if let firstPoint = problem.lineFirstPoint {
                                    
                                    HStack {
                                        Image(systemName: "figure.rower")
                                        Text("assis")
                                        //                                        .font(.body)
                                        
                                    }
                                    .foregroundColor(.primary.opacity(0.8))
                                    .font(.caption)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    //                                .background { Color(problem.circuitUIColor) }
                                    //                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 4))
                                    .scaleEffect(counterZoomScale.wrappedValue)
                                    .position(x: firstPoint.x * geo.size.width, y: firstPoint.y * geo.size.height)
                                    .offset(x: 0, y: (problem.isCircuit ? 28 : 24) * counterZoomScale.wrappedValue)
                                    .zIndex(.infinity)
                                }
                            }
                        }
                    }
                    else {
                        Text("problem.missing_line")
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.gray.opacity(0.8))
                            .foregroundColor(Color(UIColor.systemBackground))
                            .cornerRadius(16)
                            .transition(.opacity)
                            .opacity(showMissingLineNotice ? 1.0 : 0.0)
                    }
                    
                    GeometryReader { geo in
                        ForEach(indexedProblems, id: \.element.id) { idx, pWithGroup in
                            let p = pWithGroup.problem
                            if let firstPoint = p.lineFirstPoint {
                                ProblemCircleView(problem: p, isDisplayedOnPhoto: true)
                                    .allowsHitTesting(false)
                                    .scaleEffect(counterZoomScale.wrappedValue)
                                    .position(x: firstPoint.x * geo.size.width, y: firstPoint.y * geo.size.height)
                                    .zIndex(p == problem ? .infinity : p.zIndex)
                                    .modify {
                                        if pWithGroup.inGroup && p != problem {
                                            $0
                                                // https://chatgpt.com/c/688dc673-12a4-832b-a1c6-bd8040ba8047
                                                .keyframeAnimator(initialValue: CGFloat(0), trigger: bounceAnimation) { content, y in
                                                    content.offset(y: y)
                                                } keyframes: { _ in
                                                    KeyframeTrack(\.self) {
                                                        // Physics-ish timing (points, not pixels):
                                                        // g ≈ 3300 pt/s², e ≈ 0.6
                                                        // Heights: 100, 36, 12.96, 4.67
                                                        // Half-bounce times t = sqrt(2h/g): 0.246, 0.148, 0.089, 0.053 s

                                                        // Up 100, down to floor
                                                        CubicKeyframe(-100/2,  duration: 0.246)
                                                        CubicKeyframe(   0,  duration: 0.246)

                                                        // Diminishing bounces (never below 0)
                                                        CubicKeyframe( -36/2,  duration: 0.148)
                                                        CubicKeyframe(   0,  duration: 0.148)
                                                        CubicKeyframe(-12.96/2, duration: 0.089)
                                                        CubicKeyframe(     0, duration: 0.089)
                                                        CubicKeyframe( -4.67/2, duration: 0.053)
                                                        CubicKeyframe(   0,  duration: 0.053)

                                                        // Hold at rest
                                                        CubicKeyframe(0, duration: 0.30)
                                                    }
                                                }
                                        }
                                        else {
                                            $0
                                        }
                                    }
                                    
                            }
                            
                        }
                        
                        
                    }
                    
                    GeometryReader { geo in
                        TapLocationView { location in
                            handleTap(at: Line.PhotoPercentCoordinate(x: location.x / geo.size.width, y: location.y / geo.size.height))
                        }
                    }
                }
            }
            else if case .loading = photoStatus {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if case .none = photoStatus {
                Image("nophoto")
                    .font(.system(size: 60))
                    .foregroundColor(Color.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if photoStatus == .noInternet || photoStatus == .timeout || photoStatus == .error {
                VStack(spacing: 16) {
                    if photoStatus == .noInternet {
                        Text("problem.topo.no_internet")
                            .foregroundColor(Color.gray)
                    }
                    else if photoStatus == .timeout {
                        Text("problem.topo.timeout")
                            .foregroundColor(Color.gray)
                    }
                    else {
                        Text("problem.topo.error")
                            .foregroundColor(Color.gray)
                    }
                    
                    Button {
                        Task {
                            await loadData()
                        }
                    } label: {
                        
                        Label {
                            Text("problem.topo.retry")
                        } icon: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(.gray.opacity(0.2))
                        .clipShape(Capsule())
                    }
                    .foregroundColor(Color.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                EmptyView()
            }
        }
        .aspectRatio(4/3, contentMode: .fit)
        .background(Color(.imageBackground))
        .onChange(of: photoStatus) { oldValue, newValue in
            switch newValue {
            case .ready(image: _):
                displayLine()
            default:
                print("")
            }
        }
        .onChange(of: problem) { oldValue, newValue in

//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                animateBounce()
//            }
            
            if oldValue.topoId == newValue.topoId {
//                lineDrawPercentage = 0.0
//                
//                displayLine()
            }
            else {
//                lineDrawPercentage = 0.0
                
                Task {
                    await loadData()
                }
            }
            
        }
        .task {
            await loadData()
        }
    }
    
    // The UI above the photo (lines, circle views, ...) should get a little smaller as the user zooms into the photo
    var counterZoomScale: Binding<CGFloat> {
        Binding(
            get: { 1/((zoomScale / 2) + 0.5) },
            set: { _ in } // Read-only
        )
    }
    
    func displayLine() {
        if problem.line?.coordinates != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animate { lineDrawPercentage = 1.0 }
                showMissingLineNotice = false
            }
        }
        else {
            withAnimation { showMissingLineNotice = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation { showMissingLineNotice = false }
            }
        }
    }
    
    func loadData() async {
        guard let topo = problem.topo else {
            photoStatus = .none
            return
        }
        
        if let photo = problem.onDiskPhoto {
            self.photoStatus = .ready(image: photo)
            return
        }
        
        await downloadPhoto(topo: topo)
    }
    
    func downloadPhoto(topo: Topo) async {
        photoStatus = .loading
        
        let result = await Downloader().downloadFile(topo: topo)
        if result == .success
        {
            // TODO: move this logic to Downloader
            if let photo = problem.onDiskPhoto {
                self.photoStatus = .ready(image: photo)
                return
            }
        }
        else if result == .noInternet {
            self.photoStatus = .noInternet
            return
        }
        else if result == .timeout {
            self.photoStatus = .timeout
            return
        }
        
        self.photoStatus = .error
        return
    }
    
    enum PhotoStatus: Equatable {
        case initial
        case none
        case loading
        case ready(image: UIImage)
        case noInternet
        case timeout
        case error
    }
    
    func animate(action: () -> Void) {
        withAnimation(Animation.easeInOut(duration: 0.4)) {
            action()
        }
    }
    
    func handleTap(at tapPoint: Line.PhotoPercentCoordinate) {
        let groups = problem.startGroups
            .filter { $0.distance(to: tapPoint) < 0.1 }
            .sorted { $0.distance(to: tapPoint) < $1.distance(to: tapPoint) }
        
        guard let group = groups.first else {
            return handleTapOnBackground()
        }
        
        if group.problems.contains(problem) {
            if let next = group.next(after: problem) {
                mapState.selectProblem(next)
            }
        }
        else {
            if let topProblem = group.topProblem {
                mapState.selectProblem(topProblem)
            }
        }
    }
    
    func handleTapOnBackground() {
        onBackgroundTap?()
    }
    
    func animateBounce() {
        bounceAnimation.toggle()
        
//        // First, animate to bounce position
//        yOffset = -40
//        
//        // Then animate back to original position
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//            yOffset = 0
//        }
        
        // First, immediately set to bounce position (no animation)
//            yOffset = -100
        
        // Then animate back to 0 with a spring
//            withAnimation(.interpolatingSpring(stiffness: 100, damping: 8)) {
//                yOffset = -100
//            }
    }
}

//struct TopoView_Previews: PreviewProvider {
//    static let dataStore = DataStore()
//    
//    static var previews: some View {
//        TopoView(problem: .constant(dataStore.problems.first!), areaResourcesDownloaded: .constant(true), scale: .constant(1))
//    }
//}
