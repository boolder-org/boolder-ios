//
//  FiltersView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 07/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct FiltersView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var presentFilters: Bool
    @Binding var filters: Filters
    
    let viewModel: AreaViewModel
    @State private var segment: Segment = .circuit
    
    enum Segment {
        case circuit
        case level
    }
    
    var body: some View {
        NavigationView {

                List {
                    
                    levels
                    
                    
//                    ForEach(1..<9) { level in
//                        Button {
//                            if let filterRange = filters.gradeRange {
//                                filters.gradeRange = GradeRange.level(level).concatenate(with: filterRange)
//                            }
//                            else {
//                                filters.gradeRange = GradeRange.level(level)
//                            }
//                        } label: {
//                            HStack {
//                                Image(systemName: levelActive(level) ? "largecircle.fill.circle" : "circle")
//                                    .font(Font.body.weight(.bold)).frame(width: 20, height: 20)
//                                Text("Niveau \(level)").foregroundColor(.primary)
//                                Spacer()
//                                Text("\(level*13)").foregroundColor(Color(.systemGray))
//                            }
//                        }
//
//                    }

                }

                .navigationBarTitle("Niveaux", displayMode: .inline)
                .navigationBarItems(
                    leading: Button(action: {
                        filters = Filters()
                        viewModel.mapState.unselectCircuit()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("filters.clear")
                            .padding(.vertical)
                            .font(.body)
                    },
                    trailing: Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("OK")
                            .bold()
                            .padding(.vertical)
                            .padding(.leading, 32)
                    }
                )
//            }
        }
//        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func levelActive(_ level: Int) -> Bool {
        if let filterRange = filters.gradeRange {
            return filterRange.contains(GradeRange.level(level))
        }
        else {
            return false
        }
    }
    
    var levels: some View {
        Section {
            ForEach([GradeRange.beginner, GradeRange.intermediate, GradeRange.advanced], id: \.self) { range in
                Button(action: {
                    if filters.gradeRange == range {
                        filters.gradeRange = nil
                    }
                    else {
                        filters.gradeRange = range
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    HStack {
                        Image(systemName: filters.gradeRange == range ? "largecircle.fill.circle" : "circle")
                            .font(Font.body.weight(.bold)).frame(width: 20, height: 20)
                        
                        Text(range.localizedName).foregroundColor(.primary)
                        Spacer()
                        Text(range.description).foregroundColor(Color(.systemGray)).font(.caption)
                    }
                }
            }
            
            NavigationLink(destination:
                            GradeRangePickerView(gradeRange: filters.gradeRange ?? GradeRange(min: Grade("1a"), max: Grade("9a+")), onSave: { range in
                filters.gradeRange = range
            })
            ) {
                HStack {
                    Image(systemName: (filters.gradeRange?.isCustom ?? false) ? "largecircle.fill.circle" : "circle")
                        .font(Font.body.weight(.bold)).frame(width: 20, height: 20).foregroundColor(.appGreen)
                    
                    Text("filters.grade.range.custom").foregroundColor(.primary)
                    Spacer()
                    Text(customRangeDescription).foregroundColor(Color(.systemGray)).font(.caption)
                }
            }
        }
    }
    
    var circuits: some View {
        Section {
//            if viewModel.circuits.count == 0 {
//                Text("Aucun circuit")
//            }
            ForEach(viewModel.circuits) { circuit in
                Button {
                    presentationMode.wrappedValue.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        viewModel.mapState.selectAndCenterOnCircuit(circuit)
                    }
                    //                        viewModel.mapState.selectAndPresentAndCenterOnProblem(problem)
                } label: {
                    HStack {
                        CircleView(number: "", color: circuit.color.uicolor, height: 20)
                        Text(circuit.color.longName)
                        Spacer()
                        Text(circuit.averageGrade.string)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
    
    var customRangeDescription: String {
        if let range = filters.gradeRange {
            if range.isCustom {
                return range.description
            }
        }
        
        return ""
    }
}

//struct FiltersView_Previews: PreviewProvider {
//    static var previews: some View {
//        FiltersView()
//    }
//}
