//
//  ProblemListView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 25/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ProblemListView: View {
    let areaDataSource: ProblemDataSource
    @Binding var selectedProblem: ProblemAnnotation?
    
    var body: some View {
        List {
            ForEach(Array(self.areaDataSource.groupedAnnotations.keys.sorted()), id: \.self) { grade in
                Section(header:
                    Text("Niveau \(grade)").font(.title).bold().foregroundColor(Color(UIColor.label)).padding(.top, (grade == self.areaDataSource.groupedAnnotations.keys.sorted().first) ? 32 : 0),
                        footer:
                    Rectangle().fill(Color.clear).frame(width: 1, height: (grade == self.areaDataSource.groupedAnnotations.keys.sorted().last) ? 120 : 0, alignment: .center)
                    ) {
                    ForEach(self.areaDataSource.groupedAnnotations[grade]!, id: \.self) { (problem: ProblemAnnotation) in
                        HStack {
                            Text(problem.displayLabel)
                                .font(.headline)
                                .foregroundColor(Color(problem.displayColor()))
                                .frame(minWidth: 30, alignment: .leading)
                            Text(problem.name ?? "-")
                            Spacer()
                            Text(problem.grade?.string ?? "-")
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct ProblemListView_Previews: PreviewProvider {
    static var previews: some View {
        let areaDataSource = ProblemDataSource(circuitFilter: .red, filters: Filters())
        return ProblemListView(areaDataSource: areaDataSource, selectedProblem: .constant(nil))
    }
}
