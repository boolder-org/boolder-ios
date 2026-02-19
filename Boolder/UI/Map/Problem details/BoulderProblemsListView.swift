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
    let boulderId: Int?
    let currentTopoId: Int?
    
    // MARK: - Topo data
    
    private var boulderTopos: [Topo] {
        mapState.boulderTopos
    }
    
    private var topoProblems: [Problem] {
        guard let topoId = currentTopoId else { return [] }
        return problems.filter { $0.topoId == topoId }.sorted { $0.grade < $1.grade }
    }
    
    private var topoProblemsTitle: String {
        let count = topoProblems.count
        return String(
            format: NSLocalizedString(
                count == 1 ? "boulder.info_basic_singular" : "boulder.info_basic",
                comment: ""
            ),
            count
        )
    }
    
    private var allBoulderProblems: [Problem] {
        problems.sorted { $0.grade < $1.grade }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(topoProblems) { problem in
                        problemRow(problem)
                    }
                }
            }
            .navigationTitle(topoProblemsTitle)
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
    
    private func problemRow(_ problem: Problem) -> some View {
        Button {
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
