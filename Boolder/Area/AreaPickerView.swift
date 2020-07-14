//
//  AreaPickerView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 11/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct AreaPickerView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.dataStore.areas.keys.sorted(), id: \.self) { areaId in
                    Button(action: {
                        self.dataStore.filters = Filters()
                        self.dataStore.areaId = areaId
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text(self.dataStore.areas[areaId]!)
                            
                            Spacer()
                            
                            if self.dataStore.areaId == areaId {
                                Image(systemName: "checkmark").font(Font.body.weight(.bold))
                                    .foregroundColor(Color.green)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("areas", displayMode: .inline)
        }
    }
}

struct AreaPickerView_Previews: PreviewProvider {
    static var previews: some View {
        AreaPickerView()
    }
}
