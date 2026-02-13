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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(problems.sorted { $0.grade < $1.grade }) { problem in
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
            .navigationTitle("boulder.problems_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(.secondaryLabel))
                            .padding(6)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

