//
//  StartGroupMenuView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 26/01/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct StartGroupMenuView: View {
    @Binding var problem: Problem
    @Environment(MapState.self) private var mapState: MapState
    
    private var startGroup: StartGroup? {
        problem.startGroup
    }
    
    private var problems: [Problem] {
        startGroup?.sortedProblems ?? []
    }
    
    private var currentIndex: Int {
        (problems.firstIndex(of: problem) ?? 0) + 1
    }
    
    var body: some View {
        Group {
            if problems.count > 1 {
                Menu {
                    ForEach(problems) { p in
                        Button {
                            mapState.skipBounceAnimation = true
                            mapState.selectProblem(p)
                        } label: {
                            HStack {
                                Text("\(p.localizedName) \(p.grade.string)")
                                if p.id == problem.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(String(format: NSLocalizedString("problem.startgroup.pagination", comment: ""), currentIndex, problems.count))
                        Image(systemName: "chevron.down")
                    }
                    .modify {
                        if #available(iOS 26, *) {
                            $0.foregroundColor(.primary)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .glassEffect()
                        } else {
                            $0
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.gray.opacity(0.8))
                                .foregroundColor(Color(UIColor.systemBackground))
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

