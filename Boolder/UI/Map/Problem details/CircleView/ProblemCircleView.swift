//
//  ProblemCircleView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 05/11/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ProblemCircleView: View {
    var problem: Problem
    var isDisplayedOnPhoto = false
    
    var body: some View {
        CircleView(number: problem.circuitNumber,
                   color: isDisplayedOnPhoto ? problem.circuitUIColorForPhotoOverlay : problem.circuitUIColor,
                   showStroke: problem.circuitColor == .white && !isDisplayedOnPhoto,
                   showShadow: isDisplayedOnPhoto,
                   scaleEffect: (problem.circuitNumber.isEmpty) ? 0.7 : 1.0
        )
    }
}
//
//struct ProblemCircleView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProblemCircleView(problem: DataStore().problems.first!)
//    }
//}
