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
    
    @State private var selectedTopoId: Int?
    
    init(problems: [Problem], boulderId: Int?, currentTopoId: Int?) {
        self.problems = problems
        self.boulderId = boulderId
        self.currentTopoId = currentTopoId
        self._selectedTopoId = State(initialValue: currentTopoId)
    }
    
    // MARK: - Topo data
    
    private var boulderTopos: [Topo] {
        guard let boulderId = boulderId else { return [] }
        return Boulder(id: boulderId).topos
    }
    
    private var topoEntries: [(id: Int, letter: String)] {
        boulderTopos.enumerated().map { index, topo in
            let letter = String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(index))!)
            return (id: topo.id, letter: letter)
        }
    }
    
    private var filteredProblems: [Problem] {
        let filtered: [Problem]
        if let topoId = selectedTopoId {
            filtered = problems.filter { $0.topoId == topoId }
        } else {
            filtered = problems
        }
        return filtered.sorted { $0.grade < $1.grade }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Picker(selection: $selectedTopoId) {
                    Text(NSLocalizedString("boulder.problems_list.all_faces", comment: ""))
                        .tag(nil as Int?)
                    ForEach(topoEntries, id: \.id) { entry in
                        Text("Face \(entry.letter)")
                            .tag(entry.id as Int?)
                    }
                } label: {
                    Text("Face")
                }
                
                ForEach(filteredProblems) { problem in
                    problemRow(problem)
                }
            }
            .navigationTitle(String(format: NSLocalizedString("boulder.problems_title", comment: ""), filteredProblems.count))
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
