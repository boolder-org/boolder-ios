//
//  FiltersView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

let userVisibleSteepnessTypes: [Steepness.SteepnessType] = [.wall, .slab, .overhang, .traverse]

struct FiltersView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: DataStore
    
    @State private var presentGradeFilter = false
    @State private var presentCircuitFilter = false
    @State private var presentSteepnessFilter = false
    @Binding var presentFilters: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: SteepnessFilterView(presentFilters: $presentFilters), isActive: $presentSteepnessFilter) {
                        HStack {
                            Text("type")
                            Spacer()
                            Text(labelForSteepness())
                                .foregroundColor(Color.gray)
                        }
                    }
                    
//                    NavigationLink(destination: HeightFilterView(presentFilters: $presentFilters)) {
//                        HStack {
//                            Text("height")
//                            Spacer()
//                            Text(dataStore.filters.heightMax == Int.max ? "all" : "less than \(String(dataStore.filters.heightMax)) m")
//                                .foregroundColor(Color.gray)
//                        }
//                    }
//                    
//                    NavigationLink(destination: RiskyFilterView(presentFilters: $presentFilters)) {
//                        HStack {
//                            Text("risk")
//                            Spacer()
//                            Text(dataStore.filters.risky ? "all" : "less_risky")
//                                .foregroundColor(Color.gray)
//                        }
//                    }
                    
                    NavigationLink(destination: GradeFilterView(presentFilters: $presentFilters), isActive: $presentGradeFilter) {
                        HStack {
                            Text("level")
                            Spacer()
                            Text(labelForCategories())
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                
                Section {
                    
                    HStack {
                        Toggle(isOn: $dataStore.filters.favorite) {
                            Text("favorite")
                                .foregroundColor(dataStore.favorites().count == 0 ? Color(.systemGray) : Color(.label))
                        }
                        .disabled(dataStore.favorites().count == 0)
                    }
                    
                    HStack {
                        Toggle(isOn: $dataStore.filters.ticked) {
                            Text("ticked")
                                .foregroundColor(dataStore.ticks().count == 0 ? Color(.systemGray) : Color(.label))
                        }
                        .disabled(dataStore.ticks().count == 0)
                    }
                }
            }
            .navigationBarTitle("filters", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    var newFilters = Filters()
                    newFilters.circuit = self.dataStore.filters.circuit
                    self.dataStore.filters = newFilters
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("reset")
                        .padding(.vertical)
                        .font(.body)
                },
                trailing: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("OK")
                        .bold()
                        .padding(.vertical)
                        .padding(.leading, 32)
                }
            )
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func labelForSteepness() -> String {
        if dataStore.filters.steepness == Set(Steepness.SteepnessType.allCases) {
            return NSLocalizedString("all", comment: "")
        }
        
        let visibleAndSelected = dataStore.filters.steepness.intersection(userVisibleSteepnessTypes)
        let string = visibleAndSelected.map{ Steepness($0).name.lowercased() }.joined(separator: ", ")
        return String(string.prefix(1).capitalized + string.dropFirst())
    }
    
    private func labelForCategories() -> String {
        if dataStore.filters.gradeMin == Filters().gradeMin && dataStore.filters.gradeMax == Filters().gradeMax {
            return NSLocalizedString("all", comment: "")
        }
        else {
            return String.localizedStringWithFormat(NSLocalizedString("grade_between", comment: ""), dataStore.filters.gradeMin.string, dataStore.filters.gradeMax.string)
        }
    }
    
    private func consecutiveNumbers(_ categories: [Int]) -> Bool {
        if categories.count < 2 { return false }
        
        for i in 0..<categories.count {
            if i > 0 {
                if categories[i] != (categories[i-1] + 1) { return false }
            }
        }
        return true
    }
}

