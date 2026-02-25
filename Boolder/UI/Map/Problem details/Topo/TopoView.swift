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
    var onBackgroundTap: (() -> Void)? = nil
    var skipInitialBounceAnimation: Bool = false
    
    private var showAllLines: Bool {
        mapState.isInTopoMode
    }
    
    @State private var isInitialLoad = true
    
    @State private var bounceAnimation = false
    @State private var paginationPosition: Line.PhotoPercentCoordinate?
    @State private var showProblemNameLabel = false
    @State private var nameLabelTask: Task<Void, Never>?
    
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
            case .rest: return .spring(duration: 0.033)
            case .up1, .down1: return .spring(duration: 0.109)
            case .up2, .down2: return .spring(duration: 0.066)
            case .up3, .down3: return .spring(duration: 0.039)
            case .up4, .down4: return .spring(duration: 0.023)
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            switch photoStatus {
            case .ready(let image):
                readyPhotoContent(image: image)
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .none:
                Image("nophoto")
                    .font(.system(size: 60))
                    .foregroundColor(Color.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .noInternet, .timeout, .error:
                errorRetryContent
            case .initial:
                EmptyView()
            }
        }
        .aspectRatio(4/3, contentMode: .fit)
        .background(Color(.imageBackground))
        .onChange(of: photoStatus) { _, newValue in
            if case .ready = newValue {
                displayLine()
                displayNameLabel()
                animateBounceIfAllowed()
            }
        }
        .onChange(of: mapState.isInTopoMode) { oldValue, newValue in
            if oldValue && !newValue {
                displayNameLabel()
            }
        }
        .onChange(of: problem) { oldValue, newValue in
            paginationPosition = newValue.startGroup?.paginationPosition
            
            if oldValue.topoId == newValue.topoId {
                lineDrawPercentage = 0.0
                displayLine()
                displayNameLabel()
                animateBounceIfAllowed()
            }
            else {
                lineDrawPercentage = 0.0
                nameLabelTask?.cancel()
                showProblemNameLabel = false
                Task {
                    await loadData()
                }
            }
        }
        .task {
            paginationPosition = problem.startGroup?.paginationPosition
            await loadData()
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func readyPhotoContent(image: UIImage) -> some View {
        let allProblems = problem.startGroups.flatMap { group in
            group.problems.map { p in
                ProblemWithGroup(problem: p, inGroup: group.problems.contains(problem), index: group.problems.firstIndex(of: p), count: group.problems.count)
            }
        }
        let indexedProblems = Array(allProblems.enumerated())
        
        Group {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            if !showAllLines && problem.line?.coordinates != nil {
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
                problemOverlay(in: geo, indexedProblems: indexedProblems)
            }
            
            GeometryReader { geo in
                TapLocationView { location in
                    handleTap(at: Line.PhotoPercentCoordinate(x: location.x / geo.size.width, y: location.y / geo.size.height))
                }
            }
            
            if showAllLines {
                allLinesOverlay
            }
        }
    }
    
    @ViewBuilder
    private func problemOverlay(in geo: GeometryProxy, indexedProblems: [(offset: Int, element: ProblemWithGroup)]) -> some View {
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
        
        if !showAllLines, let gradePoint = problem.lineGradePoint {
            GradeLabelView(grade: problem.grade.string, color: problem.circuitUIColorForPhotoOverlay)
                .scaleEffect(counterZoomScale.wrappedValue)
                .position(x: gradePoint.x * geo.size.width, y: gradePoint.y * geo.size.height)
                .allowsHitTesting(false)
        }
        
        if !showAllLines, showProblemNameLabel, let lastPoint = problem.lineLastPoint, !problem.localizedName.isEmpty {
            let labelPos = clampedNameLabelPosition(name: problem.localizedName, lastPoint: lastPoint, geoSize: geo.size, scale: counterZoomScale.wrappedValue)
            ProblemNameLabelView(name: problem.localizedName, color: problem.circuitUIColorForPhotoOverlay)
                .scaleEffect(counterZoomScale.wrappedValue)
                .position(x: labelPos.x, y: labelPos.y)
                .allowsHitTesting(false)
                .transition(.opacity)
        }
        
        if !showAllLines, let paginationPos = paginationPosition, mapState.currentSelectionSource == .map || mapState.currentSelectionSource == .circleView, !(skipInitialBounceAnimation && isInitialLoad) {
            StartGroupMenuView(problem: $problem)
                .scaleEffect(counterZoomScaleIdentity)
                .position(x: paginationPos.x * geo.size.width, y: paginationPos.y * geo.size.height + 32 * counterZoomScale.wrappedValue)
        }
    }
    
    @ViewBuilder
    private var allLinesOverlay: some View {
        let otherProblems = problem.otherProblemsOnSameTopo
        
        ZStack {
            ForEach(otherProblems, id: \.id) { p in
                if p.line?.coordinates != nil {
                    TappableLineView(problem: p, counterZoomScale: counterZoomScale) {
                        mapState.selectProblem(p)
                    }
                    .zIndex(p.zIndex)
                }
            }
        }
        
        GeometryReader { geo in
            ZStack {
                ForEach(otherProblems, id: \.id) { p in
                    if let firstPoint = p.lineFirstPoint {
                        ProblemCircleView(problem: p, isDisplayedOnPhoto: true)
                            .allowsHitTesting(false)
                            .scaleEffect(counterZoomScale.wrappedValue)
                            .position(x: firstPoint.x * geo.size.width, y: firstPoint.y * geo.size.height)
                            .zIndex(p.zIndex)
                    }
                }
            }
        }
        
        GeometryReader { geo in
            ZStack {
                ForEach(otherProblems, id: \.id) { p in
                    if let gradePoint = p.lineGradePoint {
                        GradeLabelView(grade: p.grade.string, color: p.circuitUIColorForPhotoOverlay)
                            .scaleEffect(counterZoomScale.wrappedValue)
                            .position(x: gradePoint.x * geo.size.width, y: gradePoint.y * geo.size.height)
                            .zIndex(p.zIndex)
                            .onTapGesture {
                                mapState.selectProblem(p)
                            }
                    }
                }
            }
        }
        
        GeometryReader { geo in
            let lastPoints = Dictionary(
                uniqueKeysWithValues: otherProblems.compactMap { p in
                    p.lineLastPoint.map { (p.id, $0) }
                }
            )
            let visibleIds = visibleNameLabelIds(
                problems: otherProblems,
                lastPoints: lastPoints,
                geoSize: geo.size
            )
            
            ZStack {
                ForEach(otherProblems, id: \.id) { p in
                    if let lastPoint = lastPoints[p.id], !p.localizedName.isEmpty {
                        let isVisible = visibleIds.contains(p.id)
                        let labelPos = clampedNameLabelPosition(name: p.localizedName, lastPoint: lastPoint, geoSize: geo.size, scale: counterZoomScale.wrappedValue)
                        ProblemNameLabelView(name: p.localizedName, color: p.circuitUIColorForPhotoOverlay)
                            .scaleEffect(counterZoomScale.wrappedValue)
                            .position(x: labelPos.x, y: labelPos.y)
                            .zIndex(p.zIndex)
                            .opacity(isVisible ? 1 : 0)
                            .allowsHitTesting(isVisible)
                            .onTapGesture {
                                mapState.selectProblem(p)
                            }
                    }
                }
            }
        }
    }
    
    private var errorRetryContent: some View {
        VStack(spacing: 16) {
            switch photoStatus {
            case .noInternet:
                Text("problem.topo.no_internet")
                    .foregroundColor(Color.gray)
            case .timeout:
                Text("problem.topo.timeout")
                    .foregroundColor(Color.gray)
            default:
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
    
    // The UI above the photo (lines, circle views, ...) should get a little smaller as the user zooms into the photo
    var counterZoomScale: Binding<CGFloat> {
        Binding(
            get: { 1/((zoomScale / 2) + 0.5) },
            set: { _ in } // Read-only
        )
    }
    
    // Exactly cancels the zoom scale (1:1 ratio)
    var counterZoomScaleIdentity: CGFloat {
        1 / zoomScale
    }
    
    /// Clamps the name label center so it stays fully within the photo bounds.
    func clampedNameLabelPosition(name: String, lastPoint: Line.PhotoPercentCoordinate, geoSize: CGSize, scale: CGFloat) -> CGPoint {
        let labelWidth = (CGFloat(name.count) * 7 + 12) * scale
        let labelHeight: CGFloat = 18 * scale
        let rawX = lastPoint.x * geoSize.width
        let rawY = lastPoint.y * geoSize.height - 14 * scale
        let clampedX = max(labelWidth / 2, min(rawX, geoSize.width - labelWidth / 2))
        let clampedY = max(labelHeight / 2, min(rawY, geoSize.height - labelHeight / 2))
        return CGPoint(x: clampedX, y: clampedY)
    }

    /// Returns the set of problem IDs whose name labels can be displayed without overlapping.
    /// Problems with highest zIndex get priority.
    func visibleNameLabelIds(problems: [Problem], lastPoints: [Int: Line.PhotoPercentCoordinate], geoSize: CGSize) -> Set<Int> {
        let scale = counterZoomScale.wrappedValue
        
        let sorted = problems
            .filter { lastPoints[$0.id] != nil && !$0.localizedName.isEmpty }
            .sorted { $0.zIndex > $1.zIndex }
        
        var occupiedRects: [CGRect] = []
        var visibleIds = Set<Int>()
        
        for p in sorted {
            guard let lastPoint = lastPoints[p.id] else { continue }
            
            let labelWidth = (CGFloat(p.localizedName.count) * 7 + 12) * scale
            let labelHeight: CGFloat = 18 * scale
            
            let center = clampedNameLabelPosition(name: p.localizedName, lastPoint: lastPoint, geoSize: geoSize, scale: scale)
            
            let rect = CGRect(
                x: center.x - labelWidth / 2,
                y: center.y - labelHeight / 2,
                width: labelWidth,
                height: labelHeight
            )
            
            let hasOverlap = occupiedRects.contains { $0.intersects(rect) }
            
            if !hasOverlap {
                occupiedRects.append(rect)
                visibleIds.insert(p.id)
            }
        }
        
        return visibleIds
    }
    
    func displayNameLabel() {
        nameLabelTask?.cancel()
        showProblemNameLabel = true
        nameLabelTask = Task {
            try? await Task.sleep(for: .seconds(2))
            if !Task.isCancelled {
                withAnimation { showProblemNameLabel = false }
            }
        }
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
            await MainActor.run {
                photoStatus = .none
            }
            return
        }
        
        if let photo = await TopoImageCache.shared.image(for: topo) {
            await MainActor.run {
                self.photoStatus = .ready(image: photo)
            }
            return
        }
        
        await downloadPhoto(topo: topo)
    }
    
    func downloadPhoto(topo: Topo) async {
        await MainActor.run {
            photoStatus = .loading
        }
        
        let result = await Downloader().downloadFile(topo: topo)
        if result == .success
        {
            if let photo = await TopoImageCache.shared.image(for: topo) {
                await MainActor.run {
                    self.photoStatus = .ready(image: photo)
                }
                return
            }
        }
        else if result == .noInternet {
            await MainActor.run {
                self.photoStatus = .noInternet
            }
            return
        }
        else if result == .timeout {
            await MainActor.run {
                self.photoStatus = .timeout
            }
            return
        }
        
        await MainActor.run {
            self.photoStatus = .error
        }
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
                isInitialLoad = false
                mapState.selectProblem(next, source: .circleView)
            }
        }
        else {
            if let topProblem = group.topProblem {
                isInitialLoad = false
                mapState.selectProblem(topProblem, source: .circleView)
            }
        }
    }
    
    func handleTapOnBackground() {
        onBackgroundTap?()
    }
    
    func animateBounceIfAllowed() {
        if skipInitialBounceAnimation && isInitialLoad { return }
        
        switch mapState.currentSelectionSource {
        case .circleView, .map:
            bounceAnimation.toggle()
        case .other:
            break
        }
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
