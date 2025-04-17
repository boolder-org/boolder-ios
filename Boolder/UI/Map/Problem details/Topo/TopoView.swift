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
    
    @Binding var showAllLines: Bool
    @Binding var selectedDetent: PresentationDetent
    
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
                
                if problem.line?.coordinates != nil {
                    LineView(problem: problem, drawPercentage: $lineDrawPercentage, pinchToZoomScale: .constant(1))
                    
                    if true { // showAllLines { // selectedDetent == .large {
                        if let line = problem.line, let middlePoint = problem.overlayBadgePosition, let firstPoint = line.firstPoint {
                            
                            GeometryReader { geo in
                                GradeBadgeView(number: problem.grade.string, color: problem.circuitUIColorForPhotoOverlay)
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
                        let problems = group.problemsWithoutVariants
                        
                        if problems.count >= 2 {
                            if let problemToUseAsStart = (problems.firstIndex(of: problem) != nil) ? problem : problems.first {
                                if let line = problemToUseAsStart.line, let firstPoint = line.firstPoint {
                                    //                                        CircleView(number: "+", color: .darkGray, scaleEffect: 0.7)
                                    ////                                            .allowsHitTesting(false)
                                    //                                            .position(x: firstPoint.x * geo.size.width, y: firstPoint.y * geo.size.height)
                                    
                                    
                                    
                                    //                                            ZStack {
                                    //                                                Circle()
                                    //                                                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                                    //                                                    .frame(width: 18, height: 18)
                                    //
                                    //                                                Circle()
                                    //                                                    .fill(Color(.darkGray).opacity(0.8))
                                    //                                                    .frame(width: 18, height: 18)
                                    //
                                    //                                                Circle()
                                    //                                                    .fill(Color.white)
                                    //                                                    .frame(width: 8, height: 8)
                                    //                                            }
                                    //
                                    //                                            .position(x: firstPoint.x * geo.size.width, y: firstPoint.y * geo.size.height)
                                    //                                            .onTapGesture {
                                    //                                                showAllLines = true
                                    //
                                    //                                                if group.problems.contains(problem) {
                                    //                                                    if let next = problem.startGroup?.next(after: problem) {
                                    //                                                        mapState.selectProblem(next)
                                    //                                                    }
                                    //
                                    //                                                }
                                    //                                                else {
                                    //                                                    if let topProblem = group.topProblem {
                                    //                                                        mapState.selectProblem(topProblem)
                                    //                                                    }
                                    //                                                }
                                    //                                            }
                                    
                                    //                                            if showAllLines && problem.startId == group.startId {
                                    //                                                HStack(spacing: 0) {
                                    //                                                    ForEach(problems.indices, id: \.self) { (i: Int) in
                                    //                                                        let p = problems[i]
                                    //                                                        ProblemCircleView(problem: p, isDisplayedOnPhoto: true)
                                    //                                                            .onTapGesture {
                                    //                                                                showAllLines = false
                                    //                                                                mapState.selectProblem(p)
                                    //                                                            }
                                    //                                                    }
                                    //                                                }
                                    //                                                .background {
                                    //                                                    Color.gray
                                    //                                                }
                                    //                                                .cornerRadius(8)
                                    //                                                .position(x: firstPoint.x * geo.size.width, y: firstPoint.y * geo.size.height)
                                    //                                                .zIndex(.infinity)
                                    ////                                                .offset(x: 0, y: 32)
                                    //                                            }
                                }
                            }
                        }
                        else if false  {
                            ForEach(problems.indices, id: \.self) { (i: Int) in
                                let p = problems[i]
                                //                                    let offseeet = group.sortedProblems.firstIndex(of: problem)
                                
                                
                                
                                if let line = p.line, let firstPoint = line.firstPoint {
                                    ProblemCircleView(problem: p, isDisplayedOnPhoto: true)
                                    //                                            .scaleEffect(0.8)
                                    //                                            .opacity(0.5)
                                    //                                                .allowsHitTesting(false)
                                        .position(x: firstPoint.x * geo.size.width, y: firstPoint.y * geo.size.height)
                                    //                                            .offset(x: Double((i-(offseeet ?? 0))*4), y: 0)
                                    //                                                .offset(x: (p.lineFirstPoint?.x == group.topProblem?.lineFirstPoint?.x && p.id != group.topProblem?.id) ? 4 : 0, y: 0)
                                    
                                        .zIndex(p == problem ? .infinity : p.zIndex)
                                        .onTapGesture {
                                            showAllLines = false
                                            mapState.selectProblem(p)
                                        }
                                    
                                    
                                }
                            }
                        }
                        
                        if showAllLines { // }(showAllLines) {
                            ForEach(problems) { p in
                                LineView(problem: p, drawPercentage: $lineDrawPercentage, pinchToZoomScale: .constant(1))
                                //                                                .opacity(0.5)
                                    .onTapGesture {
                                        showAllLines = false
                                        mapState.selectProblem(p)
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
                
                if showAllLines { // }(showAllLines) {
                    GeometryReader { geo in
                        ForEach(problem.startGroups) { (group: StartGroup) in
                            ForEach(group.problems) { (p: Problem) in
                                if let line = p.line, let firstPoint = line.firstPoint, let lastPoint = line.lastPoint, let middlePoint = p.overlayBadgePosition, let topPoint = p.topPosition {
                                    
                                    if p.parentId == nil {
                                        
                                        GradeBadgeView(number: p.grade.string, color: p.circuitUIColorForPhotoOverlay)
                                            .position(x: middlePoint.x * geo.size.width, y: middlePoint.y * geo.size.height)
                                            .zIndex(.infinity)
                                            .onTapGesture {
                                                showAllLines = false
                                                mapState.selectProblem(p)
                                            }
                                        
                                        //                                                ProblemCircleView(problem: p, isDisplayedOnPhoto: true)
                                        //                                                    .position(x: topPoint.x * geo.size.width, y: topPoint.y * geo.size.height)
                                        //                                                    .zIndex(.infinity)
                                        //                                                    .onTapGesture {
                                        //                                                        mapState.selectProblem(p)
                                        //                                                        showAllLines = false
                                        //                                                    }
                                    }
                                }
                            }
                        }
                    }
                }
                
                //                        if let line = problem.line, let firstPoint = problem.lineFirstPoint {
                //                            if let group = problem.startGroup, let index = problem.indexWithinStartGroup {
                //                                if(group.problemsWithoutVariants.count > 1 ) {
                //                                    GeometryReader { geo in
                //                                        Menu {
                //                                            ForEach(group.problemsWithoutVariants) { p in
                //                                                Button {
                //                                                    mapState.selectProblem(p)
                //                                                } label: {
                //                                                    Text("\(p.localizedName) \(p.grade.string)")
                //                                                }
                //                                            }
                //
                ////                                            Divider()
                ////
                ////                                            Menu("Voir aussi") {
                ////                                                Button {
                ////
                ////                                                } label : {
                ////                                                    Text("Test")
                ////                                                }
                ////                                                Button {
                ////
                ////                                                } label : {
                ////                                                    Text("Test 2")
                ////                                                }
                ////                                            }
                //                                        } label: {
                //                                            HStack(spacing: 4) {
                //                                                Text("\(index + 1) sur \(group.problemsWithoutVariants.count)")
                ////                                                Image(systemName: "list.bullet")
                ////                                                PageControlView(numberOfPages: group.problems.count, currentPage: index)
                //                                            }
                //                                            .font(.caption)
                //                                            .padding(.vertical, 2)
                //                                            .padding(.horizontal, 6)
                //                                            .background(Color(.darkGray).opacity(0.8))
                //                                            .foregroundColor(Color(UIColor.systemBackground))
                //                                            .cornerRadius(16)
                //                                            .padding(8)
                //                                        }
                //                                        .position(x: firstPoint.x * geo.size.width, y: firstPoint.y * geo.size.height + 28)
                //                                        .zIndex(.infinity)
                //
                //                                    }
                //                                }
                //                            }
                //                        }
                
                
            }
            
            VStack {
                HStack {
                    if !showAllLines {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                                            .foregroundColor(.white)
                                            .opacity(0.8)
                                            .shadow(radius: 2)
                                            .padding()
                            .onTapGesture {
                                showAllLines = true
                            }
                    }
//                    else {
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.system(size: 22, weight: .semibold))
//                                            .foregroundColor(.white)
//                                            .opacity(0.8)
//                                            .shadow(radius: 2)
//                            .onTapGesture {
//                                
//                            }
//                    }
                        
                    
                    Spacer()
                }
//                .padding(.horizontal)
                
                Spacer()
            }
//            .padding(.vertical)
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            
            Group {
                if case .ready(let image) = photoStatus  {
                    contentWithImage(image)
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
        handleTapOnBackground()
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
    
    func handleTapOnBackground() {
//        presentTopoFullScreenView = true
//        showAllLines = true
//        showAllLines.toggle()
        showAllLines = true
    }
}

//struct TopoView_Previews: PreviewProvider {
//    static let dataStore = DataStore()
//    
//    static var previews: some View {
//        TopoView(problem: .constant(dataStore.problems.first!), areaResourcesDownloaded: .constant(true), scale: .constant(1))
//    }
//}
