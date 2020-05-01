//
//  StandaloneCircuitFilterView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 01/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct StandaloneCircuitFilterView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: DataStore
    
    @Binding var presentCircuitFilter: Bool
    @Binding var presentFilters: Bool
    
    var body: some View {
        NavigationView {
            CircuitFilterView(presentCircuitFilter: $presentCircuitFilter, presentFilters: $presentFilters)
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

//struct StandaloneCircuitFilterView_Previews: PreviewProvider {
//    static var previews: some View {
//        StandaloneCircuitFilterView()
//    }
//}
