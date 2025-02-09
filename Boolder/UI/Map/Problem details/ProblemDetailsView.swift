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
    @Environment(\.openURL) var openURL
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: []) var favorites: FetchedResults<Favorite>
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    var problem: Problem
    @ObservedObject var mapState: MapState
    
    @State private var areaResourcesDownloaded = false
    @State private var presentSaveActionsheet = false
    @State private var presentSharesheet = false
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 8) {
                    TopoView(
                        problem: problem,
                        mapState: mapState
                    )
                    .frame(width: geo.size.width, height: geo.size.width * 3/4)
                    .zIndex(10)
                    
                    infos
                    
                    actionButtons
                }
            }
            
            Spacer()
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
                            .fixedSize(horizontal: false, vertical: true)
                            .minimumScaleFactor(0.5)
                        
                        Spacer()
                        
                        Text(problem.grade.string)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 4)
                }
                
                HStack(alignment: .firstTextBaseline) {
                    
                    if(problem.sitStart) {
                        Image(systemName: "figure.rower")
                        Text("problem.sit_start")
                            .font(.body)
                    }
                    
                    if problem.steepness != .other {
                        if problem.sitStart {
                            Text("•")
                                .font(.body)
                        }
                        
                        HStack(alignment: .firstTextBaseline) {
                            Image(problem.steepness.imageName)
                                .frame(minWidth: 16)
                            Text(problem.steepness.localizedName)
                            
                        }
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
    
    var boolderURL: URL {
        URL(string: "https://www.boolder.com/\(NSLocale.websiteLocale)/p/\(String(problem.id))")!
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

