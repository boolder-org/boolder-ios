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
    
    @ObservedObject var filters: Filters
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(circuits, id: \.self) { circuitType in
                    Button(action: {
                        self.filters.circuit = .orange
                        self.presentationMode.wrappedValue.dismiss()
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
                    Text("Montrer toutes les voies")
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle("Circuit", displayMode: .inline)
        }
    }
}

struct CircuitFilterView_Previews: PreviewProvider {
    static var previews: some View {
        CircuitFilterView(filters: Filters())
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
