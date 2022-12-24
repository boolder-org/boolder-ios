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
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    ForEach([GradeRange.beginner, GradeRange.intermediate, GradeRange.advanced], id: \.self) { range in
                        Button(action: {
                            if filters.gradeRange == range {
                                filters.gradeRange = nil
                            }
                            else {
                                filters.gradeRange = range
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
            .navigationBarTitle("filters.level", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    filters = Filters()
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
