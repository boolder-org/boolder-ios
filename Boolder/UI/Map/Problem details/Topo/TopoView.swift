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
    
//    let topo: Topo // FIXME: what happends when page changes?
    var topo: Topo {
        problem.topo! // FIXME: don't use bang
    }
    
    @Binding var problem: Problem
    @ObservedObject var mapState: MapState
    @State private var lineDrawPercentage: CGFloat = .zero
//    @State private var photoStatus: PhotoStatus = .initial
    @State private var presentTopoFullScreenView = false
    @State private var showMissingLineNotice = false
    @Binding var zoomScale: CGFloat
 
    
    var zoomScaleAdapted: CGFloat {
        (zoomScale / 2) + 0.5
    }
    
    
    // TODO: refactor
    var width : CGFloat {
        UIScreen.main.bounds.size.width - 16
    }
    
    var height : CGFloat {
        width * 3/4
    }
    
    var overlayView: some View {
        ZStack {
            
            
            if problem.line?.coordinates != nil {
                LineView(problem: problem, drawPercentage: $lineDrawPercentage, pinchToZoomScale: $zoomScale)
                
                if true { // showAllLines { // selectedDetent == .large {
                    if let line = problem.line, let middlePoint = problem.overlayBadgePosition, let firstPoint = line.firstPoint {
                        
                        
                        GradeBadgeView(number: problem.grade.string, sitStart: problem.sitStart, color: problem.circuitUIColorForPhotoOverlay)
                            .scaleEffect(1/zoomScaleAdapted)
                            .position(x: middlePoint.x * width, y: middlePoint.y * height)
                            .zIndex(.infinity)
                        //                                            .onTapGesture {
                        //                                                showAllLines = false
                        //                                                mapState.selectProblem(problem)
                        //                                            }
                        
                        
                        
                        
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
            
            
            ForEach(problem.startGroups) { (group: StartGroup) in
                let problems = group.problemsToDisplay
                
                if mapState.anyStartSelected { // }(showAllLines) {
                    ForEach(problems.filter{$0.startId == problem.startId || mapState.showAllStarts}) { p in
                        if p.showLine {
                            LineView(problem: p, drawPercentage: $lineDrawPercentage, pinchToZoomScale: $zoomScale)
                            //                                    .opacity(showAllLines ? 1 : 0.7)
                            //                                                .opacity(0.5)
                                .onTapGesture {
                                    mapState.selectProblem(p)
                                }
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
                            .position(x: firstPoint.x * width, y: firstPoint.y * height)
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
                                .position(x: firstPoint.x * width, y: firstPoint.y * height)
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
                        let problems = problem.startGroup?.problems ?? []
                        
                        if problems.allSatisfy{$0.endId == p.endId} {
                            
                            //                                    ForEach(group.problems.filter{$0.startId == problem.startId}) { (p: Problem) in
                            if let line = p.line, let firstPoint = line.firstPoint, let lastPoint = line.lastPoint, let middlePoint = p.overlayBadgePosition, let topPoint = p.topPosition {
                                
                                
                                Menu {
                                    ForEach(problems) { p in
                                        Button {
                                            mapState.selectProblem(p)
                                        } label: {
                                            Text("\(p.localizedName) \(p.grade.string)")
                                        }
                                    }
                                    
                                } label: {
                                    HStack(spacing: 2) {
                                        //                                                    Text("\(p.localizedName) +\(problems.count - 1)")
                                        Text("\(p.localizedName)")
                                        Image(systemName: "chevron.down")
                                        
                                    }
                                    .foregroundColor(.white)
                                    .font(.caption)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background {
                                        Color(p.circuitUIColor)
                                        
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    //                                                .contentShape(Rectangle())
                                    //                                                .frame(width: 80, height: 32)
                                }
                                //                                            .contentShape(Rectangle())
                                //                                            .frame(width: 80, height: 32)
                                .scaleEffect(1/zoomScaleAdapted)
                                .position(x: lastPoint.x * width, y: lastPoint.y * height)
                                .offset(x: 0, y: -16)
                                .zIndex(.infinity)
                                
                                
                                
                            }
                            //                                    }
                        }
                    }
                    else {
                        let p = problem
                        
                        // if variants then show menu
                        
                        if let line = p.line, let firstPoint = line.firstPoint, let lastPoint = line.lastPoint, let middlePoint = p.overlayBadgePosition, let topPoint = p.topPosition {
                            HStack {
                                Text("\(p.localizedName)")
                            }
                            .foregroundColor(.white)
                            .font(.caption)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background {
                                Color(p.circuitUIColor)
                                
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            
                            .scaleEffect(1/zoomScaleAdapted)
                            .position(x: lastPoint.x * width, y: lastPoint.y * height)
                            .offset(x: 0, y: -16)
                            .zIndex(.infinity)
                            .onTapGesture {
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
            
            if mapState.anyStartSelected {
                
                ForEach(problem.startGroups) { (group: StartGroup) in
                    ForEach(group.problems.filter{$0.startId == problem.startId || mapState.showAllStarts}) { (p: Problem) in
                        if let line = p.line, let firstPoint = line.firstPoint, let lastPoint = line.lastPoint, let middlePoint = p.overlayBadgePosition, let topPoint = p.topPosition {
                            
                            if p.showLine {
                                
                                GradeBadgeView(number: p.grade.string, sitStart: p.sitStart, color: p.circuitUIColorForPhotoOverlay)
                                    .scaleEffect(1/zoomScaleAdapted)
                                    .position(x: middlePoint.x * width, y: middlePoint.y * height)
                                    .zIndex(.infinity)
                                    .onTapGesture {
                                        mapState.selectProblem(p)
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
    
    func contentWithImage(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .overlay(
                overlayView
        )
//        .contentShape(Rectangle())
        .background(Color(.imageBackground))
        .onTapGesture {
            print("Tapped on image")
            mapState.selectAllStarts()
            
        }
    }
    
    var body: some View {
        contentWithImage(topo.onDiskPhoto!)
        .aspectRatio(4/3, contentMode: .fit)
        .background(Color(.imageBackground))
//        .onChange(of: photoStatus) { value in
//            switch value {
//            case .ready(image: _):
//                displayLine()
//            default:
//                print("")
//            }
//        }
        .onChange(of: problem) { [problem] newValue in
            if problem.topoId == newValue.topoId {
                lineDrawPercentage = 0.0
                
                displayLine()
            }
            else {
                lineDrawPercentage = 0.0
                
//                Task {
//                    await loadData()
//                }
            }
        }
//        .task {
//            await loadData()
//        }
        .onAppear {
            displayLine()
        }
        
    }
    
    func displayLine() {
        if problem.line?.coordinates != nil {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                animate { lineDrawPercentage = 1.0 }
//                lineDrawPercentage = 1.0
//                showMissingLineNotice = false
//            }
            lineDrawPercentage = 1.0
            showMissingLineNotice = false
        }
        else {
            withAnimation { showMissingLineNotice = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation { showMissingLineNotice = false }
            }
        }
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
