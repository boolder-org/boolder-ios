//
//  AllFiltersView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 26/02/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct AllFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MapState.self) private var mapState: MapState
    
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: []) var favorites: FetchedResults<Favorite>
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    @State private var showingAlertFavorite = false
    @State private var showingAlertTicked = false
    
    var body: some View {
        @Bindable var mapState = mapState
        
        NavigationView {
            List {
                Section {
                    if circuits.count > 0 {
                        NavigationLink {
                            CircuitFilterList(dismissSheet: dismiss)
                        } label: {
                            HStack {
                                Image("circuit")
                                Text("Circuit")
                                Spacer()
                                if let circuit = mapState.selectedCircuit {
                                    CircleView(number: "", color: circuit.color.uicolor, height: 16)
                                    Text(circuit.color.shortName)
                                        .foregroundColor(Color(.systemGray))
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    
                    NavigationLink {
                        LevelFilterList(dismissSheet: dismiss)
                    } label: {
                        HStack {
                            Image(systemName: "chart.bar")
                            Text("filters.level")
                            Spacer()
                            if let range = mapState.filters.gradeRange {
                                Text(range.description)
                                    .foregroundColor(Color(.systemGray))
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section {
                    Button {
                        let previous = mapState.filters.popular
                        mapState.clearFilters()
                        mapState.unselectCircuit()
                        mapState.filters.popular = !previous
                        mapState.filtersRefresh()
                    } label: {
                        HStack {
                            Image(systemName: "heart")
                            Text("filters.popular")
                            Spacer()
                            if mapState.filters.popular {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.appGreen)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section {
                    Button {
                        if favorites.isEmpty {
                            if mapState.filters.favorite {
                                mapState.filters.favorite = false
                                mapState.filtersRefresh()
                            } else {
                                showingAlertFavorite = true
                            }
                        } else {
                            let previous = mapState.filters.favorite
                            mapState.clearFilters()
                            mapState.unselectCircuit()
                            mapState.filters.favorite = !previous
                            mapState.filtersRefresh()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "star")
                            Text("filters.favorite")
                            Spacer()
                            if mapState.filters.favorite {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.appGreen)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    .alert(isPresented: $showingAlertFavorite) {
                        Alert(
                            title: Text("filters.no_favorites_alert.title"),
                            message: Text("filters.no_favorites_alert.message"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    
                    Button {
                        if ticks.isEmpty {
                            if mapState.filters.ticked {
                                mapState.filters.ticked = false
                                mapState.filtersRefresh()
                            } else {
                                showingAlertTicked = true
                            }
                        } else {
                            let previous = mapState.filters.ticked
                            mapState.clearFilters()
                            mapState.unselectCircuit()
                            mapState.filters.ticked = !previous
                            mapState.filtersRefresh()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("filters.ticked")
                            Spacer()
                            if mapState.filters.ticked {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.appGreen)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    .alert(isPresented: $showingAlertTicked) {
                        Alert(
                            title: Text("filters.no_ticks_alert.title"),
                            message: Text("filters.no_ticks_alert.message"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
            .navigationTitle("filters.title")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button {
                    dismiss()
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(350))
                        mapState.clearFilters()
                        mapState.unselectCircuit()
                    }
                } label: {
                    Text("filters.clear")
                        .padding(.vertical)
                        .font(.body)
                },
                trailing: confirmButton
            )
        }
    }
    
    var confirmButton: some View {
        Group {
            if #available(iOS 26, *) {
                Button(role: .confirm) { dismiss() }
            } else {
                Button {
                    dismiss()
                } label: {
                    Text("OK")
                        .bold()
                        .padding(.vertical)
                }
            }
        }
    }
    
    var circuits: [Circuit] {
        guard let area = mapState.selectedArea else { return [] }
        return area.circuits
    }
}

// MARK: - Circuit Filter List

private struct CircuitFilterList: View {
    var dismissSheet: DismissAction
    @Environment(MapState.self) private var mapState: MapState
    
    var body: some View {
        List {
            Section {
                ForEach(circuits) { circuit in
                    Button {
                        if mapState.selectedCircuit?.id == circuit.id {
                            mapState.unselectCircuit()
                        } else {
                            mapState.clearFilters()
                            mapState.selectAndCenterOnCircuit(circuit)
                            mapState.displayCircuitStartButton = true
                        }
                    } label: {
                        HStack {
                            CircleView(number: "", color: circuit.color.uicolor, height: 20)
                            Text(circuit.color.longName)
                            Spacer()
                            if circuit.beginnerFriendly {
                                Image(systemName: "face.smiling")
                                    .foregroundColor(.green)
                                    .font(.title3)
                            }
                            if circuit.dangerous {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(.orange)
                                    .font(.title3)
                            }
                            Text(circuit.averageGrade.string)
                            
                            if mapState.selectedCircuit?.id == circuit.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.appGreen)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
        }
        .navigationTitle("Circuits")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                confirmButton
            }
        }
    }
    
    var confirmButton: some View {
        Group {
            if #available(iOS 26, *) {
                Button(role: .confirm) { dismissSheet() }
            } else {
                Button {
                    dismissSheet()
                } label: {
                    Text("OK").bold().padding(.vertical)
                }
            }
        }
    }
    
    var circuits: [Circuit] {
        guard let area = mapState.selectedArea else { return [] }
        return area.circuits
    }
}

// MARK: - Level Filter List

private struct LevelFilterList: View {
    var dismissSheet: DismissAction
    @Environment(MapState.self) private var mapState: MapState
    
    var body: some View {
        @Bindable var mapState = mapState
        
        List {
            Section {
                ForEach([GradeRange.beginner, .level4, .level5, .level6, .level7], id: \.self) { range in
                    Button {
                        mapState.unselectCircuit()
                        if mapState.filters.gradeRange == range {
                            mapState.filters.gradeRange = nil
                        } else {
                            mapState.filters.gradeRange = range
                        }
                        mapState.filtersRefresh()
                    } label: {
                        HStack {
                            Text(range.description).foregroundColor(.primary)
                            Spacer()
                            if range == .beginner {
                                Text("filters.beginner").foregroundColor(Color(.systemGray))
                            }
                            if mapState.filters.gradeRange == range {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.appGreen)
                            }
                        }
                    }
                }
            }
            
            Section {
                NavigationLink(destination: GradeRangePickerView(
                    gradeRange: mapState.filters.gradeRange ?? GradeRange(min: Grade("1a"), max: Grade("9a+")),
                    onSave: { range in
                        mapState.unselectCircuit()
                        mapState.filters.gradeRange = range
                        mapState.filtersRefresh()
                    }
                )) {
                    HStack {
                        Text("filters.grade.range.custom").foregroundColor(.primary)
                        Spacer()
                        if let range = mapState.filters.gradeRange, range.isCustom {
                            Text(range.description).foregroundColor(Color(.systemGray))
                            Image(systemName: "checkmark")
                                .foregroundColor(.appGreen)
                        }
                    }
                }
            }
        }
        .navigationTitle("filters.levels")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                confirmButton
            }
        }
    }
    
    var confirmButton: some View {
        Group {
            if #available(iOS 26, *) {
                Button(role: .confirm) { dismissSheet() }
            } else {
                Button {
                    dismissSheet()
                } label: {
                    Text("OK").bold().padding(.vertical)
                }
            }
        }
    }
}
