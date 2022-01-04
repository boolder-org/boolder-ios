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
    
    @Binding var areaResourcesDownloaded: Bool
    
    @State var presentMoreActionsheet = false
    @State var presentSaveActionsheet = false
    @State private var presentPoiActionSheet = false
    
    @State var presentEditProblem = false
    
    @StateObject var pinchToZoomState = PinchToZoomState()
    let pinchToZoomPadding: CGFloat = 64 // safeguard for the pinch gesture hack (cf TopoView)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                TopoView(
                    problem: $problem,
                    areaResourcesDownloaded: $areaResourcesDownloaded,
                    pinchToZoomState: pinchToZoomState,
                    pinchToZoomPadding: pinchToZoomPadding
                )
                .zIndex(10)
                
                ZStack {
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 8) {
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(problem.nameWithFallback())
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
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
                                        Image(problem.steepness.imageName)
                                            .font(.body)
                                            .frame(minWidth: 16)
                                        Text(problem.steepness.localizedName)
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
                                        .foregroundColor(Color.appGreen)
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
                        .frame(minHeight: pinchToZoomPadding) // careful when changing this, it may hide tappable areas
                        
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
                                        .foregroundColor(Color.appGreen)
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
                    }
                    .padding(.horizontal)
                    .padding(.top, 0)
                    .layoutPriority(1) // without this the imageview prevents the title from going multiline
                    
                    Color.systemBackground
                        .opacity(overlayOpacity)
                }
                
                Spacer()
            }
        }
        .background(
            EmptyView()
                .sheet(isPresented: $presentEditProblem) {
                    EditProblemView(problem: problem, selectedSteepness: problem.steepness, selectedHeight: Double(problem.height ?? 0))
                        .environment(\.managedObjectContext, managedObjectContext)
                }
        )
    }
    
    var overlayOpacity: Double {
        if pinchToZoomState.scale <= 1 {
            return 0
        }
        
        else if pinchToZoomState.scale > 1 && pinchToZoomState.scale < 2 {
            return Double(pinchToZoomState.scale - 1.0)
        }
        else {
            return 1
        }
    }
    
    private func buttonsForMoreActionSheet() -> [Alert.Button] {
        var buttons = [Alert.Button]()
        
        if problem.bleauInfoId != nil && problem.bleauInfoId != "" {
            buttons.append(
                .default(Text("problem.action.see_on_bleau_info")) {
                    openURL(URL(string: "https://bleau.info/a/\(problem.bleauInfoId ?? "").html")!)
                }
            )
        }
        
        if let url = mailToURL {
            buttons.append(
                .default(Text("problem.action.report")) {
                    UIApplication.shared.open(url)
                }
            )
        }
        
        #if DEVELOPMENT
        buttons.append(
            .default(Text("Edit (dev only)")) {
                presentEditProblem = true
            }
        )
        #endif
        
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
        return String.localizedStringWithFormat(NSLocalizedString("problem.action.share.description", comment: ""), problem.nameForDirections(), dataStore.area(withId: dataStore.areaId)!.name)
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

// https://useyourloaf.com/blog/how-to-percent-encode-a-url-string/
extension String {
  func stringByAddingPercentEncodingForRFC3986() -> String? {
    let unreserved = "-._~/?"
    let allowed = NSMutableCharacterSet.alphanumeric()
    allowed.addCharacters(in: unreserved)
    return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
  }
}


struct ProblemDetailsView_Previews: PreviewProvider {
    static let dataStore = DataStore()
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static var previews: some View {
        ProblemDetailsView(problem: .constant(dataStore.problems.first!), centerOnProblem: .constant(nil), centerOnProblemCount: .constant(0), areaResourcesDownloaded: .constant(false))
            .environment(\.managedObjectContext, context)
            .environmentObject(dataStore)
    }
}

