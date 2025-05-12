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
    
    let topo: Topo // FIXME: what happends when page changes?
    @Binding var problem: Problem
    @ObservedObject var mapState: MapState
    @State private var lineDrawPercentage: CGFloat = .zero
    @State private var photoStatus: PhotoStatus = .initial
    @State private var presentTopoFullScreenView = false
    @State private var showMissingLineNotice = false
    @State private var zoomScale: CGFloat = 1.0
    @State private var highlightedSide: String? = nil
    
    @Binding var selectedDetent: PresentationDetent
    
    @State private var offset = CGSize.zero
    @State private var lastGestureTime: TimeInterval = 0
    
//    var topo: Topo {
//        problem.topo! // FIXME: don't use bang
//    }
    
//    @StateObject private var motion = MotionManager()
    
    private let responseCurve: Double = 0.5

    private func curved(_ normalized: Double) -> Double {
      let s = normalized >= 0 ? 1.0 : -1.0
      return s * pow(abs(normalized), responseCurve)
    }

    private var xOffset: CGFloat {
      // roll / π gives you a normalized –1…1
//      let norm = motion.roll / .pi
//      return CGFloat(curved(norm)) * 4
        return 2
    }

    private var yOffset: CGFloat {
//      let norm = motion.pitch / (.pi/2)
//      return CGFloat(curved(norm)) * 4
        return 2
    }
    
