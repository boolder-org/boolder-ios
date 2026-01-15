//
//  TopoFullScreenView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 10/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopoFullScreenView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) var openURL
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: []) var favorites: FetchedResults<Favorite>
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    @Binding var problem: Problem
    @State private var zoomScale: CGFloat = 1
    
    // drag gesture (to dismiss the sheet)
    @State var dragOffset: CGSize = CGSize.zero
    @State var dragOffsetPredicted: CGSize = CGSize.zero
    
    // overlay state
    @State private var presentSaveActionsheet = false
    @State private var presentSharesheet = false
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        
                        if #available(iOS 26, *) {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
                                    .padding(4)
                            }
                            .buttonStyle(.glass)
                            .buttonBorderShape(.circle)
                        }
                        else {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(Color(UIColor.white))
                                    .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    overlayInfos
                }
                .modify {
                    if #available(iOS 26, *) {
                        $0.edgesIgnoringSafeArea(.bottom)
                    }
                    else {
                        $0
                    }
                }
                .zIndex(2)
                
                ZoomableScrollView(zoomScale: $zoomScale) {
                    TopoView(problem: $problem, zoomScale: $zoomScale)
                }
                .containerRelativeFrame(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                .zIndex(1)
                .offset(x: 0, y: self.dragOffset.height) // drag gesture
                .gesture(DragGesture()
                    .onChanged { value in
                        self.dragOffset = value.translation
                        self.dragOffsetPredicted = value.predictedEndTranslation
                    }
                    .onEnded { value in
                        if(self.dragOffset.height > 200
                           || (self.dragOffsetPredicted.height > 0 && abs(self.dragOffsetPredicted.height) / abs(self.dragOffset.height) > 3)) {
                            withAnimation(.spring()) {
                                self.dragOffset = self.dragOffsetPredicted
                            }
                            dismiss()
                            
                            return
                        }
                        withAnimation(.interactiveSpring()) {
                            self.dragOffset = .zero
                        }
                    }
                )
                .background(Color.black)
                .edgesIgnoringSafeArea(.all)
                
            }
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var overlayInfos: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Problem name, grade, and details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(problem.localizedName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Spacer()
                    
                    Text(problem.grade.string)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                HStack(alignment: .firstTextBaseline) {
                    if problem.sitStart {
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
                .foregroundColor(.primary.opacity(0.8))
            }
            
            // Action buttons
            overlayActionButtons
        }
        .modify {
            if #available(iOS 26, *) {
                $0
                    .padding()
                    .frame(minHeight: 140, alignment: .top)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
                    
            } else {
                $0
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(16)
            }
        }
    }
    
    var overlayActionButtons: some View {
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
                        .modify {
                            if #available(iOS 26, *) {
                                $0
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 4)
                            } else {
                                $0
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                    .modify {
                        if #available(iOS 26, *) {
                            $0.buttonStyle(.glassProminent)
                        } else {
                            $0
                                .buttonStyle(Pill(fill: true))
                        }
                    }
                }
                
                Button(action: {
                    presentSaveActionsheet = true
                }) {
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: (isFavorite() || isTicked()) ? "bookmark.fill" : "bookmark")
                        Text((isFavorite() || isTicked()) ? "problem.action.saved" : "problem.action.save")
                            .fixedSize(horizontal: true, vertical: true)
                    }
                    .modify {
                        if #available(iOS 26, *) {
                            $0
                                .padding(.vertical, 2)
                                .padding(.horizontal, 4)
                        } else {
                            $0
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .modify {
                    if #available(iOS 26, *) {
                        $0.buttonStyle(.glass)
                    } else {
                        $0
                            .buttonStyle(Pill())
                    }
                }
                .actionSheet(isPresented: $presentSaveActionsheet) {
                    ActionSheet(title: Text("problem.action.save"), buttons: saveButtons)
                }
                
                Button(action: {
                    presentSharesheet = true
                }) {
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .modify {
                        if #available(iOS 26, *) {
                            $0
                                .padding(.vertical, 2)
                                .padding(.horizontal, 4)
                        } else {
                            $0
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .modify {
                    if #available(iOS 26, *) {
                        $0.buttonStyle(.glass)
                    } else {
                        $0
                            .buttonStyle(Pill())
                    }
                }
                .sheet(isPresented: $presentSharesheet,
                       content: {
                    ActivityView(activityItems: [boolderURL] as [Any], applicationActivities: nil)
                })
            }
        }
        .scrollClipDisabled()
    }
    
    var saveButtons: [ActionSheet.Button] {
        var buttons = [ActionSheet.Button]()
        
        if !isTicked() {
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

//struct TopoFullScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopoFullScreenView()
//    }
//}
