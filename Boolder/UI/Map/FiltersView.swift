//
//  FiltersView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 07/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct FiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var presentFilters: Bool
    @Binding var filters: Filters
    
    @Environment(MapState.self) private var mapState: MapState
    
    var body: some View {
        NavigationView {
            
            List {
                Section {
                    ForEach([GradeRange.beginner, GradeRange.level4, GradeRange.level5, GradeRange.level6, GradeRange.level7], id: \.self) { range in
                        Button {
                            if filters.gradeRange == range {
                                filters.gradeRange = nil
                            }
                            else {
                                filters.gradeRange = range
                                dismiss()
                            }
                        } label : {
                            HStack {
                                Image(systemName: filters.gradeRange == range ? "largecircle.fill.circle" : "circle")
                                    .font(Font.body.weight(.bold)).frame(width: 20, height: 20)
                                
                                Text(range.description).foregroundColor(.primary)
                                Spacer()
                                if(range == .beginner) {
                                    Text("filters.beginner").foregroundColor(Color(.systemGray))
                                }
                            }
                        }
                    }
                }
                
                Section {
                    
                    NavigationLink(destination: GradeRangePickerView(gradeRange: filters.gradeRange ?? GradeRange(min: Grade("1a"), max: Grade("9a+")), onSave: { range in filters.gradeRange = range})) {
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
            .navigationBarTitle("filters.levels", displayMode: .inline)
            .navigationBarItems(
                leading: Button {
                    mapState.clearFilters()
                    mapState.unselectCircuit()
                    dismiss()
                } label: {
                    Text("filters.clear")
                        .padding(.vertical)
                        .font(.body)
                },
                trailing: Button {
                    dismiss()
                } label: {
                    Text("OK")
                        .bold()
                        .padding(.vertical)
                }
            )
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
