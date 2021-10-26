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
    
    @Binding var showList: Bool
    
    @State private var searchText: String = ""
    @State private var showCancelButton: Bool = false
    @FocusState private var searchIsFocused: Bool
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: []) var favorites: FetchedResults<Favorite>
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    var body: some View {
        List {
            
            HStack {
                                    Image(systemName: "magnifyingglass")

                                    TextField("Nom de voie", text: $searchText, onEditingChanged: { isEditing in
                                        self.showCancelButton = true
                                    }, onCommit: {
                                        print("onCommit")
                                    })
                                    .focused($searchIsFocused)
                                    .submitLabel(.done)
                                    .foregroundColor(.primary)
                                    .disableAutocorrection(true)

                                    Button(action: {
                                        self.searchText = ""
                                        self.searchIsFocused = false
                                    }) {
                                        Image(systemName: "xmark.circle.fill").opacity(searchText == "" ? 0 : 1)
                                    }
                                }
                                .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                                .foregroundColor(.secondary)
                                .background(Color(.quaternaryLabel))
                                .cornerRadius(10.0)
        
            .listRowBackground(Color.red)
            .listRowSeparator(Visibility.hidden)
            .padding(0)
            
            
            ForEach(groupedProblemsKeys, id: \.self) { (circuitColor: Circuit.CircuitColor) in
                // FIXME: simplify the code by using a tableview footer when/if it becomes possible
                // NB: we want a footer view (or bottom inset?) to be able to show the FabFilters with no background when user scrolls to the bottom of the list
                Section(
                    header: Text(circuitColor.longName()).font(.title2).bold().foregroundColor(.primary).padding(.bottom, 8).textCase(.none),
                    footer: Rectangle().fill(Color.clear).frame(width: 1, height: (circuitColor == dataStore.groupedProblemsKeys.last) ? 120 : 0, alignment: .center)
                    ) {
                        ForEach(groupedProblems[circuitColor]!) { (problem: Problem) in


                        Button(action: {
                            selectedProblem = problem
                            presentProblemDetails = true
                            searchIsFocused = false
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
            }
        }
        .listStyle(GroupedListStyle())
        .animation(.easeInOut(duration: 0))
        .onChange(of: showList) { value in
            searchIsFocused = false
        }
    }
    
//    func searchResults(_ circuitColor: Circuit.CircuitColor) -> [Problem] {
//        if searchText.isEmpty {
//            return dataStore.groupedProblems[circuitColor]!
//        } else {
//            return (dataStore.groupedProblems[circuitColor]!).filter { $0.nameWithFallback().folding(options: .diacriticInsensitive, locale: .current).contains(searchText.folding(options: .diacriticInsensitive, locale: .current)) }
//        }
//    }
    
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
            return (dataStore.sortedProblems).filter { $0.nameWithFallback().folding(options: .diacriticInsensitive, locale: .current).contains(searchText.folding(options: .diacriticInsensitive, locale: .current)) }
        }
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

struct ProblemListView_Previews: PreviewProvider {
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static var previews: some View {
        NavigationView {
            ProblemListView(selectedProblem: .constant(Problem()), presentProblemDetails: .constant(false), showList: .constant(true))
                .navigationBarTitle("Rocher Canon", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(DataStore())
        .environment(\.managedObjectContext, context)
    }
}
