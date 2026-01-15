//
//  VariantsMenuView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 15/01/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct VariantsMenuView: View {
    @Binding var problem: Problem
    @Environment(MapState.self) private var mapState: MapState
    
    @State private var variants: [Problem] = []
    
    var body: some View {
        Group {
            if variants.count > 1 {
                Menu {
                    ForEach(variants) { p in
                        Button {
                            mapState.selectProblem(p)
                        } label: {
                            Text("\(p.localizedName) \(p.grade.string)")
                        }
                    }
                } label: {
                    HStack {
                        Text(String(format: NSLocalizedString("problem.variants", comment: ""), variants.count))
                        Image(systemName: "chevron.down")
                    }
                    .modify {
                        if #available(iOS 26, *) {
                            $0.foregroundColor(.primary)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .glassEffect()
                                .padding(12)
                        } else {
                            $0
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.gray.opacity(0.8))
                                .foregroundColor(Color(UIColor.systemBackground))
                                .cornerRadius(16)
                                .padding(8)
                        }
                    }
                }
            }
        }
        .onAppear {
            computeVariants()
        }
        .onChange(of: problem) {
            computeVariants()
        }
    }
    
    private func computeVariants() {
        variants = problem.variants
    }
}

