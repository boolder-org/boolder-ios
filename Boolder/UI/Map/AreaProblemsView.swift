//
//  AreaProblemsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 30/12/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct AreaProblemsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let viewModel: AreaViewModel
    
    var body: some View {
        List {
            Section {
                ForEach(viewModel.problems) { problem in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        viewModel.mapState.presentAreaView = false
                        viewModel.mapState.selectAndPresentAndCenterOnProblem(problem)
                    } label: {
                        HStack {
                            ProblemCircleView(problem: problem)
                            Text(problem.nameWithFallback)
                            Spacer()
                            if(problem.featured) {
                                Image(systemName: "heart.fill").foregroundColor(.pink)
                            }
                            Text(problem.grade.string)
                        }
                        .foregroundColor(.primary)
                    }
                }
                
            }
        }
        .navigationTitle("Voies")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct AreaProblemsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AreaProblemsView()
//    }
//}
