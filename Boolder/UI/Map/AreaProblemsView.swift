//
//  AreaProblemsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 30/12/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct AreaProblemsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let area: Area
    @EnvironmentObject var appState: AppState
    
    @State private var problems = [Problem]()
    @State private var searchText = ""
    @State private var popular = false
    
    var body: some View {
        List {
            
            HStack {
                Toggle(isOn: $popular, label: {
                    Text("area.problems.popular")
                })
            }
            
            Section {
                ForEach(problemsFilteredBySearch) { problem in
                    Button {
                        appState.tab = .map
                        appState.selectedProblem = problem
                    } label: {
                        HStack {
                            ProblemCircleView(problem: problem)
                            Text(problem.localizedName)
                            Spacer()
                            if(problem.featured) {
                                Image(systemName: "heart.fill").foregroundColor(.pink)
                            }
                            Text(problem.grade.string)
                        }
                        .foregroundColor(.primary)
                    }
                }
                
            }
        }
        .onAppear {
            problems = area.problems
        }
        .modify {
            if #available(iOS 16, *) {
                $0.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("area.problems.search_prompt")).autocorrectionDisabled()
            }
            else {
                $0
            }
        }
        .navigationTitle("area.problems")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var problemsFilteredBySearch: [Problem] {
        if searchText.count > 0 {
            return problemsFilteredByPopular.filter { ($0.name?.normalized ?? "").contains(searchText.normalized) }
        }
        else
        {
            return problemsFilteredByPopular
        }
    }
    
    var problemsFilteredByPopular: [Problem] {
        if popular {
            return problems.filter { $0.featured }
        }
        else {
            return problems
        }
    }
}

//struct AreaProblemsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AreaProblemsView()
//    }
//}
