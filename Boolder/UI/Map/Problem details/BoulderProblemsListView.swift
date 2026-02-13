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
    @State private var selectedSegment: Segment = .photo
    
    private enum Segment: String, CaseIterable, Identifiable {
        case photo
        case grade
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .photo:
                return NSLocalizedString("boulder.problems_list.photo", comment: "")
            case .grade:
                return NSLocalizedString("boulder.problems_list.grade", comment: "")
            }
        }
    }
    
    // MARK: - Photo grouping (by topo position)
    
    private var boulderTopos: [Topo] {
        guard let boulderId = boulderId else { return [] }
        return Boulder(id: boulderId).topos
    }
    
    private var groupedByTopo: [(index: Int, letter: String, topo: Topo, problems: [Problem])] {
        boulderTopos.enumerated().compactMap { index, topo in
            let letter = String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(index))!)
            let topoProblems = problems
                .filter { $0.topoId == topo.id }
                .sorted { $0.grade < $1.grade }
            guard !topoProblems.isEmpty else { return nil }
            return (index: index, letter: letter, topo: topo, problems: topoProblems)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedSegment) {
                    ForEach(Segment.allCases) { segment in
                        Text(segment.title).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                switch selectedSegment {
                case .photo:
                    photoList
                case .grade:
                    gradeList
                }
            }
            .navigationTitle(String(format: NSLocalizedString("boulder.problems_title", comment: ""), problems.count))
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
    
    private var photoList: some View {
        List {
            ForEach(groupedByTopo, id: \.index) { group in
                Section {
                    ForEach(group.problems) { problem in
                        problemRow(problem)
                    }
                } header: {
                    Text("Face \(group.letter)")
                }
            }
        }
    }
    
    private var sortedByGrade: [Problem] {
        problems.sorted { $0.grade < $1.grade }
    }
    
    private var gradeList: some View {
        List {
            ForEach(sortedByGrade) { problem in
                problemRow(problem)
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
