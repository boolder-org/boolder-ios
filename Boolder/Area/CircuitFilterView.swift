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
    @EnvironmentObject var dataStore: DataStore
    
    @Binding var presentCircuitFilter: Bool
    
    var body: some View {
        List {
            Section {
                ForEach(circuits, id: \.self) { circuitType in
                    Button(action: {
                        self.dataStore.filters.circuit = circuitType
                        self.presentCircuitFilter = false
                    }) {
                        HStack(alignment: .center) {
                            CircuitRectangle(color: Color(Circuit(circuitType).color))
                            
                            Text("\(Circuit(circuitType).name)")
                            
                            Spacer()
                            
                            Text(Circuit(circuitType).overallLevelDescription)
                            .font(.caption)
                            .foregroundColor(Color(UIColor.systemGray))
                        }
                        .foregroundColor(Color(.label))
                    }
                }
            }
            
            Section {
                Button(action: {
                    self.dataStore.filters.circuit = nil
                    self.presentCircuitFilter = false
                }) {
                    Text("Aucun circuit")
                }
                .foregroundColor(Color(.label))
            }
        }
    }
}

struct CircuitFilterView_Previews: PreviewProvider {
    static var previews: some View {
        CircuitFilterView(presentCircuitFilter: .constant(true))
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
