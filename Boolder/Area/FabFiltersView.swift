//
//  FabFiltersView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct FabFiltersView: View {
    @State private var presentCircuitFilter = false
    @State private var presentFilters = false
    
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        ZStack {
            HStack(spacing: 16) {
                Button(action: {
                    self.presentCircuitFilter.toggle()
                }) {
                    if dataStore.filters.circuit != nil {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(circuitColor())
                            .frame(width: 20, height: 20)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.init(white: 0.8, alpha: 0.6)), lineWidth: 1.0))
                        Text("Circuit")
                    }
                    else {
                        Text("Pas de circuit")
                    }
                }
                .sheet(isPresented: $presentCircuitFilter) {
                    CircuitFilterView()
                        // FIXME: there is a bug with SwiftUI not passing environment correctly to modal views
                        // remove these lines as soon as it's fixed
                        .environmentObject(self.dataStore)
                        .environment(\.managedObjectContext, self.managedObjectContext)
                        .accentColor(Color.green)
                }
                
                Divider().frame(width: 1, height: 44, alignment: .center)
                
                Button(action: {
                    self.presentFilters.toggle()
                }) {
                    Image(systemName: "slider.horizontal.3")
                    Text("Filtres")
                    
                }
                .padding(.vertical, 12)
                .sheet(isPresented: $presentFilters) {
                    FiltersView()
                        // FIXME: there is a bug with SwiftUI not passing environment correctly to modal views
                        // remove these lines as soon as it's fixed
                        .environmentObject(self.dataStore)
                        .environment(\.managedObjectContext, self.managedObjectContext)
                        .accentColor(Color.green)
                }
            }
        }
        .accentColor(Color(.label))
        .padding(.horizontal, 16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.25))
        .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
        .padding()
    }
    
    func circuitColor() -> Color {
        if let circuit = dataStore.filters.circuit {
            return Color(Circuit(circuit).color)
        }
        else {
            return Color.white
        }
    }
}

struct FabFiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FabFiltersView()
            .environmentObject(DataStore.shared)
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
