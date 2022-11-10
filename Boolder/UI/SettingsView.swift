//
//  SettingsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 10/01/2021.
//  Copyright © 2021 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var showAlertToRemoveTicksAndFavorites = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Button(action: {
                        showAlertToRemoveTicksAndFavorites = true
                    }) {
                        Text("Remove all ticks and favorites")
                    }
                    .alert(isPresented: $showAlertToRemoveTicksAndFavorites) {
                        Alert(
                            title: Text("Are you sure?"),
                            message: Text("This will delete all favorites and ticks"),
                            primaryButton: .destructive(Text("Delete")) {
                                deleteFavoritesAndTicks()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
        }
        .navigationBarTitle(Text("Settings"), displayMode: .inline)
    }
    
    // BE VERY CAREFUL WHEN CHANGING THIS PIECE OF CODE, IT MAY DELETE DATA IN PRODUCTION
    private func deleteFavoritesAndTicks() {
        #if DEVELOPMENT
        
        // delete all favorites
        let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try managedObjectContext.execute(DelAllReqVar) }
        catch { print(error) }

        // delete all ticks
        let ReqVar2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Tick")
        let DelAllReqVar2 = NSBatchDeleteRequest(fetchRequest: ReqVar2)
        do { try managedObjectContext.execute(DelAllReqVar2) }
        catch { print(error) }
        
        #endif
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
