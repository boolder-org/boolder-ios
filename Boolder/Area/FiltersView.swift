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
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination:
                        CircuitFilterView(presentCircuitFilter: $presentCircuitFilter)
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
                            Text("Niveaux")
                            Spacer()
                            Text(labelForCategories(dataStore.filters.gradeCategories))
                                .foregroundColor(Color.gray)
                        }
                    }
                    
                    HStack {
                        Toggle(isOn: $dataStore.filters.favorite) {
                            Text("Favori")
                        }
                    }
                }
                
                Section {
                    NavigationLink(destination: SteepnessFilterView(), isActive: $presentSteepnessFilter) {
                        HStack {
                            Text("Type")
                            Spacer()
                            Text(labelForSteepness())
                                .foregroundColor(Color.gray)
                        }
                    }
                
                    HStack {
                        Toggle(isOn: $dataStore.filters.photoPresent) {
                            Text("Avec photo")
                        }
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
        let categories = Array(categories).sorted()
        
        if categories.isEmpty {
            return "Tous"
        }
        else {
            if categories.count == 1 {
                return String(categories.first!)
            }
            else if consecutiveNumbers(categories) {
                return "\(categories.min()!) à \(categories.max()!)"
            }
            else
            {
                return categories.sorted().map{String($0)}.joined(separator: ",")
            }
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
            FiltersView()
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
            
            Section {
                Button(action: {
                    self.dataStore.filters.gradeCategories = Set<Int>()
                }) {
                    Text("Tous les niveaux").foregroundColor(Color(.label))
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Niveaux")
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
