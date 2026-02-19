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
        guard let boulderId else { return mapState.boulderTopos }
        return mapState.boulderTopos.filter { $0.boulderId == boulderId }
    }
    
    private var allBoulderProblems: [Problem] {
        problems.sorted { $0.grade < $1.grade }
    }

    private var topoSections: [(title: String, problems: [Problem])] {
        let topoOrder = Dictionary(uniqueKeysWithValues: boulderTopos.enumerated().map { ($0.element.id, $0.offset) })
        let grouped = Dictionary(grouping: allBoulderProblems) { $0.topoId ?? -1 }

        var sections: [(title: String, problems: [Problem])] = boulderTopos.map { topo in
            let topoProblems = grouped[topo.id] ?? []
            let faceLetter = topoLetter(for: topo.id)
            return (title: "Face \(faceLetter)", problems: topoProblems)
        }

        // Keep orphan/unknown topo problems visible at the end.
        let unknownTopoProblems = grouped
            .filter { key, value in key != -1 && topoOrder[key] == nil && !value.isEmpty }
            .flatMap(\.value)
            .sorted { $0.grade < $1.grade }
        if !unknownTopoProblems.isEmpty {
            sections.append((title: "Autres", problems: unknownTopoProblems))
        }

        return sections
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(topoSections, id: \.title) { section in
                    Section(section.title) {
                        ForEach(section.problems) { problem in
                            problemRow(problem)
                        }
                    }
                }
            }
            .navigationTitle("\(allBoulderProblems.count) voies")
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

    private func topoLetter(for topoId: Int) -> String {
        guard let index = boulderTopos.firstIndex(where: { $0.id == topoId }) else {
            return "?"
        }
        return String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(index))!)
    }
}
