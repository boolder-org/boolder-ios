//
//  SavedProblems.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 11/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TickList: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: []) var favorites: FetchedResults<Favorite>
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    @Binding var appTab: ContentView.Tab
    let mapState: MapState
    
    var body: some View {
        NavigationView {
            VStack {
                if problems.count == 0 {
                    VStack(alignment: .center, spacing: 16) {
                        Spacer()
                        Text("ticklist.empty_state_title").font(.title2)
                        Text("ticklist.empty_state_body").font(.body)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .foregroundColor(Color.secondary)
                }
                else {
                    List {
                        ForEach(groupedProblemsKeys, id: \.self) { (area: Area) in
                            Section(header: Text(area.name)) {
                                ForEach(groupedProblems[area]!.sorted(by: \.grade)) { problem in
                                    Button {
                                        appTab = .map
                                        mapState.selectAndPresentAndCenterOnProblem(problem)
                                    } label: {
                                        HStack {
                                            ProblemCircleView(problem: problem)
                                            
                                            Text(problem.nameWithFallback)
                                            
                                            Spacer()
                                            
                                            if isTicked(problem: problem) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Color.appGreen)
                                            }
                                            else if isFavorite(problem: problem) {
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(Color.yellow)
                                            }
                                            
                                            Text(problem.grade.string)
                                        }
                                        .foregroundColor(.primary)
                                    }
                                }
                                
                            }
                        }
                    }
                    
                    .listStyle(.insetGrouped)
                    .modify {
                        if #available(iOS 15, *) {
                            $0.headerProminence(.increased)
                        }
                        else {
                            $0
                        }
                    }
                }
            }
     
            .navigationTitle("ticklist.title")
        }
    }
    
    var groupedProblems : Dictionary<Area?, [Problem]> {
        Dictionary(grouping: problems, by: { (problem: Problem) in
            Area.load(id: problem.areaId)
        })
    }
    
    var groupedProblemsKeys : [Area] {
        groupedProblems.keys.compactMap{$0}.sorted()
    }
    
    var problems: [Problem] {
        let problemIds = Set(favorites.map{ $0.problemId }).union(ticks.map{ $0.problemId })
        
        return problemIds.map { id in
            Problem.load(id: Int(id))
        }.compactMap { $0 }
    }
    
    func isFavorite(problem: Problem) -> Bool {
        favorites.contains { (favorite: Favorite) -> Bool in
            return Int(favorite.problemId) == problem.id
        }
    }
    
    func isTicked(problem: Problem) -> Bool {
        ticks.contains { (tick: Tick) -> Bool in
            return Int(tick.problemId) == problem.id
        }
    }
}

//struct SavedProblems_Previews: PreviewProvider {
//    static var previews: some View {
//        SavedProblemsView()
//    }
//}
