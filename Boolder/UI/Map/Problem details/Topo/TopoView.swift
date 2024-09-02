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
    @ObservedObject var mapState: MapState
    @State private var lineDrawPercentage: CGFloat = .zero
    @State private var photoStatus: PhotoStatus = .initial
    @State private var presentTopoFullScreenView = false
    
    @State private var leftSideTapped = false
    @State private var rightSideTapped = false
    
    @State private var showMissingLineNotice = false
    
    let tapSize: CGFloat = 44
    
    var adjacentButtons: some View {
        Group {
            if let previous = problem.previousAdjacent {
                GeometryReader { geometry in
                    HStack {
                        ZStack {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: geometry.size.width / 3.5, height: geometry.size.height)
                                .contentShape(Rectangle())
                                .onTapGesture {
//                                    if previous.topoId == problem.topoId {
                                        mapState.selectProblem(previous)
//                                    }
                                    
                                    withAnimation {
                                        leftSideTapped = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        withAnimation {
                                            leftSideTapped = false
                                        }
                                    }
                                }
//                                .onLongPressGesture {
//                                    mapState.selectProblem(previous)
//                                    
//                                    withAnimation {
//                                        leftSideTapped = true
//                                    }
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//                                        withAnimation {
//                                            leftSideTapped = false
//                                        }
//                                    }
//                                }
                            
                            if leftSideTapped {
                                LinearGradient(
                                    gradient: gradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(width: geometry.size.width / 3.5, height: geometry.size.height)
                                .transition(.opacity)
                            }
                        }
                        Spacer()
                    }
                    
                }
            }
            
            if let next = problem.nextAdjacent {
                GeometryReader { geometry in
                    HStack {
                        Spacer()
                        ZStack {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: geometry.size.width / 3.5, height: geometry.size.height)
                                .contentShape(Rectangle())
                                .onTapGesture {
//                                    if next.topoId == problem.topoId {
                                        mapState.selectProblem(next)
//                                    }
                                    
                                    withAnimation {
                                        rightSideTapped = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        withAnimation {
                                            rightSideTapped = false
                                        }
                                    }
                                }
//                                .onLongPressGesture {
//                                    mapState.selectProblem(next)
//                                    
//                                    withAnimation {
//                                        rightSideTapped = true
//                                    }
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//                                        withAnimation {
//                                            rightSideTapped = false
//                                        }
//                                    }
//                                }
                            
                            if rightSideTapped {
                                LinearGradient(
                                    gradient: gradient,
                                    startPoint: .trailing,
                                    endPoint: .leading
                                )
                                .frame(width: geometry.size.width / 3.5, height: geometry.size.height)
                                .transition(.opacity)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            
            
            
            Group {
                if case .ready(let image) = photoStatus  {
                        Group {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
//                                .onTapGesture {
//                                    presentTopoFullScreenView = true
//                                }
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
                            
                            adjacentButtons
                            
                            if problem.line?.coordinates != nil {
                                LineView(problem: problem, drawPercentage: $lineDrawPercentage, pinchToZoomScale: .constant(1))
                            }
                            else {
                                Text("Ligne manquante")
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Color.gray.opacity(0.8))
                                    .foregroundColor(Color(UIColor.systemBackground))
                                    .cornerRadius(16)
                                    .transition(.opacity)
                                    .opacity(showMissingLineNotice ? 1.0 : 0.0)
                            }
                            
                            GeometryReader { geo in
                                if let lineStart = lineStart(problem: problem, inRectOfSize: geo.size) {
                                    ProblemCircleView(problem: problem, isDisplayedOnPhoto: true)
                                        .frame(width: tapSize, height: tapSize, alignment: .center)
                                        .contentShape(Rectangle()) // makes the whole frame tappable
                                        .offset(lineStart)
                                        .onTapGesture {
                                            if let nextStartVariant = problem.nextStartVariant {
                                                mapState.selectProblem(nextStartVariant)
                                            }
                                        }
                                    
                                    ForEach(Array(problem.startVariantsWithoutSelf.enumerated()), id: \.element) { index, variant in
                                        ProblemCircleView(problem: variant, isDisplayedOnPhoto: true)
                                            .frame(width: tapSize, height: tapSize, alignment: .center)
                                            .contentShape(Rectangle()) // makes the whole frame tappable
                                            .offset(CGSize(width: lineStart.width + CGFloat(index+1)*5, height: lineStart.height))
                                            .zIndex(-CGFloat(index+1))
                                            .onTapGesture {
                                                if let nextStartVariant = problem.nextStartVariant {
                                                    mapState.selectProblem(nextStartVariant)
                                                }
                                            }
                                    }
                                }
                                
                                
                                
                                ForEach(problem.otherProblemsOnSameTopo) { secondaryProblem in
                                    if let lineStart = lineStart(problem: secondaryProblem, inRectOfSize: geo.size) {
                                        ProblemCircleView(problem: secondaryProblem, isDisplayedOnPhoto: true)
                                            .frame(width: tapSize, height: tapSize, alignment: .center)
                                            .contentShape(Rectangle()) // makes the whole frame tappable
                                            .offset(lineStart)
                                            .onTapGesture {
                                                mapState.selectProblem(secondaryProblem)
                                            }
                                        
                                        ForEach(Array(secondaryProblem.startVariantsWithoutSelf.enumerated()), id: \.element) { index, variant in
                                            ProblemCircleView(problem: variant, isDisplayedOnPhoto: true)
                                                .frame(width: tapSize, height: tapSize, alignment: .center)
                                                .contentShape(Rectangle()) // makes the whole frame tappable
                                                .offset(CGSize(width: lineStart.width + CGFloat(index+1)*5, height: lineStart.height))
                                                .zIndex(-CGFloat(index+1))
                                                .onTapGesture {
                                                    mapState.selectProblem(secondaryProblem)
                                                }
                                        }
                                    }
                                }
                            }
                        }
                }
                else if case .loading = photoStatus {
                    ProgressView()
                    
                    adjacentButtons
                }
                else if case .none = photoStatus {
                    Image("nophoto")
                        .font(.system(size: 60))
                        .foregroundColor(Color.gray)
                    
                    adjacentButtons
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
                    
                    adjacentButtons
                }
                else {
                    EmptyView()
                }
            }
            
            HStack {
                Spacer()
                
                VStack {
                    
                    if problem.variantsForDisplayOnTopoView.count > 1, let variantIndex = problem.variantIndex {
                        Button {
                            if let nextVariant = problem.nextVariant {
                                mapState.selectProblem(nextVariant)
                            }
                        } label: {
                            HStack {
                                Text("variante \(variantIndex+1)/\(problem.variantsForDisplayOnTopoView.count)")
//                                Image(systemName: "chevron.down")
                            }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.gray.opacity(0.8))
                                .foregroundColor(Color(UIColor.systemBackground))
                                .cornerRadius(16)
                                .padding(8)
                        }
                    }
                    
                    Spacer()
                }
            }
            
            
        }
        .aspectRatio(4/3, contentMode: .fit)
        .background(Color(.imageBackground))
        .onChange(of: photoStatus) { value in
            switch value {
            case .ready(image: _):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animate { lineDrawPercentage = 1.0 }
                }
            default:
                print("")
            }
        }
        .onChange(of: problem) { [problem] newValue in
            if problem.topoId == newValue.topoId {
                lineDrawPercentage = 0.0
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animate { lineDrawPercentage = 1.0 }
                }
            }
            else {
                lineDrawPercentage = 0.0
                
                Task {
                    await loadData()
                }
            }
            
            if newValue.line?.coordinates == nil {
                withAnimation { showMissingLineNotice = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation { showMissingLineNotice = false }
                }
            }
            else {
                withAnimation { showMissingLineNotice = false }
            }
        }
        .task {
            await loadData()
        }
    }
    
    let gradient = Gradient(stops: [
        .init(color: Color.white.opacity(0.7), location: 0.0),
        .init(color: Color.white.opacity(0.5), location: 0.5),
        .init(color: Color.white.opacity(0.0), location: 1.0)
    ])
    
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
    
    // TODO: make this DRY with other screens
    func lineStart(problem: Problem, inRectOfSize size: CGSize) -> CGSize? {
        guard let lineFirstPoint = problem.lineFirstPoint() else { return nil }
        
        return CGSize(
            width:  (CGFloat(lineFirstPoint.x) * size.width) - tapSize/2,
            height: (CGFloat(lineFirstPoint.y) * size.height) - tapSize/2
        )
    }
    
    func animate(action: () -> Void) {
        withAnimation(Animation.easeInOut(duration: 0.4)) {
            action()
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
