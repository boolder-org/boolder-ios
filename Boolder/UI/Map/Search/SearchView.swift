//
//  SearchView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 12/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    @Environment(MapState.self) private var mapState: MapState
    @State private var isEditing = false
    @State private var query = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        Group {
            Color.systemBackground
                .edgesIgnoringSafeArea(.vertical)
                .ignoresSafeArea(.keyboard)
                .opacity(isEditing ? 1 : 0)
            
            VStack {
                HStack {
                  TextField("search.placeholder", text: $query)
                  .frame(maxWidth: 400)
                  .padding(10)
                  .padding(.horizontal, 25)
                  .focused($isFocused)
                  .modify {
                      if #available(iOS 26, *) {
                          $0.glassEffect()
                      }
                      else {
                          $0
                              .background(isEditing ? Color(.imageBackground) : Color(.systemBackground))
                              .cornerRadius(12)
                      }
                  }
                  .shadow(color: Color(.secondaryLabel).opacity(isEditing ? 0 : 0.5), radius: 5)
                  .simultaneousGesture(TapGesture().onEnded {
                      mapState.presentProblemDetails = false
                      withAnimation {
                          isEditing = true
                          isFocused = true
                      }
                  })
                  .overlay(
                    HStack {
                      Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(.secondaryLabel))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                        .disabled(true)
                      if isEditing && !query.isEmpty {
                        Button(action: {
                            query = ""
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
                    if query.count == 0 {
                        VStack {
                            VStack(spacing: 16) {
                                Text("search.examples")
                                    .foregroundColor(Color.secondary)

                                ForEach(["Isatis", "La Marie-Rose", "Cul de Chien"], id: \.self) { query in
                                    Button {
                                        self.query = query
                                    } label: {
                                        Text(query).foregroundColor(.appGreen)
                                    }
                                }
                            }
                            .padding(.top, 100)

                            Spacer()
                        }
                    }
                    else if(problems.count == 0 && areas.count == 0) {
                        Spacer()
                        Text("search.no_results").foregroundColor(Color(.secondaryLabel))
                        Spacer()
                    }
                    else {
                        List {
                            if(areas.count > 0) {
                                Section(header: Text("search.areas")) {
                                    ForEach(Area.search(query), id: \.self) { area in
                                        Button {
                                            dismiss()
                                            
                                            mapState.selectArea(area)
                                            mapState.centerOnArea(area)
                                        } label: {
                                            HStack {
                                                Text(area.name).foregroundColor(.primary)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if(problems.count > 0) {
                                Section(header: Text("search.problems")) {
                                    ForEach(Problem.search(query), id: \.self) { problem in
                                        Button {
                                            dismiss()
                                            
                                            mapState.selectAndPresentAndCenterOnProblem(problem)
                                        } label: {
                                            HStack {
                                                ProblemCircleView(problem: problem)
                                                Text(problem.localizedName).foregroundColor(.primary)
                                                Text(problem.grade.string).foregroundColor(Color(.secondaryLabel)).padding(.leading, 2)
                                                Spacer()
                                                Text(Area.load(id: problem.areaId)?.name ?? "").foregroundColor(Color(.secondaryLabel)).font(.caption)
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
                }
                .opacity(isEditing ? 1 : 0)
            }
        }
    }
    
    private var problems : [Problem] {
        Problem.search(query)
    }
    
    private var areas : [Area] {
        Area.search(query)
    }
    
    func dismiss() {
        isEditing =  false
        isFocused = false
        query = ""
        
        UIApplication.shared.dismissKeyboard()
    }
}

//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchView(mapState: MapState.init())
//    }
//}
