//
//  CircuitFilterView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct CircuitFilterView: View {
    let circuits = [
        Circuit.CircuitType.yellow,
        Circuit.CircuitType.orange,
        Circuit.CircuitType.blue,
        Circuit.CircuitType.skyBlue,
        Circuit.CircuitType.red,
        Circuit.CircuitType.white,
    ]
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var areaDataSource: DataStore
    
    var body: some View {
        NavigationView {
            List {
                ForEach(circuits, id: \.self) { circuitType in
                    Button(action: {
                        self.areaDataSource.filters.circuit = circuitType
                        self.dismiss()
                    }) {
                        HStack(alignment: .center) {
                            CircuitRectangle(color: Color(Circuit(circuitType).color))
                            
                            Text("\(Circuit(circuitType).name)")
                            
                            Spacer()
                            
                            Text(Circuit(circuitType).overallLevelDescription)
                            .font(.caption)
                            .foregroundColor(Color(UIColor.systemGray))
                        }
                        .foregroundColor(Color(UIColor.label))
                    }
                }
                
                Section {
                    Button(action: {
                        self.areaDataSource.filters.circuit = nil
                        self.dismiss()
                    }) {
                        Text("Montrer toutes les voies")
                    }
                    .foregroundColor(Color(UIColor.label))
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle("Circuit", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("OK") {
                    self.presentationMode.wrappedValue.dismiss()
                }
            )
        }
        // FIXME: use accent color on all views by default (even for modals)
        .accentColor(Color.green)
    }
    
    func dismiss() {
        areaDataSource.refresh()
        presentationMode.wrappedValue.dismiss()
    }
}

struct CircuitFilterView_Previews: PreviewProvider {
    static var previews: some View {
        CircuitFilterView(areaDataSource: DataStore())
    }
}

struct CircuitRectangle: View {
    var color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(color)
            .frame(width: 20, height: 20)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.init(white: 0.8, alpha: 0.6)), lineWidth: 1.0))
    }
}
