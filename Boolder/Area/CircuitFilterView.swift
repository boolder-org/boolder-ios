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
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(circuits, id: \.self) { circuitType in
                        Button(action: {
                            self.dataStore.filters.circuit = circuitType
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(alignment: .center) {
                                CircuitNumberView(number: "", color: Circuit(circuitType).color, height: 20)
                                
                                Text("\(Circuit(circuitType).name)")
                                    .foregroundColor(Color(.label))
                                
                                Spacer()
                                
                                Text(Circuit(circuitType).overallLevelDescription)
                                .font(.caption)
                                .foregroundColor(Color(UIColor.systemGray))
                                
                                if self.dataStore.filters.circuit == circuitType {
                                    Image(systemName: "checkmark").font(Font.body.weight(.bold))
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        self.dataStore.filters.circuit = nil
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text("Pas de circuit")
                                .foregroundColor(Color(.label))
                            
                            Spacer()
                            
                            if self.dataStore.filters.circuit == nil {
                                Image(systemName: "checkmark").font(Font.body.weight(.bold))
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle("Circuit", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("OK").bold()
                }
            )
        }
    }
}

struct CircuitFilterView_Previews: PreviewProvider {
    static var previews: some View {
        CircuitFilterView()
    }
}
