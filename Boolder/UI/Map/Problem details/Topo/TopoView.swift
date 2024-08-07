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
    
    let tapSize: CGFloat = 44
    
    var body: some View {
        ZStack(alignment: .center) {
            
            Group {
                if case .ready(let image) = photoStatus  {
                        Group {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .onTapGesture {
                                    presentTopoFullScreenView = true
                                }
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
                            
                            LineView(problem: problem, drawPercentage: $lineDrawPercentage, pinchToZoomScale: .constant(1))
                            
                            GeometryReader { geo in
                                if let lineStart = lineStart(problem: problem, inRectOfSize: geo.size) {
                                    ProblemCircleView(problem: problem, isDisplayedOnPhoto: true)
                                        .frame(width: tapSize, height: tapSize, alignment: .center)
                                        .contentShape(Rectangle()) // makes the whole frame tappable
                                        .offset(lineStart)
                                        .onTapGesture { /* intercept tap to avoid triggerring a tap on the background photo */ }
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
                                    }
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
            
            HStack {
                Spacer()
                
                VStack {
                    
                    if(problem.variants.count > 0) {
                        Menu {
                            ForEach(problem.variants) { variant in
                                Button {
                                    mapState.selectProblem(variant)
                                } label: {
                                    Text("\(variant.localizedName) \(variant.grade.string)")
                                }
                            }
                        } label: {
                            HStack {
                                Text(numberOfVariantsForProblem(problem))
                                Image(systemName: "chevron.down")
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
        }
        .task {
            await loadData()
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
