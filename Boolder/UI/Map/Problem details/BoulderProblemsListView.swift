//
//  BoulderProblemsListView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 13/02/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct BoulderProblemsListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MapState.self) private var mapState: MapState
    
    let problems: [Problem]
    
    private var groupedProblems: [(category: Int, problems: [Problem])] {
        let sorted = problems.sorted { $0.grade < $1.grade }
        let grouped = Dictionary(grouping: sorted) { $0.grade.category }
        return grouped.sorted { $0.key < $1.key }.map { (category: $0.key, problems: $0.value) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedProblems, id: \.category) { group in
                    Section {
                        ForEach(group.problems) { problem in
                            Button {
                                mapState.showAllLines = false
                                mapState.selectProblem(problem)
                                dismiss()
                            } label: {
                                HStack {
                                    ProblemCircleView(problem: problem)
                                    Text(problem.localizedName)
                                    Spacer()
                                    if problem.featured {
                                        Image(systemName: "heart.fill").foregroundColor(.pink)
                                    }
                                    Text(problem.grade.string)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("boulder.problems_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

