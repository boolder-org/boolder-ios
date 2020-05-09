//
//  CircuitFilterView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct CircuitFilterView: View {    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: DataStore
    
    @State private var presentCircuitArticle = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(dataStore.geoStore.circuits, id: \.color) { (circuit: Circuit) in
                        Button(action: {
                            self.dataStore.filters.circuit = circuit.color
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(alignment: .center) {
                                CircuitNumberView(number: "", color: circuit.color.uicolor, height: 20)
                                
                                Text("\(circuit.name)")
                                    .foregroundColor(Color(.label))
                                
                                Spacer()
                                
                                if self.dataStore.filters.circuit == circuit.color {
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
            .environmentObject(DataStore())
    }
}
