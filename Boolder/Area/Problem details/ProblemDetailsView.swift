//
//  ProblemDetailsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 25/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ScaledBezier: Shape {
    let bezierPath: Path

    func path(in rect: CGRect) -> Path {
        let transform = CGAffineTransform(scaleX: rect.width, y: rect.height)
        return bezierPath.applying(transform)
    }
}

struct ProblemDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.openURL) var openURL
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: []) var favorites: FetchedResults<Favorite>
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    @Binding var problem: Problem
    @State var showMoreActionsheet = false

    @State private var percentage: CGFloat = .zero
    
    private func linePoints() -> [CGPoint] {
        if let line = problem.line?.coordinates {
            return line.map{CGPoint(x: $0.x, y: $0.y)}
        }
        else {
            return []
        }
    }
    
    func linePath() -> Path {
        guard problem.line != nil else { return Path() }
//        guard problem.line?.coordinates != nil else { return Path() }
        if problem.line?.coordinates?.count == 0 { return Path() }
        
        let points = linePoints()
        let controlPoints = CubicCurveAlgorithm().controlPointsFromPoints(dataPoints: points)
        
        return Path { path in
            for i in 0..<points.count {
                let point = points[i]
                
                if i==0 {
                    path.move(to: CGPoint(x: point.x, y: point.y))
                } else {
                    let segment = controlPoints[i-1]
                    path.addCurve(to: point, control1: segment.controlPoint1, control2: segment.controlPoint2)
                }
            }
        }
    }
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ZStack(alignment: .topLeading) {
                    Image(uiImage: problem.mainTopoPhoto())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
//                    BezierViewRepresentable(problem: problem)
                    
                    ScaledBezier(bezierPath: linePath())
                        .trim(from: 0, to: percentage) // << breaks path by parts, animatable
                        .stroke(Color(problem.circuitUIColorForPhotoOverlay), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
//                        .animation(Animation.easeInOut(duration: 0.5).delay(0.5)) // << animate
                        
                    
                    GeometryReader { geo in
                        if lineFirstPoint(photoSize: geo.size) != nil {
                            ProblemCircleView(problem: problem, isDisplayedOnPhoto: true)
                                .offset(x: lineFirstPoint(photoSize: geo.size)!.x - 14, y: lineFirstPoint(photoSize: geo.size)!.y - 14)
                        }
                    }
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(UIColor.init(white: 1.0, alpha: 0.8)))
                            .padding(16)
                            .shadow(color: Color.gray, radius: 8, x: 0, y: 0)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 8) {
                    
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(problem.nameWithFallback())
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.label))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                                
                                Spacer()
                                
                                Text(problem.grade.string)
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                        }
                    
                        
                        HStack(alignment: .firstTextBaseline) {
                            Image(Steepness(problem.steepness).imageName)
                                .font(.body)
                                .frame(minWidth: 16)
                            Text(Steepness(problem.steepness).name)
                                .font(.body)
                            Text(problem.readableDescription() ?? "")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                        }
                        
                        if problem.isRisky() {
                        
                            Divider()
                            
                            HStack {
                                Image(systemName: "exclamationmark.shield.fill")
                                    .font(.body)
                                    .foregroundColor(Color.red)
                                    .frame(minWidth: 16)
                                Text("problem.risky.long")
                                    .font(.body)
                                    .foregroundColor(Color.red)
                                }
                        }
                    }
                    
                    
                    VStack {
                        Divider()
                        
                        Button(action:{
                            percentage = 0.0
                            problem = dataStore.problems.randomElement()!
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(Animation.easeInOut(duration: 0.5)) {
                                    percentage = 1.0
                                }
                            }
                        }) {
                            HStack {
                                Text("Test")
                                    .font(.body)
                                Spacer()
                            }
                        }
                        
                        Divider()
                        
                        Button(action:{
                            toggleFavorite()
                        }) {
                            HStack {
                                if isFavorite() {
                                    Image(systemName: "star.fill").foregroundColor(Color.yellow)
                                    Text("problem.action.favorite.remove")
                                        .font(.body)
                                }
                                else {
                                    Image(systemName: "star")
                                    Text("problem.action.favorite.add")
                                        .font(.body)
                                }
                                Spacer()
                            }
                        }
                        
                        Divider()
                        
                        Button(action:{
                            toggleTick()
                        }) {
                            HStack {
                                if isTicked() {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("problem.action.untick")
                                        .font(.body)
                                }
                                else {
                                    Image(systemName: "checkmark.circle")
                                    Text("problem.action.tick")
                                        .font(.body)
                                }
                                Spacer()
                            }
                        }
                        
                        if problem.bleauInfoId != nil && problem.bleauInfoId != "" {
                            Divider()
                            
                            Button(action: {
                                showMoreActionsheet = true
                            })
                            {
                                HStack {
                                    Image(systemName: "ellipsis.circle")
                                    Text("problem.action.plus")
                                        .font(.body)
                                        .foregroundColor(Color.green)
                                    Spacer()
                                }
                            }
                            .actionSheet(isPresented: $showMoreActionsheet) {
                                ActionSheet(title: Text("problem.action.plus"), buttons: [
                                    .default(Text("problem.action.see_on_bleau_info")) {
                                        openURL(URL(string: "https://bleau.info/a/\(problem.bleauInfoId ?? "").html")!)
                                    },
                                    .cancel()
                                ])
                            }
                        }
                        
                        Divider()
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal)
                .padding(.top, 0)
                
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(Animation.easeInOut(duration: 0.5)) {
                    percentage = 1.0
                }
            }
        }
    }
    
    func lineFirstPoint(photoSize size: CGSize) -> CGPoint? {
        guard let lineFirstPoint = problem.lineFirstPoint() else { return nil }
            
        return CGPoint(x: CGFloat(lineFirstPoint.x) * size.width, y: CGFloat(lineFirstPoint.y) * size.height)
    }
        
    func isFavorite() -> Bool {
        favorite() != nil
    }
    
    func favorite() -> Favorite? {
        favorites.first { (favorite: Favorite) -> Bool in
            return Int(favorite.problemId) == problem.id
        }
    }
    
    func toggleFavorite() {
        if isFavorite() {
            deleteFavorite()
        }
        else {
            createFavorite()
        }
    }
    
    func createFavorite() {
        let favorite = Favorite(context: managedObjectContext)
        favorite.id = UUID()
        favorite.problemId = Int64(problem.id)
        favorite.createdAt = Date()
        
        do {
            try managedObjectContext.save()
        } catch {
            // handle the Core Data error
        }
    }
    
    func deleteFavorite() {
        guard let favorite = favorite() else { return }
        managedObjectContext.delete(favorite)
        
        do {
            try managedObjectContext.save()
        } catch {
            // handle the Core Data error
        }
    }
    
    func isTicked() -> Bool {
        tick() != nil
    }
    
    func tick() -> Tick? {
        ticks.first { (tick: Tick) -> Bool in
            return Int(tick.problemId) == problem.id
        }
    }
    
    func toggleTick() {
        if isTicked() {
            deleteTick()
        }
        else {
            createTick()
        }
    }
    
    func createTick() {
        let tick = Tick(context: managedObjectContext)
        tick.id = UUID()
        tick.problemId = Int64(problem.id)
        tick.createdAt = Date()
        
        do {
            try managedObjectContext.save()
        } catch {
            // handle the Core Data error
        }
    }
    
    func deleteTick() {
        guard let tick = tick() else { return }
        managedObjectContext.delete(tick)
        
        do {
            try managedObjectContext.save()
        } catch {
            // handle the Core Data error
        }
    }
}

struct ProblemDetailsView_Previews: PreviewProvider {
    static let dataStore = DataStore()
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static var previews: some View {
        ProblemDetailsView(problem: .constant(dataStore.problems.first!))
            .environment(\.managedObjectContext, context)
            .environmentObject(dataStore)
    }
}

