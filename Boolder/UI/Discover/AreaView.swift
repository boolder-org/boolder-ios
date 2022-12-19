//
//  AreaView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/12/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI


struct AreaView: View {
    let viewModel: AreaViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.problems) { problem in
                HStack {
                    ProblemCircleView(problem: problem)
                    Text(problem.nameWithFallback)
                    Spacer()
                    Text(problem.grade.string)
                }
            }
        }
        .navigationTitle(viewModel.area.name)
    }
    
    
}

//struct AreaView_Previews: PreviewProvider {
//    static var previews: some View {
//        AreaView(viewModel: AreaViewModel(areaId: 1))
//    }
//}
