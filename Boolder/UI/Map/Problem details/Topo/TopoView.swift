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
    @EnvironmentObject var odrManager: ODRManager
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var problem: Problem
    @ObservedObject var mapState: MapState
    @Binding var lineDrawPercentage: CGFloat
    @Binding var areaResourcesDownloaded: Bool
    
    @State private var presentTopoFullScreenView = false
    
    let tapSize: CGFloat = 44
    
    var body: some View {
        ZStack(alignment: .center) {
            
            Group {
                if areaResourcesDownloaded {
                    if let topoPhoto = problem.mainTopoPhoto {
                        
                        Group {
                            Image(uiImage: topoPhoto)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .onTapGesture {
                                    presentTopoFullScreenView = true
                                }
                                .fullScreenCover(isPresented: $presentTopoFullScreenView) {
                                    TopoFullScreenView(image: topoPhoto, problem: problem)
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
                                                switchToProblem(secondaryProblem)
                                            }
                                    }
                                }
                            }
                        }
                    }
                    else {
                        Image("nophoto")
                            .font(.system(size: 60))
                            .foregroundColor(Color.gray)
                    }
                }
                else {
                    ImageLoadingView(progress: $odrManager.downloadProgress)
                        .aspectRatio(4/3, contentMode: .fill)
                }
            }
            
            HStack {
                Spacer()
                
                VStack {
                    
                    if(problem.variants.count > 0) {
                        Menu {
                            ForEach(problem.variants) { variant in
                                Button {
                                    switchToProblem(variant)
                                } label: {
                                    Text("\(variant.nameWithFallback) \(variant.grade.string)")
                                }
                            }
                        } label: {
                            Text(numberOfVariantsForProblem(problem))
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
        .onAppear {
            // hack to make the animation start after the view is properly loaded
            // I tried doing it synchronously by I couldn't make it work :grimacing:
            // I also tried to use a lower value for the delay but it doesn't work (no animation at all)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animate { lineDrawPercentage = 1.0 }
            }
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
    
    // FIXME: make this DRY with other screens
    func lineStart(problem: Problem, inRectOfSize size: CGSize) -> CGSize? {
        guard let lineFirstPoint = problem.lineFirstPoint() else { return nil }
        
        return CGSize(
            width:  (CGFloat(lineFirstPoint.x) * size.width) - tapSize/2,
            height: (CGFloat(lineFirstPoint.y) * size.height) - tapSize/2
        )
    }
    
    // FIXME: this code is duplicated from ProblemsDetailsView.swift => make it DRY
    func switchToProblem(_ newProblem: Problem) {
        lineDrawPercentage = 0.0
        mapState.selectProblem(newProblem)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animate { lineDrawPercentage = 1.0 }
        }
    }
    
    func animate(action: () -> Void) {
        withAnimation(Animation.easeInOut(duration: 0.5)) {
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
