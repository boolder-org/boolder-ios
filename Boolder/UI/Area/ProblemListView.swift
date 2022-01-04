//
//  ProblemListView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 25/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ProblemListView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var selectedProblem: Problem
    @Binding var presentProblemDetails: Bool
    @Binding var centerOnProblem: Problem?
    @Binding var centerOnProblemCount: Int
    
    @State private var searchText = ""
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: []) var favorites: FetchedResults<Favorite>
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    var body: some View {
        NavigationView {
        List {
 
            ForEach(groupedProblemsKeys, id: \.self) { (circuitColor: Circuit.CircuitColor) in
                Section(
//                    header: Text(circuitColor.longName())
                    ) {
                        ForEach(groupedProblems[circuitColor]!) { (problem: Problem) in


                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                            
                            centerOnProblem = problem
                            centerOnProblemCount += 1 // triggers a map refresh

//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                selectedProblem = problem
//                                presentProblemDetails = true
//                            }
                        }) {
                            HStack {
                                ProblemCircleView(problem: problem)
                                
                                Text(problem.nameWithFallback())
                                    .foregroundColor(.primary)

                                Spacer()

                                if isFavorite(problem: problem) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Color.yellow)
                                }

                                if isTicked(problem: problem) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color.appGreen)
                                }

                                Text(problem.grade.string)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
//                .headerProminence(.increased)
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Nom de voie"))
        .navigationBarTitle(Text("Voies"), displayMode: .inline)
        .navigationBarItems(
            trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("OK")
                    .bold()
                    .padding(.vertical)
                    .padding(.leading, 32)
            }
        )
        .listStyle(.insetGrouped)
//        .listStyle(GroupedListStyle())
        .animation(.easeInOut(duration: 0))
        }
    }
    
    var groupedProblems : Dictionary<Circuit.CircuitColor, [Problem]> {
        Dictionary(grouping: sortedProblems, by: { (problem: Problem) in
            problem.circuitColor ?? Circuit.CircuitColor.offCircuit
        })
    }
    
    var groupedProblemsKeys : [Circuit.CircuitColor] {
        groupedProblems.keys.sorted()
    }
    
    var sortedProblems : [Problem] {
        if searchText.isEmpty {
            return dataStore.sortedProblems
        } else {
            return (dataStore.sortedProblems).filter { cleanString($0.nameWithFallback()).contains(cleanString(searchText)) }
        }
    }
    
    func cleanString(_ str: String) -> String {
        str.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).alphanumeric
    }


    
    func isFavorite(problem: Problem) -> Bool {
        favorites.contains { (favorite: Favorite) -> Bool in
            return Int(favorite.problemId) == problem.id
        }
    }
    
    func isTicked(problem: Problem) -> Bool {
        ticks.contains { (tick: Tick) -> Bool in
            return Int(tick.problemId) == problem.id
        }
    }
}

extension String {
    var alphanumeric: String {
        return self.components(separatedBy: CharacterSet.alphanumerics.inverted).joined().lowercased()
    }
}


struct ProblemListView_Previews: PreviewProvider {
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static var previews: some View {
        NavigationView {
            ProblemListView(selectedProblem: .constant(Problem()), presentProblemDetails: .constant(false), centerOnProblem: .constant(Problem()), centerOnProblemCount: .constant(1))
                .navigationBarTitle("Rocher Canon", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(DataStore())
        .environment(\.managedObjectContext, context)
    }
}
