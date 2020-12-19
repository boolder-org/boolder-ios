//
//  ProblemDetailsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 25/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import MapKit

struct ProblemDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.openURL) var openURL
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: []) var favorites: FetchedResults<Favorite>
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    @Binding var problem: Problem
    @Binding var centerOnProblem: Problem?
    @Binding var centerOnProblemCount: Int
    @Binding var showList: Bool
    
    @State var presentMoreActionsheet = false
    @State var presentSaveActionsheet = false
    @State private var presentPoiActionSheet = false
    @State private var drawPercentage: CGFloat = .zero
    
    @State private var presentImagePicker = false
    @State private var capturedPhoto = UIImage()
    
    @StateObject var locationFetcher = LocationFetcher()
    
    var locationText: String {
        if let location = locationFetcher.location {
            return String(format: "%.6f", location.coordinate.latitude) + " " + String(format: "%.6f", location.coordinate.longitude) + " (±" + String(format: "%.0f", location.horizontalAccuracy) + "m)"
        }
        else {
            return "Waiting for gps..."
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ZStack(alignment: .topLeading) {
                    Image(uiImage: problem.mainTopoPhoto())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    LineView(problem: $problem, drawPercentage: $drawPercentage)
                    
                    GeometryReader { geo in
                        ForEach(problem.otherProblemsOnSameTopo) { secondaryProblem in
                            if let lineStart = lineStart(problem: secondaryProblem, inRectOfSize: geo.size) {
                                Button(action: {
                                    switchToProblem(secondaryProblem)
                                }) {
                                    ProblemCircleView(problem: secondaryProblem, isDisplayedOnPhoto: true)
                                }
                                .offset(lineStart)
                            }
                        }
                        
                        if let lineStart = lineStart(problem: problem, inRectOfSize: geo.size) {
                            ProblemCircleView(problem: problem, isDisplayedOnPhoto: true)
                                .offset(lineStart)
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
                                
                                Spacer()
                                
                                Text(problem.grade.string)
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        HStack {
                            
                            if problem.steepness != .other {
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
                            }
                            
                            Spacer()
                            
                            if isFavorite() {
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color.yellow)
                            }

                            if isTicked() {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.green)
                            }
                        }
                        
                        if problem.isRisky() {
                            
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
                            presentSaveActionsheet = true
                        }) {
                            HStack {
                                Image(systemName: "star")
                                Text("problem.action.save").font(.body)
                                Spacer()
                            }
                        }
                        .actionSheet(isPresented: $presentSaveActionsheet) {
                            ActionSheet(title: Text("problem.action.save"), buttons: [
                                .default(Text(isFavorite() ? "problem.action.favorite.remove" : "problem.action.favorite.add")) {
                                    toggleFavorite()
                                },
                                .default(Text(isTicked() ? "problem.action.untick" : "problem.action.tick")) {
                                    toggleTick()
                                },
                                .cancel()
                            ])
                        }
                        
                        Divider()
                        
                        Button(action:{
                            presentPoiActionSheet = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("problem.action.share").font(.body)
                                Spacer()
                            }
                        }
                        .background(
                            PoiActionSheet(
                                description: shareProblemDescription(),
                                location: problem.coordinate,
                                navigationMode: false,
                                presentPoiActionSheet: $presentPoiActionSheet
                            )
                        )
                        
                        Divider()
                        
                        Button(action: {
                            presentMoreActionsheet = true
                        })
                        {
                            HStack {
                                Image(systemName: "ellipsis.circle")
                                Text("problem.action.more")
                                    .font(.body)
                                    .foregroundColor(Color.green)
                                Spacer()
                            }
                        }
                        .actionSheet(isPresented: $presentMoreActionsheet) {
                            ActionSheet(
                                title: Text("problem.action.more"),
                                buttons: buttonsForMoreActionSheet()
                            )
                        }
                        
                        Divider()
                        
                        
                    }
                    .padding(.top, 16)
                    
                    
                    #if DEVELOPMENT
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dev mode")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack(alignment: .center) {
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Problem #\(String(problem.id))")
                                Text(locationText)
                            }
                            .font(.system(size: 14, design: .monospaced))
                            
                            Spacer()
                            
                            Button(action: {
                                presentImagePicker = true
                            }) {
                                Image(systemName: "camera.circle.fill")
                                    .font(.title)
                            }
                            .fullScreenCover(isPresented: $presentImagePicker) {
                                ImagePicker(sourceType: .camera, location: locationFetcher.location, problemId: problem.id, selectedImage: $capturedPhoto)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.black)
                                    .edgesIgnoringSafeArea(.all)
                            }

                        }
                    }
                    .padding(.top, 16)
                    .foregroundColor(.gray)
                    #endif
                }
                .padding(.horizontal)
                .padding(.top, 0)
                
                Spacer()
            }
        }
        .onAppear {
            // hack to make the animation start after the view is properly loaded
            // I tried doing it synchronously by I couldn't make it work :grimacing:
            // I also tried to use a lower value for the delay but it doesn't work (no animation at all)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animate { drawPercentage = 1.0 }
            }
        }
    }
    
    private func buttonsForMoreActionSheet() -> [Alert.Button] {
        var buttons = [Alert.Button]()
        
        buttons.append(
            .default(Text("problem.action.center_on_map")) {
                presentationMode.wrappedValue.dismiss()
                showList = false
                centerOnProblem = problem
                centerOnProblemCount += 1 // triggers a map refresh
            }
        )
        
        if problem.bleauInfoId != nil && problem.bleauInfoId != "" {
            buttons.append(
                .default(Text("problem.action.see_on_bleau_info")) {
                    openURL(URL(string: "https://bleau.info/a/\(problem.bleauInfoId ?? "").html")!)
                }
            )
        }
        
        if let url = mailToURL {
            buttons.append(
                .default(Text("Signaler un problème")) {
                    UIApplication.shared.open(url)
                }
            )
        }
        
        buttons.append(.cancel())
        
        return buttons
    }
    
    var mailToURL: URL? {
        let recipient = "hello@boolder.com"
        let subject = "Feedback".stringByAddingPercentEncodingForRFC3986() ?? ""
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        let body = [
            "",
            "",
            "------",
            "Problem #\(String(problem.id)) - \(problem.nameWithFallback())",
            "Boolder \(appVersion ?? "") (\(buildNumber ?? ""))",
            "iOS \(UIDevice.current.systemVersion)",
        ]
        .map{$0.stringByAddingPercentEncodingForRFC3986() ?? ""}
        .joined(separator: "%0D%0A")
        
        return URL(string: "mailto:\(recipient)?subject=\(subject)&body=\(body)")
    }
    
    func shareProblemDescription() -> String {
        return String.localizedStringWithFormat(NSLocalizedString("problem.action.share.description", comment: ""), problem.nameForDirections(), dataStore.areas[dataStore.areaId]!)
    }
    
    func animate(action: () -> Void) {
        withAnimation(Animation.easeInOut(duration: 0.5)) {
            action()
        }
    }
    
    func lineStart(problem: Problem, inRectOfSize size: CGSize) -> CGSize? {
        guard let lineFirstPoint = problem.lineFirstPoint() else { return nil }
            
        return CGSize(
            width:  (CGFloat(lineFirstPoint.x) * size.width) - 14,
            height: (CGFloat(lineFirstPoint.y) * size.height) - 14
        )
    }
    
    func switchToProblem(_ newProblem: Problem) {
        drawPercentage = 0.0
        problem = newProblem

        // doing it async to be sure that the line is reset to zero
        // (there's probably a cleaner way to do it)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animate { drawPercentage = 1.0 }
        }
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
        ProblemDetailsView(problem: .constant(dataStore.problems.first!), centerOnProblem: .constant(nil), centerOnProblemCount: .constant(0), showList: .constant(true))
            .environment(\.managedObjectContext, context)
            .environmentObject(dataStore)
    }
}

