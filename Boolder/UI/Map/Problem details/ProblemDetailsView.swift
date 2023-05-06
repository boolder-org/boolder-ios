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
    @EnvironmentObject var odrManager: ODRManager
    @Environment(\.openURL) var openURL
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: []) var favorites: FetchedResults<Favorite>
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    @Binding var problem: Problem
    @ObservedObject var mapState: MapState
    
    @State private var areaResourcesDownloaded = false
    @State private var presentSaveActionsheet = false
    @State private var presentSharesheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                TopoView(
                    problem: $problem,
                    mapState: mapState,
                    areaResourcesDownloaded: $areaResourcesDownloaded
                )
                .zIndex(10)
                
                infos
                
                actionButtons
            }
        }
        
        .onAppear{
            let ids = [15552,15555,15553,15658,15625,15560,224,230,10873,10869,245,243,237,9074,14558,14199,14179,14136,14343,1739,1703,10045,10042,1088,915,914,881,1032,5397,5326,5325,1856,1840,1861,1816,1913,2021,2003,2094,2087,11310,2668,2857,2542,2545,2543,2527,8680,8801,7807,2542,1582,1462,1455,1579,1526,1435,13478,13484,13468,13467,13074,12998,13070,13011,13042,13040,13030,2893,2911,2902,2889,3091,3092,3161,3186,11425,6342,6344,3257,3255,3283,3288,3331,3409,4534,4551,4581,690,5091,5106,5124,5088,5127,7878,3825,3803,4787,9237,9177,9302,9345,2315,2214,7756,2352,8131,8126]
            
            if !ids.contains(problem.id) {
                
                // FIXME: doesn't work when user selects a problem in a different area without closing the ProblemDetails sheet (which happens when two areas are really close together)
                odrManager.requestResources(tags: Set(["area-\(problem.areaId)"]), onSuccess: {
                    areaResourcesDownloaded = true
                    
                }, onFailure: { error in
                    print("On-demand resource error")
                    
                    // TODO: implement UI, log errors
                    switch error.code {
                    case NSBundleOnDemandResourceOutOfSpaceError:
                        print("You don't have enough space available to download this resource.")
                    case NSBundleOnDemandResourceExceededMaximumSizeError:
                        print("The bundle resource was too big.")
                    case NSBundleOnDemandResourceInvalidTagError:
                        print("The requested tag does not exist.")
                    default:
                        print(error.description)
                    }
                })
            }
        }
    }
    
    var infos: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 4) {
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(problem.localizedName)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .minimumScaleFactor(0.5)
                        
                        Spacer()
                        
                        Text(problem.grade.string)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 4)
                }
                
                HStack(alignment: .firstTextBaseline) {
                    
                    if problem.steepness != .other {
                        HStack(alignment: .firstTextBaseline) {
                            Image(problem.steepness.imageName)
                                .frame(minWidth: 16)
                            Text(problem.steepness.localizedName)
                            
                        }
                        .font(.body)
                    }
                    
                    if(problem.sitStart) {
                        if problem.steepness != .other {
                            Text("•")
                                .font(.body)
                        }
                        Text("problem.sit_start")
                            .font(.body)
                    }
                    
                    Spacer()
                    
                    if isTicked() {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.appGreen)
                    }
                    else if isFavorite() {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color.yellow)
                    }
                }
            }
        }
        .padding(.top, 0)
        .padding(.horizontal)
        //        .layoutPriority(1) // without this the imageview prevents the title from going multiline
        
    }
    
    var actionButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 16) {
                
                if problem.bleauInfoId != nil && problem.bleauInfoId != "" {
                    Button(action: {
                        openURL(URL(string: "https://bleau.info/a/\(problem.bleauInfoId ?? "").html")!)
                    }) {
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "info.circle")
                            Text("Bleau.info").fixedSize(horizontal: true, vertical: true)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                    }
                    .buttonStyle(Pill(fill: true))
                }
                
                Button(action: {
                    presentSaveActionsheet = true
                }) {
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: (isFavorite() || isTicked()) ? "bookmark.fill" : "bookmark")
                        Text((isFavorite() || isTicked()) ? "problem.action.saved" : "problem.action.save")
                            .fixedSize(horizontal: true, vertical: true)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(Pill())
                .actionSheet(isPresented: $presentSaveActionsheet) {
                    ActionSheet(title: Text("problem.action.save"), buttons: saveButtons)
                }
                
                Button(action: {
                    presentSharesheet = true
                }) {
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("problem.action.share").fixedSize(horizontal: true, vertical: true)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(Pill())
                .sheet(isPresented: $presentSharesheet,
                       content: {
                    ActivityView(activityItems: [boolderURL] as [Any], applicationActivities: nil) }
                )
                
                Button(action: {
                    if let url = mailToURL {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: "text.bubble")
                        Text("problem.action.report").fixedSize(horizontal: true, vertical: true)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(Pill())
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }
    
    var saveButtons: [ActionSheet.Button] {
        var buttons = [ActionSheet.Button]()
        
        if(!isTicked()) {
            buttons.append(
                .default(Text(isFavorite() ? "problem.action.favorite.remove" : "problem.action.favorite.add")) {
                    toggleFavorite()
                }
            )
        }
        
        buttons.append(
            .default(Text(isTicked() ? "problem.action.untick" : "problem.action.tick")) {
                toggleTick()
            }
        )
        
        buttons.append(.cancel())
        
        return buttons
    }
    
    var variants: some View {
        VStack(alignment: .leading, spacing: 4) {
            if(problem.variants.count > 0) {
                
                Divider()
                
                ForEach(problem.variants) { variant in
                    
                    Button(action: {
                        mapState.selectProblem(variant)
                        
                    }, label: {
                        HStack {
                            Text(variant.localizedName)
                                .lineLimit(2)
                            Spacer()
                            Text(variant.grade.string)
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        .frame(height: 44)
                    })
                    
                    Divider()
                }
            }
            
            Spacer()
        }
        .padding(.top, 8)
    }
    
    var boolderURL: URL {
        URL(string: "https://www.boolder.com/\(NSLocale.websiteLocale)/p/\(String(problem.id))")!
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
            "Problem #\(String(problem.id)) - \(problem.localizedName)",
            "Boolder \(appVersion ?? "") (\(buildNumber ?? ""))",
            "iOS \(UIDevice.current.systemVersion)",
        ]
            .map{$0.stringByAddingPercentEncodingForRFC3986() ?? ""}
            .joined(separator: "%0D%0A")
        
        return URL(string: "mailto:\(recipient)?subject=\(subject)&body=\(body)")
    }
    
    // MARK: Ticks and favorites
    
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


//struct ProblemDetailsView_Previews: PreviewProvider {
//    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//    static var previews: some View {
//        ProblemDetailsView(problem: .constant(dataStore.problems.first!))
//            .environment(\.managedObjectContext, context)
//    }
//}