struct FiltersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FiltersView(presentFilters: .constant(true))
            .environmentObject(DataStore())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct GradeFilterView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var presentFilters: Bool
    
    var body: some View {
        List {
            Section {
                NavigationLink(destination: GradeMinMaxFilterView(gradeFilter: $dataStore.filters.gradeMin, type: .min)) {
                    HStack {
                        Text("level_min")
                        Spacer()
                        Text(dataStore.filters.gradeMin.string)
                            .foregroundColor(Color.gray)
                    }
                }
                
                NavigationLink(destination: GradeMinMaxFilterView(gradeFilter: $dataStore.filters.gradeMax, type: .max)) {
                    HStack {
                        Text("level_max")
                        Spacer()
                        Text(dataStore.filters.gradeMax.string)
                            .foregroundColor(Color.gray)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("level")
        .navigationBarItems(
            trailing: Button(action: {
                self.presentFilters = false
            }) {
                Text("OK")
                    .bold()
                    .padding(.vertical)
                    .padding(.leading, 32)
            }
        )
    }
}

struct GradeMinMaxFilterView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var presentationMode
    @Binding var gradeFilter: Grade
    var type: GradeFilterType
    
    enum GradeFilterType {
        case min
        case max
    }
    
    var body: some View {
        List {
            Section {
                ForEach(Grade.visibleGrades, id: \.self) { grade in
                    Button(action: {
                        if !self.isDisabled(grade: grade) {
                            self.gradeFilter = try! Grade(grade)
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        HStack {
                            Text(grade)
                                .foregroundColor(self.isDisabled(grade: grade) ? Color(.gray) : Color(.label))
                            Spacer()
                            if grade == self.gradeFilter.string {
                                Image(systemName: "checkmark").font(Font.body.weight(.bold))
                                    .disabled(self.isDisabled(grade: grade))
                            }
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle(type == .min ? "level_min" : "level_max")
    }
    
    func isDisabled(grade: String) -> Bool {
        if type == .min {
            return (try! Grade(grade)) > self.dataStore.filters.gradeMax
        }
        else {
            return (try! Grade(grade)) < self.dataStore.filters.gradeMin
        }
    }
}

struct RiskyFilterView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var presentFilters: Bool
    
    var body: some View {
        List {
            Section(
                footer: Text("risky_definition").padding(.top)
            ) {
                Button(action: {
                    
                }) {
                    HStack {
                        Image(systemName: "exclamationmark.shield")
                            .font(.body)
                            .foregroundColor(Color(.label))
                            .frame(minWidth: 16)
                        Text("less_risky.long").foregroundColor(Color(.systemGray))
                        Spacer()
                        Image(systemName: "checkmark").font(Font.body.weight(.bold))
                    }
                .disabled(true)
                }
                
                Button(action: {
                    self.dataStore.filters.risky.toggle()
                }) {
                    HStack {
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.body)
                            .foregroundColor(Color.red)
                            .frame(minWidth: 16)
                        Text("risky.long")
                            .foregroundColor(Color.red)
                        Spacer()
                        if dataStore.filters.risky {
                            Image(systemName: "checkmark").font(Font.body.weight(.bold))
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("risky")
        .navigationBarItems(
            trailing: Button(action: {
                self.presentFilters = false
            }) {
                Text("OK")
                    .bold()
                    .padding(.vertical)
                    .padding(.leading, 32)
            }
        )
    }
}

struct HeightFilterView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var presentFilters: Bool
    let visibleHeightMaxValues = [3,4,5,6,7,8]
    
    var body: some View {
        List {
            Section() {
                ForEach(visibleHeightMaxValues, id: \.self) { height in
                    Button(action: {
                        self.dataStore.filters.heightMax = height
                    }) {
                        HStack {
                            Text("less than \(String(height)) m").foregroundColor(Color(.label))
                            Spacer()
                            if self.dataStore.filters.heightMax == height {
                                Image(systemName: "checkmark").font(Font.body.weight(.bold))
                            }
                        }
                    }
                }
            }
            
            Section {
                Button(action: {
                    self.dataStore.filters.heightMax = Int.max
                }) {
                    HStack {
                        Text("no_limit").foregroundColor(Color(.label))
                        Spacer()
                        if self.dataStore.filters.heightMax == Int.max {
                            Image(systemName: "checkmark").font(Font.body.weight(.bold))
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("height")
        .navigationBarItems(
            trailing: Button(action: {
                self.presentFilters = false
            }) {
                Text("OK")
                    .bold()
                    .padding(.vertical)
                    .padding(.leading, 32)
            }
        )
    }
}

struct SteepnessFilterView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var presentFilters: Bool
    
    var body: some View {
        List {
            ForEach(userVisibleSteepnessTypes, id: \.self) { steepness in
                
                Button(action: {
                    self.steepnessTapped(steepness)
                }) {
                    HStack {
                        Image(Steepness(steepness).imageName)
                            .foregroundColor(Color(.label))
                            .frame(minWidth: 20)
                        Text(Steepness(steepness).name)
                            .foregroundColor(Color(.label))
                        Spacer()
                        
                        if self.dataStore.filters.steepness.contains(steepness) {
                            Image(systemName: "checkmark").font(Font.body.weight(.bold))
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("type")
        .navigationBarItems(
            trailing: Button(action: {
                self.presentFilters = false
            }) {
                Text("OK")
                    .bold()
                    .padding(.vertical)
                    .padding(.leading, 32)
            }
        )
    }
    
    private func steepnessTapped(_ steepness: Steepness.SteepnessType) {
        // toggle value for this steepness
        if self.dataStore.filters.steepness.contains(steepness) {
            self.dataStore.filters.steepness.remove(steepness)
        }
        else {
            self.dataStore.filters.steepness.insert(steepness)
        }
        
        // auto add/remove some values for user friendliness
        
        if self.dataStore.filters.steepness.isSuperset(of: Set(userVisibleSteepnessTypes)) {
            self.dataStore.filters.steepness.formUnion([.other, .roof])
        }
        else {
            self.dataStore.filters.steepness.subtract([.other, .roof])
            
            if self.dataStore.filters.steepness.contains(.overhang) {
                self.dataStore.filters.steepness.insert(.roof)
            }
        }
    }
}
