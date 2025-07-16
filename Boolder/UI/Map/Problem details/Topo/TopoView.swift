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
    @State private var lineDrawPercentage: CGFloat = .zero
    @State private var photoStatus: PhotoStatus = .initial
    @State private var presentTopoFullScreenView = false
    @State private var showMissingLineNotice = false
    
    @Binding var zoomScale: CGFloat
    var onBackgroundTap: (() -> Void)?
    
    var body: some View {
        ZStack(alignment: .center) {
            if case .ready(let image) = photoStatus  {
                Group {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .modify {
                            if case .ready(_) = photoStatus  {
                                $0.fullScreenCover(isPresented: $presentTopoFullScreenView) {
                                    TopoFullScreenView(problem: $problem)
                                }
                            }
                            else {
                                $0
                            }
                        }
                    
                    if problem.line?.coordinates != nil {
                        LineView(problem: problem, drawPercentage: $lineDrawPercentage, zoomScale: Binding(
                            get: { zoomScaleAdapted },
                            set: { _ in } // Read-only binding since we're transforming the value
                        ))
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
                            ForEach(group.problems) { (p: Problem) in
                                if let firstPoint = p.lineFirstPoint {
                                    ProblemCircleView(problem: p, isDisplayedOnPhoto: true)
                                        .allowsHitTesting(false)
                                        .scaleEffect(1/zoomScaleAdapted)
                                        .position(x: firstPoint.x * geo.size.width, y: firstPoint.y * geo.size.height)
                                        .zIndex(p == problem ? .infinity : p.zIndex)
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
    
    var zoomScaleAdapted: CGFloat {
        (zoomScale / 2) + 0.5
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
        presentTopoFullScreenView = true
    }
}

//struct TopoView_Previews: PreviewProvider {
//    static let dataStore = DataStore()
//    
//    static var previews: some View {
//        TopoView(problem: .constant(dataStore.problems.first!), areaResourcesDownloaded: .constant(true), scale: .constant(1))
//    }
//}
