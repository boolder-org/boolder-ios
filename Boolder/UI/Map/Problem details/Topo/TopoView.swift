//
//  TopoView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 21/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopoView: View {
    @Binding var problem: Problem
    @Environment(MapState.self) private var mapState: MapState
    @State private var lineDrawPercentage: CGFloat = .zero
    @State private var photoStatus: PhotoStatus = .initial
    @State private var showMissingLineNotice = false
    
    @Binding var zoomScale: CGFloat
    var onBackgroundTap: (() -> Void)?
    
    @State private var bounceAnimation = false
    
    struct ProblemWithGroup: Identifiable {
        let problem: Problem
        let inGroup: Bool
        let index: Int?
        let count: Int
        
        internal var id: Int { problem.id }
    }
    
    enum BouncePhase: CaseIterable {
        case rest
        case up1, down1
        case up2, down2
        case up3, down3
        case up4, down4
        
        var yOffset: CGFloat {
            switch self {
            case .rest, .down1, .down2, .down3, .down4: return 0
            case .up1: return -20      // 100/5
            case .up2: return -7.2     // 36/5
            case .up3: return -2.6     // 12.96/5
            case .up4: return -0.93    // 4.67/5
            }
        }
        
        var animation: Animation {
            switch self {
            case .rest: return .easeOut(duration: 0.033)
            case .up1, .down1: return .easeOut(duration: 0.109)
            case .up2, .down2: return .easeOut(duration: 0.066)
            case .up3, .down3: return .easeOut(duration: 0.039)
            case .up4, .down4: return .easeOut(duration: 0.023)
            }
        }
    }
    
    var body: some View {
        let allProblems = problem.startGroups.flatMap { group in
            group.problems.map { p in
                ProblemWithGroup(problem: p, inGroup: group.problems.contains(problem), index: group.problems.firstIndex(of: p), count: group.problems.count)
            }
        }
        let indexedProblems = Array(allProblems.enumerated())
        ZStack(alignment: .center) {
            if case .ready(let image) = photoStatus  {
                Group {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    if problem.line?.coordinates != nil {
                        LineView(problem: problem, drawPercentage: $lineDrawPercentage, counterZoomScale: counterZoomScale)
                    }
                    else {
                        Text("problem.missing_line")
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .modify {
                                if #available(iOS 26, *) {
                                    $0.glassEffect()
                                }
                                else {
                                    $0.background(Color.gray.opacity(0.8))
                                        .foregroundColor(Color(UIColor.systemBackground))
                                        .cornerRadius(16)
                                }
                            }
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
                                    .modifier(BounceModifier(
                                        shouldAnimate: pWithGroup.inGroup && p != problem,
                                        trigger: bounceAnimation,
                                        delay: Double(pow(Double(pWithGroup.index ?? 0), 0.7) * 0.033)
                                    ))
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
                animateBounce()
            default:
                print("")
            }
        }
        .onChange(of: problem) { oldValue, newValue in
            animateBounce()
            
            if oldValue.topoId == newValue.topoId {
                lineDrawPercentage = 0.0
                
                displayLine()
            }
            else {
                lineDrawPercentage = 0.0
                
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
        // Don't show "no photo" for the empty placeholder problem
        guard problem.id != 0 else { return }
        
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
    }
    
    struct BounceModifier: ViewModifier {
        let shouldAnimate: Bool
        let trigger: Bool
        let delay: Double
        
        @State private var delayedTrigger = false
        
        func body(content: Content) -> some View {
            if shouldAnimate {
                content
                    .phaseAnimator(BouncePhase.allCases, trigger: delayedTrigger) { view, phase in
                        view.offset(y: phase.yOffset)
                    } animation: { phase in
                        phase.animation
                    }
                    .onChange(of: trigger) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            delayedTrigger.toggle()
                        }
                    }
            } else {
                content
            }
        }
    }
}

//struct TopoView_Previews: PreviewProvider {
//    static let dataStore = DataStore()
//    
//    static var previews: some View {
//        TopoView(problem: .constant(dataStore.problems.first!), areaResourcesDownloaded: .constant(true), scale: .constant(1))
//    }
//}
