//
//  ProblemDetailsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 25/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import StoreKit
import MapKit

struct ProblemDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    
    @AppStorage("problemDetails/viewCount") var viewCount = 0
    @AppStorage("lastVersionPromptedForReview") var lastVersionPromptedForReview = ""
    @Environment(\.requestReview) private var requestReview
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: []) var favorites: FetchedResults<Favorite>
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    @Binding var problem: Problem
    @ObservedObject var mapState: MapState
    
    @State private var areaResourcesDownloaded = false
    @State private var presentSaveActionsheet = false
    @State private var presentSharesheet = false
    
    @State private var currentPage = 0
    @State private var pageCounter = 0
    @State private var currentPageForVariants = 0
    
    @Binding var selectedDetent: PresentationDetent
    
    @State private var showAllLines = false
    
    var array: [Problem] {
        problem.startGroup?.sortedProblems ?? []
    }
    
    var variants: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(array) { (p: Problem) in
                        HStack {
                            if p.sitStart {
                                Image(systemName: "figure.rower")
                            }
                            
                            Text("\(p.grade.string)")
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        .id(p.id)
                        .font(.callout)
                        .frame(maxWidth: UIScreen.main.bounds.width / 2)
                        .foregroundColor(problem.id == p.id ? .white : .black)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(problem.id == p.id ? Color.appGreen : Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                mapState.selectProblem(p)
                                proxy.scrollTo(p.id, anchor: .center)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
    }
    
    var infosCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            VStack(alignment: .leading, spacing: 4) {
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        if false { // showAllLines {
                            Button {
                                showAllLines = true
                            } label: {
                                Image(systemName: "chevron.backward.circle")
                            }
                            .foregroundColor(.gray)
                            .font(.title2)
                            //                            .fontWeight(.bold)
                        }
                        
                        ProblemCircleView(problem: problem)
                        
                        Text(problem.localizedName)
                            .font(.title2)
//                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .fixedSize(horizontal: false, vertical: true)
                            .minimumScaleFactor(0.5)
                        
                        Spacer()
                        
                        //                        if(problem.sitStart) {
                        //                            Image(systemName: "figure.rower")
                        //                            Text("problem.sit_start")
                        //                                .font(.body)
                        //                        }
                        
                        Text(problem.grade.string)
                            .font(.title2)
//                            .fontWeight(.bold)
                        
                        //                        variants
                    }
                    .padding(.top, 4)
                }
                
                HStack(alignment: .firstTextBaseline) {
                    
                    if(problem.sitStart) {
                        Image(systemName: "figure.rower")
                        Text("problem.sit_start")
                            .font(.body)
                    }
                    
                    //                    if problem.steepness != .other {
                    //                        if problem.sitStart {
                    //                            Text("•")
                    //                                .font(.body)
                    //                        }
                    //
                    //                        HStack(alignment: .firstTextBaseline) {
                    //                            Image(problem.steepness.imageName)
                    //                                .frame(minWidth: 16)
                    //                            Text(problem.steepness.localizedName)
                    //
                    //                        }
                    //                        .font(.body)
                    //                    }
                    
                    Spacer()
                    
                    //                    if isTicked() {
                    //                        Image(systemName: "checkmark.circle.fill")
                    //                            .foregroundColor(Color.appGreen)
                    //                    }
                    //                    else if isFavorite() {
                    //                        Image(systemName: "star.fill")
                    //                            .foregroundColor(Color.yellow)
                    //                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    var currentTopoIndex: Int {
        guard let t = Topo.load(id: currentPage) else { return 0 }
        
        return problem.topo!.onSameBoulder.firstIndex(of: t) ?? 0
    }
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 0) {
                    
                    TabView(selection: $currentPage) {
                        ForEach(problem.topo!.onSameBoulder) { topo in
                            TopoView(
                                topo: topo,
                                problem: $problem,
                                mapState: mapState,
                                showAllLines: $showAllLines,
                                selectedDetent: $selectedDetent
                            )
                            .frame(width: geo.size.width, height: geo.size.width * 3/4)
                            .zIndex(10)
                            .tag(topo.id) // use tag or id?
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(width: geo.size.width, height: geo.size.width * 3/4)
                    .onChange(of: currentPage) { newPage in
                        print(newPage)
                        if let topo = Topo.load(id: newPage) {
                            mapState.selectProblem(topo.firstProblemOnTheLeft!)
                            
                            //                            print(pageCounter)
                            if true { // pageCounter > 0 {
//                                showAllLines = true
                                
                            }
                            pageCounter = pageCounter + 1
                            
                            //                            if selectedDetent == .large {
                            //                                showAllLines = true
                            //                            }
                            
                        }
                    }
                    .onChange(of: problem) { [problem] newValue in
                        currentPage = newValue.topo!.id
                    }
                    
//                    PageControlView(numberOfPages: problem.topo!.onSameBoulder.count, currentPage: currentTopoIndex)
//                        .padding(.top, 8)
//                        .padding(.bottom, 4)
//                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    
                    if !showAllLines {  //selectedDetent == .medium {
                        
                        if array.count > 1 {
                            variants
                        }
                        
                        infosCard
                            .frame(height: 80)
                            .opacity(showAllLines ? 0.2 : 1)
                    }
                    
                    
//                    if !showAllLines {
//                        tabs
//
//                        if (problem.startGroup?.problems.count ?? 0) > 1 {
//
//                            PageControlView(numberOfPages: problem.startGroup?.problems.count ?? 0, currentPage: problem.indexWithinStartGroup ?? 0)
//                                .padding(.top, 8)
//                                .padding(.bottom, 4)
//                                .frame(maxWidth: .infinity, alignment: .center)
//                        }
//                    }
                    
                    if showAllLines { // selectedDetent == .large {
                        
                        
                        ScrollView {
                            
                            VStack(spacing: 0) {
                                
                                //                                Divider().padding(.vertical, 0)
                                
                                ForEach(problem.topo!.orderedProblems) { p in
                                    Button {
                                        mapState.selectProblem(p)
                                        showAllLines = false
                                    } label: {
                                        HStack {
                                            ProblemCircleView(problem: p)
                                            Text(p.localizedName)
                                            Spacer()
                                            //                                            if(p.sitStart) {
                                            //                                                Image(systemName: "figure.rower")
                                            //                                            }
                                            
                                            //                                            if(p.featured) {
                                            //                                                Image(systemName: "heart.fill").foregroundColor(.pink)
                                            //                                            }
                                            Text(p.grade.string)
                                        }
                                        .foregroundColor(.primary)
                                        
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)
                                    .background(p.id == problem.id && !showAllLines ? Color.secondary.opacity(0.1) : Color.systemBackground)
                                    
                                    Divider().padding(.vertical, 0)
                                    
                                    //                                    ForEach(p.children) { child in
                                    //                                        Button {
                                    //                                            mapState.selectProblem(child)
                                    //                                            showAllLines = false
                                    //                                        } label: {
                                    //                                            HStack {
                                    ////                                                Image(systemName: "arrow.turn.down.right")
                                    ////                                                    .foregroundColor(.gray)
                                    //
                                    //                                                ProblemCircleView(problem: child)
                                    //                                                Text(child.localizedName)
                                    //                                                Spacer()
                                    ////                                                if(child.sitStart) {
                                    ////                                                    Image(systemName: "figure.rower")
                                    ////                                                }
                                    //
                                    ////                                                if(child.featured) {
                                    ////                                                    Image(systemName: "heart.fill").foregroundColor(.pink)
                                    ////                                                }
                                    //
                                    //                                                Text(child.grade.string)
                                    //                                            }
                                    //                                            .foregroundColor(.primary)
                                    //                                        }
                                    //                                        .padding(.horizontal)
                                    //                                        .padding(.vertical, 6)
                                    //                                        .background(child.id == problem.id && !showAllLines ? Color.secondary.opacity(0.1) : Color.systemBackground)
                                    //
                                    //                                        Divider().padding(.vertical, 0)
                                    //                                    }
                                    
                                    
                                }
                            }
                        }
                        
                        
                    }
                    
                    //                    Spacer()
                    
                    //                    if !showAllLines {
                    //                        actionButtons
                    //                    }
                }
            }
            
            Spacer()
        }
        .onChange(of: problem) { [problem] newValue in
            //            showAllLines = false
        }
        .task {
            currentPage = problem.topo!.id
        }
        .modify {
            if #available(iOS 17.0, *) {
                $0.onAppear {
                    viewCount += 1
                }
                // Inspired by https://developer.apple.com/documentation/storekit/requesting-app-store-reviews
                .onChange(of: viewCount) {
                    guard let currentAppVersion = Bundle.currentAppVersion else {
                        return
                    }
                    
                    if viewCount >= 100, currentAppVersion != lastVersionPromptedForReview {
                        presentReview()
                        lastVersionPromptedForReview = currentAppVersion
                    }
                }
            }
            else {
                $0
            }
        }
    }
    
