//
//  ProblemCardView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 05/03/2025.
//  Copyright © 2025 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ProblemCardView: View {
    let problem: Problem
    @ObservedObject var mapState: MapState
    
    var variants: some View {
//        VStack {
            HStack {
//                Spacer()
        
                if(problem.variants.count > 1) {
                    Menu {
                        ForEach(problem.variants) { variant in
                            Button {
                                mapState.selectProblem(variant)
                            } label: {
                                Text("\(variant.localizedName) \(variant.grade.string)")
                            }
                        }
                    } label: {
                        HStack {
//                            Text("+\(problem.variants.count - 1)")
                            Image(systemName: "chevron.down")
                        }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.gray.opacity(0.8))
                            .foregroundColor(Color(UIColor.systemBackground))
                            .cornerRadius(16)
                            .padding(8)
                    }
                }
//            }
//            
//            Spacer()
        }
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            VStack(alignment: .leading, spacing: 4) {
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(problem.localizedName)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .fixedSize(horizontal: false, vertical: true)
                            .minimumScaleFactor(0.5)
                        
                        Spacer()
                        
                        Text(problem.grade.string)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        variants
                    }
                    .padding(.top, 4)
                }
                
                HStack(alignment: .firstTextBaseline) {
                    
                    if(problem.sitStart) {
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
                    
//                    if isTicked() {
//                        Image(systemName: "checkmark.circle.fill")
//                            .foregroundColor(Color.appGreen)
//                    }
//                    else if isFavorite() {
//                        Image(systemName: "star.fill")
//                            .foregroundColor(Color.yellow)
//                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

//#Preview {
//    ProblemCardView()
//}
