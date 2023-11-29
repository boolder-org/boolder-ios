//
//  TopoView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 21/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
//import ImageViewer

struct TopoView: View {
//    @EnvironmentObject var odrManager: ODRManager
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var problem: Problem
    @ObservedObject var mapState: MapState
    @State private var lineDrawPercentage: CGFloat = .zero
//    @Binding var areaResourcesDownloaded: Bool
    
    @State private var photoUrl: String? // remove
    @State private var photoImage: UIImage?  // remove
    @State private var photoStatus: PhotoStatus = .initial
    
    @State private var presentTopoFullScreenView = false
    
    let tapSize: CGFloat = 44
    
    enum PhotoStatus: Equatable {
        case initial
        case none
        case loading
        case ready(image: UIImage)
        case error
    }
    
    
    
    func loadData() async {
        if let localPhoto = problem.mainTopoPhoto {
            self.photoStatus = .ready(image: localPhoto)
            return
        }
        
        
        
        
        guard let topoId = problem.mainTopoId else {
            photoStatus = .none
            return
        }
        
        do {
            
            photoStatus = .loading
            
            if let image = try await TopoImageCache.shared.getImage(topoId: topoId) {
                self.photoStatus = .ready(image: image)
            }
            else {
                self.photoStatus = .error
            }
            
        } catch {
            print("Invalid data")
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
//                                .transition(
//                                         .asymmetric(
//                                            insertion: .identity,
//                                            removal: .opacity.animation(.linear(duration: 0.3)) // to avoid flickering when switching between 2 different topos
//                                         )
//                                    )
                                .onTapGesture {
                                    presentTopoFullScreenView = true
                                }
//                                .fullScreenCover(isPresented: $presentTopoFullScreenView) {
//                                    TopoFullScreenView(image: topoPhoto, problem: problem)
//                                }
                            
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
//                        .transition(
//                                 .asymmetric(
//                                    insertion: .opacity.animation(.default.delay(0.1)),
//                                      removal: .opacity
//                                 )
//                            )
                }
                else if case .none = photoStatus {
                    Image("nophoto")
                        .font(.system(size: 60))
                        .foregroundColor(Color.gray)
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
        .background(Color("ImageBackground"))
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
//            print("old topoId: \(problem.mainTopoId)")
//            print("new topoId: \(newValue.mainTopoId)")
            
            if problem.mainTopoId == newValue.mainTopoId {
                lineDrawPercentage = 0.0
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animate { lineDrawPercentage = 1.0 }
                }
            }
            else {
//                photoStatus = .initial
                lineDrawPercentage = 0.0
                
                Task {
                    await loadData()
                }
            }
        }
        
        .onChange(of: problem) { _ in
//            lineDrawPercentage = 0.0
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                animate { lineDrawPercentage = 1.0 }
//            }
        }
        .onAppear {
            // hack to make the animation start after the view is properly loaded
            // I tried doing it synchronously by I couldn't make it work :grimacing:
            // I also tried to use a lower value for the delay but it doesn't work (no animation at all)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                animate { lineDrawPercentage = 1.0 }
//            }
        }
        .task {
            await loadData()
        }
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