//    private var
    
    var zoomScaleAdapted: CGFloat {
        (zoomScale / 2) + 0.5
    }
    
    private struct HighlightView: View {
        let isLeft: Bool
        let opacity: Double
        
        var body: some View {
            LinearGradient(
                gradient: Gradient(colors: [Color.primary.opacity(0.2), Color.primary.opacity(0.1), Color.primary.opacity(0.1), Color.clear]),
                startPoint: isLeft ? .leading : .trailing,
                endPoint: isLeft ? .trailing : .leading
            )
            .opacity(opacity)
        }
    }
    
    func moveRight() {
        highlightedSide = "right"
        if let boulderId = problem.topo?.boulderId {
            if let next = Boulder(id: boulderId).next(after: problem) {
                mapState.selectStartOrProblem(next)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            highlightedSide = nil
        }
    }
    
    func moveLeft() {
        highlightedSide = "left"
        if let boulderId = problem.topo?.boulderId {
            if let previous = Boulder(id: boulderId).previous(before: problem) {
                mapState.selectStartOrProblem(previous)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            highlightedSide = nil
        }
    }
    
    func contentWithImage(_ image: UIImage) -> some View {
        ZStack {
            Group {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .modify {
                        if case .ready(let image) = photoStatus  {
                            $0.fullScreenCover(isPresented: $presentTopoFullScreenView) {
                                TopoFullScreenView(image: image, problem: problem)
                            }
                        }
                        else {
                            $0
                        }
                    }
                    
//                    .onTapGesture {
//                        print("Tapped on image")
//                        handleTapOnBackground()
//                    }
                
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: geometry.size.width * 0.33)
                            .contentShape(Rectangle())
                            .overlay(
                                HighlightView(
                                    isLeft: true,
                                    opacity: highlightedSide == "left" ? 1 : 0
                                )
                                .animation(.easeInOut(duration: 0.2), value: highlightedSide)
                            )
                            
                        
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: geometry.size.width * 0.34)
                        
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: geometry.size.width * 0.33)
                            .contentShape(Rectangle())
                            .overlay(
                                HighlightView(
                                    isLeft: false,
                                    opacity: highlightedSide == "right" ? 1 : 0
                                )
                                .animation(.easeInOut(duration: 0.2), value: highlightedSide)
                            )
                            
                    }
                }
                
                
                if problem.line?.coordinates != nil {
                    LineView(problem: problem, drawPercentage: $lineDrawPercentage, pinchToZoomScale: $zoomScale)
                    
                    if true { // showAllLines { // selectedDetent == .large {
                        if let line = problem.line, let middlePoint = problem.overlayBadgePosition, let firstPoint = line.firstPoint {
                            
                            GeometryReader { geo in
                                GradeBadgeView(number: problem.grade.string, sitStart: problem.sitStart, color: problem.circuitUIColorForPhotoOverlay)
                                    .scaleEffect(1/zoomScaleAdapted)
                                    .position(x: middlePoint.x * geo.size.width, y: middlePoint.y * geo.size.height)
                                    .zIndex(.infinity)
                                //                                            .onTapGesture {
                                //                                                showAllLines = false
                                //                                                mapState.selectProblem(problem)
                                //                                            }
                                
                                
                                
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
                    ForEach(problem.startGroups) { (group: StartGroup) in
                        let problems = group.problemsToDisplay
                        
                        if mapState.anyStartSelected { // }(showAllLines) {
                            ForEach(problems.filter{$0.startId == problem.startId || mapState.showAllStarts}) { p in
                                LineView(problem: p, drawPercentage: $lineDrawPercentage, pinchToZoomScale: $zoomScale)
//                                    .opacity(showAllLines ? 1 : 0.7)
                                //                                                .opacity(0.5)
                                    .onTapGesture {
                                        mapState.selectProblem(p)
                                    }
                            }
                        }
                        
                        if (problems.count >= 2) {
                            if let problemToUseAsStart = (problems.firstIndex(of: problem) != nil) ? problem : problems.first {
                                if let line = problemToUseAsStart.line, let firstPoint = line.firstPoint {
                                    
                                    let array = problems.sorted{$0.zIndex > $1.zIndex}
                                    
                                    ZStack {
                                        ProblemCircleView(problem: array[0], isDisplayedOnPhoto: true).zIndex(10)
//                                            .overlay(
//                                                Circle()
//                                                    .stroke(Color(UIColor.black).opacity(0.7), lineWidth: 2)
//                                                    .frame(width: 20, height: 20)
//                                            )
//                                        ProblemCircleView(problem: array[1], isDisplayedOnPhoto: true)
//                                            .scaleEffect(1.2)
//                                            .offset(x: 3, y: 3)
                                        //                                            .offset(x: xOffset, y: yOffset)
                                        //                                            .animation(.easeOut(duration: 0.1), value: motion.roll)
                                    }
                                    .scaleEffect(1/zoomScaleAdapted)
                                    .position(x: firstPoint.x * geo.size.width, y: firstPoint.y * geo.size.height)
                                    .onTapGesture {
                                        // TODO: use the start parent
                                        if let startId = group.startId, let start = Problem.load(id: startId) {
                                            mapState.selectStart(start)
                                        }
                                    }
                                }
                            }
                        }
                        else  {
                            ForEach(problems.indices, id: \.self) { (i: Int) in
                                let p = problems[i]
                                //                                    let offseeet = group.sortedProblems.firstIndex(of: problem)
                                
                                
                                
                                if let line = p.line, let firstPoint = line.firstPoint {
                                    ProblemCircleView(problem: p, isDisplayedOnPhoto: true)
                                        .scaleEffect(1/zoomScaleAdapted)
                                    //                                            .scaleEffect(0.8)
                                    //                                            .opacity(0.5)
                                    //                                                .allowsHitTesting(false)
                                        .position(x: firstPoint.x * geo.size.width, y: firstPoint.y * geo.size.height)
                                    //                                            .offset(x: Double((i-(offseeet ?? 0))*4), y: 0)
                                    //                                                .offset(x: (p.lineFirstPoint?.x == group.topProblem?.lineFirstPoint?.x && p.id != group.topProblem?.id) ? 4 : 0, y: 0)
                                    
                                        .zIndex(p == problem ? .infinity : p.zIndex)
                                        .onTapGesture {
                                            mapState.selectProblem(p)
                                        }
                                    
                                    
                                }
                            }
                        }
                        
                        if !mapState.showAllStarts {
                            
                            if mapState.isStartSelected {
                                let p = problem.start
                                let count = problem.startGroup?.problems.count ?? 0
//                                    ForEach(group.problems.filter{$0.startId == problem.startId}) { (p: Problem) in
                                        if let line = p.line, let firstPoint = line.firstPoint, let lastPoint = line.lastPoint, let middlePoint = p.overlayBadgePosition, let topPoint = p.topPosition {
                                            
                                            
                                            Text("\(p.localizedName) +\(count)")
                                                .foregroundColor(.white)
                                                .font(.caption2)
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 2)
                                                .background {
                                                    Color(p.circuitUIColor)
                                                    
                                                }
                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                            
                                                .scaleEffect(1/zoomScaleAdapted)
                                                .position(x: lastPoint.x * geo.size.width, y: lastPoint.y * geo.size.height)
                                                .offset(x: 0, y: -16)
                                                .zIndex(.infinity)
                                                .onTapGesture {
                                                    mapState.selectProblem(p)
                                                }
                                        }
//                                    }
                                
                            }
                            else {
                                let p = problem
                                if let line = p.line, let firstPoint = line.firstPoint, let lastPoint = line.lastPoint, let middlePoint = p.overlayBadgePosition, let topPoint = p.topPosition {
                                    Text("\(p.localizedName)")
                                        .foregroundColor(.white)
                                        .font(.caption2)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background {
                                            Color(p.circuitUIColor)
                                            
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                    
                                        .scaleEffect(1/zoomScaleAdapted)
                                        .position(x: lastPoint.x * geo.size.width, y: lastPoint.y * geo.size.height)
                                        .offset(x: 0, y: -16)
                                        .zIndex(.infinity)
                                        .onTapGesture {
                                            mapState.selectProblem(p)
                                        }
                                }
                            }
                        }
                        

                            
                        
                        
                    }
                }
                
                //                GeometryReader { geo in
                //                    TapLocationView { location in
                //                        handleTap(at: Line.PhotoPercentCoordinate(x: location.x / geo.size.width, y: location.y / geo.size.height))
                //                    }
                //                }
                
                if mapState.anyStartSelected {
                    GeometryReader { geo in
                        ForEach(problem.startGroups) { (group: StartGroup) in
                            ForEach(group.problems.filter{$0.startId == problem.startId || mapState.showAllStarts}) { (p: Problem) in
                                if let line = p.line, let firstPoint = line.firstPoint, let lastPoint = line.lastPoint, let middlePoint = p.overlayBadgePosition, let topPoint = p.topPosition {
                                    
                                    if true {
                                        
                                        GradeBadgeView(number: p.grade.string, sitStart: p.sitStart, color: p.circuitUIColorForPhotoOverlay)
                                            .scaleEffect(1/zoomScaleAdapted)
                                            .position(x: middlePoint.x * geo.size.width, y: middlePoint.y * geo.size.height)
                                            .zIndex(.infinity)
                                            .onTapGesture {
                                                mapState.selectProblem(p)
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                }
            }
        }
//        .contentShape(Rectangle())
        .background(Color(.imageBackground))
        .onTapGesture {
            print("Tapped on image")
            mapState.selectAllStarts()
            
        }
//        .offset(x: offset.width)
//        .gesture(
//            DragGesture()
//                .onChanged { gesture in
//                    let currentTime = Date().timeIntervalSince1970
//                    guard currentTime - lastGestureTime >= 0.2 else { return }
//                    lastGestureTime = currentTime
//                    
//                    if let topo = problem.topo {
//                        let ref = Line.PhotoPercentCoordinate(
//                            x: Double(gesture.location.x / UIScreen.main.bounds.width),
//                            y: Double(gesture.location.y / (UIScreen.main.bounds.width * 3/4))
//                        )
//                        if let closestStart = topo.closestStart(from: ref) {
//                            mapState.selectStartOrProblem(closestStart)
//                        }
//                    }
//                }
//                .onEnded { _ in
//                    offset = .zero
//                }
//        )
        
//        .simultaneousGesture(
//            LongPressGesture(minimumDuration: 0.5)
//                .onEnded { _ in
//                    print("long press detected")
//                    
//                    mapState.showAllStarts = true
//                }
//        )
//        .modify {
//            if #available(iOS 17.0, *) {
//                $0.sensoryFeedback(.success, trigger: mapState.showAllStarts) { oldValue, newValue in
//                    newValue
//                }
//            }
//            else {
//                $0
//            }
//        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            
            Group {
                if case .ready(let image) = photoStatus  {
                    ZoomableScrollView(zoomScale: $zoomScale) {
                        contentWithImage(image)
                    }
//                        .onLongPressGesture(minimumDuration: 1, maximumDistance: 10) {
//
//                            } onPressingChanged: { inProgress in
//                                showAllLines = inProgress
//                            }
//                            .modify {
//                                if #available(iOS 17.0, *) {
//                                    $0.sensoryFeedback(.success, trigger: showAllLines) { oldValue, newValue in
//                                        newValue
//                                    }
//                                }
//                                else {
//                                    $0
//                                }
//                            }
                }
                else if case .loading = photoStatus {
                    ProgressView()
                }
                else if case .none = photoStatus {
                    Image("nophoto")
                        .font(.system(size: 60))
                        .foregroundColor(Color.gray)
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
                }
                else {
                    EmptyView()
                }
            }
            
//            if showAllLines {
//                VStack {
//                    HStack {
//                        Button {
//                            mapState.presentProblemDetails = false
//    //                        selectedDetent = .large
//                        } label: {
//                            Image(systemName: "xmark")
//                                .padding()
//                        }
//
//                        Spacer()
//
//                    }
//
//                    Spacer()
//                }
//            }
//            else
//            {
//                VStack {
//                    HStack {
//                        Button {
//                            showAllLines = true
//    //                        selectedDetent = .large
//                        } label: {
//                            Image(systemName: "chevron.left")
//                                .padding()
//                        }
//
//                        Spacer()
//
//                    }
//
//                    Spacer()
//                }
//            }
            
            
            
//            VStack {
//                HStack {
//                    Spacer()
//
//                    if(problem.variants.count > 1) {
//                        Menu {
//                            ForEach(problem.variants) { variant in
//                                Button {
//                                    mapState.selectProblem(variant)
//                                } label: {
//                                    Text("\(variant.localizedName) \(variant.grade.string)")
//                                }
//                            }
//                        } label: {
//                            HStack {
//                                Text(numberOfVariantsForProblem(problem))
//                                Image(systemName: "chevron.down")
//                            }
//                                .padding(.vertical, 4)
//                                .padding(.horizontal, 8)
//                                .background(Color.gray.opacity(0.8))
//                                .foregroundColor(Color(UIColor.systemBackground))
//                                .cornerRadius(16)
//                                .padding(8)
//                        }
//                    }
//                }
//
//                Spacer()
//            }
        }
        .aspectRatio(4/3, contentMode: .fit)
        .background(Color(.imageBackground))
        .onChange(of: photoStatus) { value in
            switch value {
            case .ready(image: _):
                displayLine()
            default:
                print("")
            }
        }
        .onChange(of: problem) { [problem] newValue in
            if problem.topoId == newValue.topoId {
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
        .onChange(of: selectedDetent) { newDetent in
            print("User selected: \(newDetent)")
//            if newDetent == .large {
//                showAllLines = true
//            }
//            else {
//                showAllLines = false
//            }
        }
        .task {
            await loadData()
        }
//        .onAppear {
//            mapState.showAllStarts = true
//        }
        
    }
    
    func displayLine() {
        if problem.line?.coordinates != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animate { lineDrawPercentage = 1.0 }
//                lineDrawPercentage = 1.0
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
//        guard let topo = problem.topo else {
//            photoStatus = .none
//            return
//        }
        
        
        if let photo = topo.onDiskPhoto {
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
            if let photo = topo.onDiskPhoto {
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
    
    // TODO: use the proper i18n method for plural
    func numberOfVariantsForProblem(_ p: Problem) -> String {
        let count = problem.variants.count
        if count >= 2 {
            return String(format: NSLocalizedString("problem.variants.other", comment: ""), count)
        }
        else {
            return NSLocalizedString("problem.variants.one", comment: "")
        }
    }
    
    func animate(action: () -> Void) {
        withAnimation(Animation.easeInOut(duration: 0.4)) {
            action()
        }
    }
    
    func handleTap(at tapPoint: Line.PhotoPercentCoordinate) {
        
//        let groups = problem.startGroups
//            .filter { $0.distance(to: tapPoint) < 0.1 }
//            .sorted { $0.distance(to: tapPoint) < $1.distance(to: tapPoint) }
//
//        guard let group = groups.first else {
//            return handleTapOnBackground()
////            return
//        }
//
//        if group.problems.contains(problem) {
//            if let next = group.next(after: problem) {
//                mapState.selectProblem(next)
//                showAllLines = false
//            }
//        }
//        else {
//            if let topProblem = group.topProblem {
//                mapState.selectProblem(topProblem)
//                showAllLines = false
//            }
//        }
    }

}

//struct TopoView_Previews: PreviewProvider {
//    static let dataStore = DataStore()
//
//    static var previews: some View {
//        TopoView(problem: .constant(dataStore.problems.first!), areaResourcesDownloaded: .constant(true), scale: .constant(1))
//    }
//}
