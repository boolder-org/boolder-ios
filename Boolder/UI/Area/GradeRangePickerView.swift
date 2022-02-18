//
//  GradeRangePickerView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 18/02/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct GradeRangePickerView: View {
    var gradeRange: GradeRange
    @State private var gradeMin: String
    @State private var gradeMax: String
    var onSave: (GradeRange) -> Void
    
    var body: some View {
        Form {
            Section {
                Picker("Grade min", selection: $gradeMin) {
                    ForEach(Grade.visibleGrades, id: \.self) {
                        Text($0)
                    }
                }
                .onChange(of: gradeMin) { a in
                    save()
                }
            }
            
            Section {
                Picker("Grade max", selection: $gradeMax) {
                    ForEach(Grade.visibleGrades, id: \.self) {
                        Text($0)
                    }
                }
            }
            .onChange(of: gradeMax) { a in
                save()
            }
        }
        .navigationTitle("Niveau")
        .onAppear {
            save()
        }
    }
    
    func save() -> Void {
        onSave(GradeRange(min: Grade(gradeMin), max: Grade(gradeMax)))
    }
    
    init(gradeRange: GradeRange, onSave: @escaping (GradeRange) -> Void) {
        self.gradeRange = gradeRange
        self.onSave = onSave

        _gradeMin = State(initialValue: gradeRange.min.string)
        _gradeMax = State(initialValue: gradeRange.max.string)
    }
}

struct GradeRangePicker_Previews: PreviewProvider {
    static var previews: some View {
        GradeRangePickerView(gradeRange: GradeRange(min: Grade("1a"), max: Grade("9a"))) {_ in }
    }
}
