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
        guard let boulderId = boulderId else { return [] }
        return Boulder(id: boulderId).topos
    }
    
    private var currentTopoLetter: String {
        guard let currentTopoId = currentTopoId else { return "" }
        for (index, topo) in boulderTopos.enumerated() {
            if topo.id == currentTopoId {
                return String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(index))!)
            }
        }
        return ""
    }
    
    private var topoProblems: [Problem] {
        guard let topoId = currentTopoId else { return [] }
        return problems.filter { $0.topoId == topoId }.sorted { $0.grade < $1.grade }
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
                
                Section {
                    NavigationLink {
                        AllBoulderProblemsView(problems: allBoulderProblems, dismiss: { dismiss() })
                    } label: {
                        Text(NSLocalizedString("boulder.problems_list.all_on_boulder", comment: ""))
                    }
                    .disabled(boulderTopos.count <= 1)
                }
            }
            .navigationTitle("Face \(currentTopoLetter)")
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

// MARK: - All Boulder Problems View

private struct AllBoulderProblemsView: View {
    @Environment(MapState.self) private var mapState: MapState
    
    let problems: [Problem]
    let dismiss: () -> Void
    
    var body: some View {
        List {
            ForEach(problems) { problem in
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
        .navigationTitle(NSLocalizedString("boulder.problems_list.title", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }
}
