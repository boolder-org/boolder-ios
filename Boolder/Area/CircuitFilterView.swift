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
    
    @State private var presentCircuitArticle = false
    
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
                leading: Button(action: {
                    self.presentCircuitArticle.toggle()
                }) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 20, weight: .regular))
                        .padding(.vertical)
                }
                .sheet(isPresented: $presentCircuitArticle) {
                    CircuitHelpView()
                        // FIXME: use accent color on all views by default (even for modals)
                        // read this blog post: https://medium.com/swlh/swiftui-and-the-missing-environment-object-1a4bf8913ba7
                        .environmentObject(self.dataStore)
                        .accentColor(Color.green)
                }
                ,
                trailing: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("OK")
                        .bold()
                        .padding(.vertical)
                        .padding(.leading, 32)
                }
            )
        }
    }
}

struct CircuitFilterView_Previews: PreviewProvider {
    static var previews: some View {
        CircuitFilterView()
            .environmentObject(DataStore.shared)
    }
}
