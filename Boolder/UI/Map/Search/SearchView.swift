//
//  SearchView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 12/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var mapState: MapState
    @State private var isEditing = false

    static let algoliaController = AlgoliaController()
    @ObservedObject var searchBoxController = Self.algoliaController.searchBoxController
    @ObservedObject var problemHitsController = Self.algoliaController.problemHitsController
    @ObservedObject var areaHitsController = Self.algoliaController.areaHitsController
    @ObservedObject var errorController = Self.algoliaController.errorController
    
    var body: some View {
        Group {
            Color.systemBackground
                .edgesIgnoringSafeArea(.top)
                .ignoresSafeArea(.keyboard)
                .opacity(isEditing ? 1 : 0)
            
            VStack {
                HStack {
                  TextField("search.placeholder", text: $searchBoxController.query, onCommit: {
                      searchBoxController.submit()
                  })
                  .frame(maxWidth: 400)
                  .padding(10)
                  .padding(.horizontal, 25)
                  .overlay(
                    HStack {
                      Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(.secondaryLabel))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                        .disabled(true)
                      if isEditing && !searchBoxController.query.isEmpty {
                        Button(action: {
                            searchBoxController.query = ""
                               },
                               label: {
                                Image(systemName: "multiply.circle.fill")
                                .foregroundColor(Color(.secondaryLabel))
                                  .padding(.horizontal, 10)
                                  .padding(.vertical, 4)
                               })
                      }
                    }
                  )
                  .onTapGesture {
                      mapState.presentProblemDetails = false
                      withAnimation {
                          isEditing = true
                      }
                  }
                  .background(isEditing ? Color("ImageBackground") : Color(.systemBackground))
                  .cornerRadius(12)
                  .shadow(color: Color(.secondaryLabel).opacity(isEditing ? 0 : 0.5), radius: 5)
                    
                  if isEditing {
                      Button(action: {
                          withAnimation {
                              dismiss()
                          }
                      },
                             label: {
                          Text("search.cancel")
                      })
                      .padding(.horizontal, 4)
                      .transition(.move(edge: .trailing).combined(with: .opacity))
                  }
                }
                .disableAutocorrection(true)
                .padding(.horizontal)
                .padding(.top, 8)
                
                VStack(spacing: 0) {
                    if errorController.requestError {
                        Spacer()
                        Text("search.request_error").foregroundColor(Color(.secondaryLabel))
                        Spacer()
                    }
                    else if searchBoxController.query.count == 0 {
                        VStack {
                            VStack(spacing: 16) {
                                Text("search.examples")
                                    .foregroundColor(Color.secondary)

                                ForEach(["Isatis", "La Marie-Rose", "Cul de Chien"], id: \.self) { query in
                                    Button {
                                        searchBoxController.query = query
                                        searchBoxController.submit()
                                    } label: {
                                        Text(query).foregroundColor(.appGreen)
                                    }
                                }
                            }
                            .padding(.top, 100)

                            Spacer()
                        }
                    }
                    else if(searchTask == nil && areaHitsController.hits.count == 0 && problemHitsController.hits.count == 0) {
                        Spacer()
                        Text("search.no_results").foregroundColor(Color(.secondaryLabel))
                        Spacer()
                    }
                    else {
//                        Results()
                        
                        List {
                            ForEach(Problem.search(searchBoxController.query), id: \.self) { problem in
                                Button {
                                    dismiss()
                                    
                                    mapState.selectAndPresentAndCenterOnProblem(problem)
                                } label: {
                                    HStack {
                                        ProblemCircleView(problem: problem)
                                        Text(problem.localizedName).foregroundColor(.primary)
                                        Text(problem.grade.string).foregroundColor(Color(.secondaryLabel)).padding(.leading, 2)
                                        Spacer()
//                                        Text(problem.area.name).foregroundColor(Color(.secondaryLabel)).font(.caption)
                                    }
                                }
                            }
                        }
                    }
                }
                .opacity(isEditing ? 1 : 0)
            }
        }
        .onChange(of: searchBoxController.query) { newValue in
//            debouncedSearch()
        }
    }
    
    private func Results() -> some View {
        List {
            if(areaHitsController.hits.count > 0) {
                Section(header: Text("search.areas")) {
                    ForEach(areaHitsController.hits, id: \.self) { (hit: AreaItem?) in
                        if let id = Int(hit?.objectID ?? "") {
                            
                            Button {
                                dismiss()
                                
                                if let area = Area.load(id: id) {
                                    mapState.selectArea(area)
                                    mapState.centerOnArea(area)
                                }
                            } label: {
                                HStack {
                                    Text(hit?.name ?? "").foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }
            }
            if(problemHitsController.hits.count > 0) {
                Section(header: Text("search.problems")) {
                    ForEach(problemHitsController.hits, id: \.self) { hit in
                        if let id = Int(hit?.objectID ?? ""), let problem = Problem.load(id: id), let hit = hit {
                            
                            Button {
                                dismiss()
                                
                                mapState.selectAndPresentAndCenterOnProblem(problem)
                            } label: {
                                HStack {
                                    ProblemCircleView(problem: problem)
                                    Text(hit.name).foregroundColor(.primary)
                                    Text(hit.grade).foregroundColor(Color(.secondaryLabel)).padding(.leading, 2)
                                    Spacer()
                                    Text(hit.area_name).foregroundColor(Color(.secondaryLabel)).font(.caption)
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.grouped)
        .gesture(DragGesture()
            .onChanged({ _ in
                UIApplication.shared.dismissKeyboard()
            })
        )
    }
    
    func dismiss() {
        isEditing = false
        searchBoxController.query = ""
        
        UIApplication.shared.dismissKeyboard()
    }
    
    private func debouncedSearch() {
        self.searchTask?.cancel()
        self.searchTask = DispatchWorkItem { searchBoxController.submit(); self.searchTask = nil }
        DispatchQueue.main.asyncAfter(deadline: .now() + self.debounceTimeInterval, execute: self.searchTask!)
    }
    
    let debounceTimeInterval: TimeInterval = 0.3
    @State private var searchTask: DispatchWorkItem?
}

//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchView()
//    }
//}
