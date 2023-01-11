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
    
    let mapState: MapState
    
    @State private var segment: Segment = .circuit
    
    enum Segment {
        case circuit
        case level
    }
    
    var body: some View {
        NavigationView {

                levels
                .navigationBarTitle("filters.levels", displayMode: .inline)
                .navigationBarItems(
                    leading: Button(action: {
                        mapState.clearFilters()
                        mapState.unselectCircuit()
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

    
    var levels: some View {
        List {
            Section {
                ForEach([GradeRange.beginner, GradeRange.level4, GradeRange.level5, GradeRange.level6, GradeRange.level7], id: \.self) { range in
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
