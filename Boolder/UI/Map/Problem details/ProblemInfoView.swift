//
//  ProblemInfoView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 15/01/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ProblemInfoView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: []) var favorites: FetchedResults<Favorite>
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    let problem: Problem
    let titleFont: Font
    
    init(problem: Problem, titleFont: Font = .title) {
        self.problem = problem
        self.titleFont = titleFont
    }
    
    private var saveManager: ProblemSaveManager {
        ProblemSaveManager(
            problem: problem,
            favorites: favorites,
            ticks: ticks,
            managedObjectContext: managedObjectContext
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if problem.circuitId != nil {
                    ProblemCircleView(problem: problem)
                }
                
                Text(problem.localizedName)
                    .font(titleFont)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .fixedSize(horizontal: false, vertical: true)
                    .minimumScaleFactor(0.5)
                
                Spacer()
                
                Text(problem.grade.string)
                    .font(titleFont)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            HStack(alignment: .firstTextBaseline) {
                if problem.sitStart {
                    Image(systemName: "figure.rower")
                    Text("problem.sit_start")
                        .font(.body)
                }
                
                if problem.steepness != .other {
                    if problem.sitStart {
                        Text("•")
                            .font(.body)
                    }
                    
                    HStack(alignment: .firstTextBaseline) {
                        Image(problem.steepness.imageName)
                            .frame(minWidth: 16)
                        Text(problem.steepness.localizedName)
                    }
                    .font(.body)
                }
                
                Spacer()
                
                if saveManager.isTicked() {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.appGreen)
                }
                else if saveManager.isFavorite() {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.yellow)
                }
            }
        }
    }
}

