//
//  TopoView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 21/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopoView: View {
    @EnvironmentObject var odrManager: ODRManager
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var problem: Problem
    @Binding var lineDrawPercentage: CGFloat
    @Binding var areaResourcesDownloaded: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            
            Group {
                if areaResourcesDownloaded {
                    if let topoPhoto = problem.mainTopoPhoto {
                        
                        Group {
                            Image(uiImage: topoPhoto)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            
                            LineView(problem: $problem, drawPercentage: $lineDrawPercentage)
                            
                            GeometryReader { geo in
                                if let lineStart = lineStart(problem: problem, inRectOfSize: geo.size) {
                                    ProblemCircleView(problem: problem, isDisplayedOnPhoto: true)
                                        .offset(lineStart)
                                }
                                
                                ForEach(problem.otherProblemsOnSameTopo) { secondaryProblem in
                                    if let lineStart = lineStart(problem: secondaryProblem, inRectOfSize: geo.size) {
                                        ProblemCircleView(problem: secondaryProblem, isDisplayedOnPhoto: true)
                                            .offset(lineStart)
                                            .animation(.easeIn(duration: 0.5))
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
                    
                    // We do this on top of the PinchToZoom view to be able to intercept taps on secondary problems
                    GeometryReader { geo in
                        ForEach(problem.otherProblemsOnSameTopo) { secondaryProblem in
                            if let lineStart = lineStart(problem: secondaryProblem, inRectOfSize: geo.size) {
                                Button(action: {
                                    switchToProblem(secondaryProblem)
                                }) {
                                    Circle()
                                        .frame(width: CircleView.defaultHeight, height: CircleView.defaultHeight)
                                        .foregroundColor(.clear)
                                }
                                .offset(lineStart)
                            }
                        }
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
    
    func lineStart(problem: Problem, inRectOfSize size: CGSize) -> CGSize? {
        guard let lineFirstPoint = problem.lineFirstPoint() else { return nil }
        
        return CGSize(
            width:  (CGFloat(lineFirstPoint.x) * size.width) - 14,
            height: (CGFloat(lineFirstPoint.y) * size.height) - 14
        )
    }
    
    // FIXME: this code is duplicated from ProblemsDetailsView.swift => make it DRY
    func switchToProblem(_ newProblem: Problem) {
        lineDrawPercentage = 0.0
        problem = newProblem
        
        // doing it async to be sure that the line is reset to zero
        // (there's probably a cleaner way to do it)
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
