//
//  FiltersView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct FiltersView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: DataStore
    
    @State private var presentGradeFilter = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: GradeFilterView(), isActive: $presentGradeFilter) {
                        HStack {
                            Text("Niveaux")
                            Spacer()
                            Text(labelForCategories(dataStore.filters.gradeCategories))
                                .foregroundColor(Color.gray)
                        }
                    }
                }
            }
            .navigationBarTitle("Filtres", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Réinitialiser") {
                    
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
        }
    }
}

struct GradeFilterView: View {
    @EnvironmentObject var dataStore: DataStore
    private let allCategories = [1,2,3,4,5,6,7,8]
    
    var body: some View {
        List {
            Section {
                ForEach(allCategories, id: \.self) { category in
                    Button(action: {
                        if self.dataStore.filters.gradeCategories.contains(category) {
                            self.dataStore.filters.gradeCategories.remove(category)
                        }
                        else {
                            self.dataStore.filters.gradeCategories.insert(category)
                        }
                        // FIXME: use a cleaner solution
                        // read this: https://stackoverflow.com/questions/57459727/why-an-observedobject-array-is-not-updated-in-my-swiftui-application
                        self.dataStore.objectWillChange.send()
                    }) {
                        HStack {
                            Text("Niveau \(category)").foregroundColor(Color(UIColor.label))
                            Spacer()
                            if self.dataStore.filters.gradeCategories.contains(category) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
        }
    .navigationBarTitle("Niveaux")
    }
}