//    var problemsSharingSameStart: [Problem] {
//        let problemsWithoutVariants = problem.startGroup?.problems.compactMap{$0}.filter{ $0.parentId == nil }
//        return problemsWithoutVariants.flatMap {
//            [$0] + $0.children.
//        }
//    }
    
    var tabs: some View {
        TabView(selection: $currentPageForVariants) {
            ForEach(problem.startGroup?.sortedProblems ?? []) { (p: Problem) in
                VStack {
                    HStack {
                        ProblemCircleView(problem: problem)
                        Text(p.localizedName)
                        Spacer()
//                        if(problem.sitStart) {
//                            Image(systemName: "figure.rower")
//                            //                        Text("problem.sit_start")
//                            //                            .font(.body)
//                        }
                        Text(p.grade.string)
                    }
                    
                    
                    HStack(alignment: .firstTextBaseline) {
                        
                        if(p.sitStart) {
                            Image(systemName: "figure.rower")
                            Text("problem.sit_start")
                                .font(.body)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal)
                .tag(p.id)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onChange(of: currentPageForVariants) { newPage in
            print(newPage)
            mapState.selectProblem(Problem.load(id: newPage)!)
        }
        .onChange(of: problem) { [problem] newValue in
            currentPageForVariants = newValue.id
        }
        .padding(.top, 0)
        //        .padding(.horizontal)
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
                            Image(systemName: "arrow.up.forward.app")
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
                        //                        Text((isFavorite() || isTicked()) ? "problem.action.saved" : "problem.action.save")
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
                        //                        Text("problem.action.share").fixedSize(horizontal: true, vertical: true)
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
    
    private func presentReview() {
        Task {
            // Delay for two seconds to avoid interrupting the person using the app.
            try await Task.sleep(for: .seconds(2))
            await requestReview()
        }
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

