//
//  FiltersView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

let userVisibleSteepnessTypes: [Steepness] = [.wall, .slab, .overhang, .traverse]

struct FiltersView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: DataStore
    
    @State private var presentSteepnessFilter = false
    @State private var showMoreFilters = UserDefaults.standard.bool(forKey: "ShowMoreFilters")
    @Binding var presentFilters: Bool
    @Binding var filters: Filters
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("filters.level")) {
                    
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
                                
                                Text(range.name).foregroundColor(.primary)
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
                            
                            Text("Personnalisé").foregroundColor(.primary)
                            Spacer()
                            Text(desc).foregroundColor(Color(.systemGray)).font(.caption)
                        }
                    }

                }
                
                if showMoreFilters {
                    Section(header: Text("filters.advanced_filters")) {
                        NavigationLink(destination: SteepnessFilterView(presentFilters: $presentFilters, filters: $filters), isActive: $presentSteepnessFilter) {
                            HStack {
                                Text("filters.type")
                                Spacer()
                                Text(labelForSteepness())
                                    .foregroundColor(Color.gray)
                            }
                        }
                        
                        NavigationLink(destination: CircuitFilterView(filters: $filters)) {
                            HStack {
                                if let circuitId = filters.circuitId, let circuit = dataStore.circuit(withId: circuitId) {
                                    Text("filters.circuit")
                                    Spacer()
                                    Text("\(circuit.color.shortName())").foregroundColor(Color(.systemGray))
                                } else
                                {
                                    Text("filters.circuit")
                                }
                            }
                        }
                        
                        HStack {
                            Toggle(isOn: $filters.favorite) {
                                Text("filters.favorite")
                                    .foregroundColor(dataStore.favorites().count == 0 ? Color(.systemGray) : .primary)
                            }
                            .disabled(dataStore.favorites().count == 0)
                        }
                        
                        HStack {
                            Toggle(isOn: $filters.ticked) {
                                Text("filters.ticked")
                                    .foregroundColor(dataStore.ticks().count == 0 ? Color(.systemGray) : .primary)
                            }
                            .disabled(dataStore.ticks().count == 0)
                        }
                    }
                    
                    #if DEVELOPMENT
                    Section(header: Text("Dev only")) {
                        HStack {
                            Toggle(isOn: $filters.mapMakerModeEnabled) {
                                Text("Hide mapped problems")
                            }
                        }
                    }
                    #endif
                }
                
                Section {
                    HStack {
                        Button(action: {
                            showMoreFilters.toggle()
                            UserDefaults.standard.set(showMoreFilters, forKey: "ShowMoreFilters")
                        }) {
                            HStack {
                                Spacer()
                                showMoreFilters ? Text("filters.show_less_filters") : Text("filters.show_more_filters")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("filters.title", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    filters = Filters()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("filters.reset")
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
    
    var desc: String {
        if let range = filters.gradeRange {
            if range.isCustom {
                return range.description
            }
        }
        
        return ""
    }
    
    private func labelForSteepness() -> String {
        if filters.steepness == Filters().steepness {
            return ""
        }
        
        let visibleAndSelected = filters.steepness.intersection(userVisibleSteepnessTypes)
        let string = visibleAndSelected.map{ $0.localizedName.lowercased() }.joined(separator: ", ")
        return String(string.prefix(1).capitalized + string.dropFirst())
    }
}

struct FiltersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FiltersView(presentFilters: .constant(true), filters: .constant(Filters()))
            .environmentObject(DataStore())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SteepnessFilterView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var presentFilters: Bool
    
    @Binding var filters: Filters
    
    var body: some View {
        Form {
            ForEach(userVisibleSteepnessTypes, id: \.self) { steepness in
                
                Button(action: {
                    steepnessTapped(steepness)
                }) {
                    HStack {
                        Image(steepness.imageName)
                            .foregroundColor(.primary)
                            .frame(minWidth: 20)
                        Text(steepness.localizedName)
                            .foregroundColor(.primary)
                        Spacer()
                        
                        if filters.steepness.contains(steepness) {
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
                presentFilters = false
            }) {
                Text("OK")
                    .bold()
                    .padding(.vertical)
                    .padding(.leading, 32)
            }
        )
    }
    
    private func steepnessTapped(_ steepness: Steepness) {
        // toggle value for this steepness
        if filters.steepness.contains(steepness) {
            filters.steepness.remove(steepness)
        }
        else {
            filters.steepness.insert(steepness)
        }
        
        // auto add/remove some values for user friendliness
        
        if filters.steepness.isSuperset(of: Set(userVisibleSteepnessTypes)) {
            filters.steepness.formUnion([.other, .roof])
        }
        else {
            filters.steepness.subtract([.other, .roof])
            
            if filters.steepness.contains(.overhang) {
                filters.steepness.insert(.roof)
            }
        }
    }
}
