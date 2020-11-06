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
    
    @State private var presentSteepnessFilter = false
    @Binding var presentFilters: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("filters.level").padding(.top, 16)) {
                    
                    ForEach(GradeRange.allCases, id: \.self) { range in
                        Button(action: {
                            if self.dataStore.filters.gradeRange == range {
                                self.dataStore.filters.gradeRange = nil
                            }
                            else {
                                self.dataStore.filters.gradeRange = range
                                self.dataStore.filters.circuit = nil
                            }
                        }) {
                            HStack {
                                Image(systemName: self.dataStore.filters.gradeRange == range ? "largecircle.fill.circle" : "circle")
                                    .font(Font.body.weight(.bold)).frame(width: 20, height: 20)
                                
                                Text(range.name).foregroundColor(Color(.label))
                                Spacer()
                                Text(range.description).foregroundColor(Color(.systemGray)).font(.caption)
                            }
                        }
                    }
                    
                    NavigationLink(destination: CircuitFilterView()) {
                        HStack {
                            
                            if let circuit = self.dataStore.filters.circuit {
                                Image(systemName: "largecircle.fill.circle").font(Font.body.weight(.bold)).frame(width: 20, height: 20).foregroundColor(Color.green)
                                Text("filters.circuit")
                                Spacer()
                                Text("\(circuit.shortName())").foregroundColor(Color(.systemGray)).font(.caption)
                            } else
                            {
                                Image(systemName: "circle").font(Font.body.weight(.bold)).frame(width: 20, height: 20).foregroundColor(Color.green)
                                Text("filters.circuit")
                            }
                        }
                    }
                }
                
                Section(header: Text("filters.advanced_filters")) {
                    NavigationLink(destination: SteepnessFilterView(presentFilters: $presentFilters), isActive: $presentSteepnessFilter) {
                        HStack {
                            Text("filters.type")
                            Spacer()
                            Text(labelForSteepness())
                                .foregroundColor(Color.gray)
                        }
                    }
                    
                    HStack {
                        Toggle(isOn: $dataStore.filters.favorite) {
                            Text("filters.favorite")
                                .foregroundColor(dataStore.favorites().count == 0 ? Color(.systemGray) : Color(.label))
                        }
                        .disabled(dataStore.favorites().count == 0)
                    }
                    
                    HStack {
                        Toggle(isOn: $dataStore.filters.ticked) {
                            Text("filters.ticked")
                                .foregroundColor(dataStore.ticks().count == 0 ? Color(.systemGray) : Color(.label))
                        }
                        .disabled(dataStore.ticks().count == 0)
                    }
                }
            }
            .navigationBarTitle("filters.title", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    self.dataStore.filters = Filters()
                }) {
                    Text("filters.reset")
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
        if dataStore.filters.steepness == Filters().steepness {
            return NSLocalizedString("filters.all", comment: "")
        }
        
        let visibleAndSelected = dataStore.filters.steepness.intersection(userVisibleSteepnessTypes).sorted()
        let string = visibleAndSelected.map{ Steepness($0).name.lowercased() }.joined(separator: ", ")
        return String(string.prefix(1).capitalized + string.dropFirst())
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

struct SteepnessFilterView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var presentFilters: Bool
    
    var body: some View {
        Form {
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
        .navigationBarTitle("filters.type")
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
