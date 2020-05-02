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
                    NavigationLink(destination:
                        CircuitFilterView(presentCircuitFilter: $presentCircuitFilter, presentFilters: $presentFilters)
                        .listStyle(GroupedListStyle())
                        .environment(\.horizontalSizeClass, .regular)
                        .navigationBarTitle("Circuit", displayMode: .inline)
                    , isActive: $presentCircuitFilter) {
                        HStack {
                            Text("Circuit")
                            Spacer()
                            Text(labelForCircuit())
                                .foregroundColor(Color.gray)
                        }
                    }
                
                    NavigationLink(destination: GradeFilterView(), isActive: $presentGradeFilter) {
                        HStack {
                            Text("Niveau")
                            Spacer()
                            Text(labelForCategories(dataStore.filters.gradeCategories))
                                .foregroundColor(Color.gray)
                        }
                    }
                    
                    NavigationLink(destination: SteepnessFilterView(), isActive: $presentSteepnessFilter) {
                        HStack {
                            Text("Type")
                            Spacer()
                            Text(labelForSteepness())
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                
                Section {
                    
                    NavigationLink(destination: HeightFilterView()) {
                        HStack {
                            Text("Hauteur")
                            Spacer()
                            Text(dataStore.filters.heightMax == Int.max ? "Tous" : "Moins de \(String(dataStore.filters.heightMax)) m")
                                .foregroundColor(Color.gray)
                        }
                    }
                    
                    NavigationLink(destination: RiskyFilterView()) {
                        HStack {
                            Text("Risque en cas de chute")
                            Spacer()
                            Text(dataStore.filters.risky ? "Tous" : "Moins dangereux")
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                
                Section {
                    
                    HStack {
                        Toggle(isOn: $dataStore.filters.favorite) {
                            Text("Favori")
                                .foregroundColor(dataStore.favorites().count == 0 ? Color(.systemGray) : Color(.label))
                        }
                        .disabled(dataStore.favorites().count == 0)
                    }
                    
                    HStack {
                        Toggle(isOn: $dataStore.filters.ticked) {
                            Text("Coché")
                                .foregroundColor(dataStore.ticks().count == 0 ? Color(.systemGray) : Color(.label))
                        }
                        .disabled(dataStore.ticks().count == 0)
                    }
                }
            }
            .navigationBarTitle("Filtres", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Réinitialiser") {
                    self.dataStore.filters = Filters()
                    self.presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("OK").bold()
                }
            )
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
        }
    }
    
    private func labelForCircuit() -> String {
        if let circuit = dataStore.filters.circuit {
            return Circuit(circuit).name
        }
        else {
            return "Aucun"
        }
    }
    
    private func labelForSteepness() -> String {
        if dataStore.filters.steepness == Set(Steepness.SteepnessType.allCases) {
            return "Tous"
        }
        
        let visibleAndSelected = dataStore.filters.steepness.intersection(userVisibleSteepnessTypes)
        let string = visibleAndSelected.map{ Steepness($0).name.lowercased() }.joined(separator: ", ")
        return String(string.prefix(1).capitalized + string.dropFirst())
    }
    
    private func labelForCategories(_ categories: Set<Int>) -> String {
        if categories == Set(Filters.allGradeCategories) {
            return "Tous"
        }
        
        let array = Array(categories).sorted()
        
        if array.count == 1 {
            return String(array.first!)
        }
        else if consecutiveNumbers(array) {
            return "\(array.min()!) à \(array.max()!)"
        }
        else
        {
            return array.sorted().map{String($0)}.joined(separator: ",")
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
            .environmentObject(DataStore.shared)
        }
    }
}

struct GradeFilterView: View {
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        List {
            Section {
                ForEach(Filters.allGradeCategories, id: \.self) { category in
                    Button(action: {
                        if self.dataStore.filters.gradeCategories.contains(category) {
                            self.dataStore.filters.gradeCategories.remove(category)
                        }
                        else {
                            self.dataStore.filters.gradeCategories.insert(category)
                        }
                    }) {
                        HStack {
                            Text("Niveau \(category)").foregroundColor(Color(.label))
                            Spacer()
                            if self.dataStore.filters.gradeCategories.contains(category) {
                                Image(systemName: "checkmark").font(Font.body.weight(.bold))
                            }
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Niveau")
    }
}

struct RiskyFilterView: View {
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        List {
            Section(
                footer: Text("Une voie est considérée comme dangereuse lorsque le terrain rend la réception difficile ou lorsque la hauteur est importante.").padding(.top)
            ) {
                Button(action: {
                    
                }) {
                    HStack {
                        Image(systemName: "exclamationmark.shield")
                            .font(.body)
                            .foregroundColor(Color(.label))
                            .frame(minWidth: 16)
                        Text("Moins dangereux en cas de chute").foregroundColor(Color(.label))
                        Spacer()
                        Image(systemName: "checkmark").font(Font.body.weight(.bold))
                    }
                }
                
                Button(action: {
                    self.dataStore.filters.risky.toggle()
                }) {
                    HStack {
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.body)
                            .foregroundColor(Color.red)
                            .frame(minWidth: 16)
                        Text("Dangereux en cas de chute")
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
        .navigationBarTitle("Risque en cas de chute")
    }
}

struct HeightFilterView: View {
    @EnvironmentObject var dataStore: DataStore
    let visibleHeightMaxValues = [3,4,5,6,7,8]
    
    var body: some View {
        List {
            Section() {
                ForEach(visibleHeightMaxValues, id: \.self) { height in
                    Button(action: {
                        self.dataStore.filters.heightMax = height
                    }) {
                        HStack {
                            Text("Moins de \(String(height)) m").foregroundColor(Color(.label))
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
                        Text("Pas de limite").foregroundColor(Color(.label))
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
        .navigationBarTitle("Hauteur")
    }
}

struct SteepnessFilterView: View {
    @EnvironmentObject var dataStore: DataStore
    
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
        .navigationBarTitle("Type")
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
