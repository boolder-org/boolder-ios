//
//  SavedProblems.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 11/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TickList: View {
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: []) var favorites: FetchedResults<Favorite>
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    @EnvironmentObject var appState: AppState
    
    @State private var loaded = false
    @State private var areas = [Area]()
    @State private var problems = [Problem]()
    @State private var problemsGroupedByAreas = Dictionary<Area?, [Problem]>()
    
    var body: some View {
        NavigationView {
            VStack {
                if !loaded {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(minHeight: 200)
                }
                else if problems.count == 0 {
                    VStack(alignment: .center, spacing: 16) {
                        Spacer()
//                        Text("ticklist.empty_state_title").font(.title2)
                        Text("ticklist.empty_state_body").font(.body)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .foregroundColor(Color.secondary)
                }
                else {
                    List {
                        ForEach(areas, id: \.self) { (area: Area) in
                            Section(header: Text(area.name)) {
                                ForEach(problemsGroupedByAreas[area]!) { problem in
                                    Button {
                                        appState.tab = .map
                                        appState.selectedProblem = problem
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
            .modify {
                if #available(iOS 16, *) {
                    $0.task {
                        load()
                    }
                }
                else {
                    $0.onAppear {
                        load()
                    }
                }
            }
        }
    }
    
    private func load() -> Void {
        let problemIds = Set(favorites.map{ $0.problemId }).union(ticks.map{ $0.problemId })
        
        problems = problemIds.map { id in
            Problem.load(id: Int(id))
        }.compactMap { $0 }
        
        problemsGroupedByAreas = Dictionary(grouping: problems, by: { (problem: Problem) in
            Area.load(id: problem.areaId)
        })
        
        areas = problemsGroupedByAreas.keys.compactMap{$0}.sorted()
        
        areas.forEach { area in
            problemsGroupedByAreas[area] = problemsGroupedByAreas[area]!.sorted { (problem1, problem2) -> Bool in
                if problem1.grade == problem2.grade {
                    return problem1.nameWithFallback < problem2.nameWithFallback
                }
                return problem1.grade > problem2.grade
            }
        }
        
        loaded = true
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
