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
    
    @State private var isVisible = true
    @State private var hideTask: Task<Void, Never>?
    
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
            if problems.count > 1 && isVisible {
                Text(String(format: NSLocalizedString("problem.startgroup.pagination", comment: ""), currentIndex, problems.count))
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
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isVisible)
        .onAppear {
            scheduleHide()
        }
        .onChange(of: problem) {
            if problems.count > 1 {
                isVisible = true
                scheduleHide()
            } else {
                hideTask?.cancel()
                isVisible = false
            }
        }
    }
    
    private func scheduleHide() {
        hideTask?.cancel()
        hideTask = Task {
            try? await Task.sleep(for: .seconds(2))
            if !Task.isCancelled {
                isVisible = false
            }
        }
    }
}
