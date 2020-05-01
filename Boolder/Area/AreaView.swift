//
//  AreaView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreData

struct AreaView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var presentationMode // required because of a bug with iOS 13: https://stackoverflow.com/questions/58512344/swiftui-navigation-bar-button-not-clickable-after-sheet-has-been-presented
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var showList = false
    @State private var selectedProblem = ProblemAnnotation()
    @State private var presentProblemDetails = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ProblemListView(selectedProblem: $selectedProblem, presentProblemDetails: $presentProblemDetails)
                .zIndex(showList ? 1 : 0)
                
                MapView(selectedProblem: $selectedProblem, presentProblemDetails: $presentProblemDetails)
                    .edgesIgnoringSafeArea(.bottom)
                    .zIndex(showList ? 0 : 1)
                    .sheet(isPresented: $presentProblemDetails) {
                        ProblemDetailsView(problem: self.$selectedProblem)
                            // FIXME: there is a bug with SwiftUI not passing environment correctly to modal views
                            // remove these lines as soon as it's fixed
                            .environmentObject(self.dataStore)
                            .environment(\.managedObjectContext, self.managedObjectContext)
                            .accentColor(Color.green)
                    }
                
                VStack {
                    Spacer()
                    FabFiltersView()
                        .padding(.bottom, 24)
                }
                .zIndex(10)
                
//                NavigationLink(destination: ProblemDetailsView(problem: self.selectedProblem ?? ProblemAnnotation()), isActive: $presentProblemDetails) { EmptyView() }
                
            }
            .navigationBarTitle("Rocher Canon", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(showList ? "Carte" : "Liste") {
                    self.showList.toggle()
                }
            )
        }
        .accentColor(Color.green)
//        .onAppear {
//                // delete all favorites
//                let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
//                let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
//                do { try self.managedObjectContext.execute(DelAllReqVar) }
//                catch { print(error) }
//        }
    }
}

struct AreaView_Previews: PreviewProvider {
    static var previews: some View {
        AreaView()
            .environmentObject(DataStore.shared)
    }
}
