//
//  SearchSheetView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 26/02/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct SearchSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MapState.self) private var mapState: MapState
    
    @State private var query = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(.secondaryLabel))
                    
                    TextField("search.placeholder", text: $query)
                        .focused($isFocused)
                        .disableAutocorrection(true)
                    
                    if !query.isEmpty {
                        Button {
                            query = ""
                        } label: {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(Color(.secondaryLabel))
                        }
                    }
                }
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                
                if query.isEmpty {
                    VStack(spacing: 16) {
                        Text("search.examples")
                            .foregroundColor(Color.secondary)
                        
                        ForEach(["Isatis", "La Marie-Rose", "Cul de Chien"], id: \.self) { q in
                            Button {
                                query = q
                            } label: {
                                Text(q).foregroundColor(.appGreen)
                            }
                        }
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                }
                else if problems.isEmpty && areas.isEmpty {
                    Spacer()
                    Text("search.no_results").foregroundColor(Color(.secondaryLabel))
                    Spacer()
                }
                else {
                    List {
                        if !areas.isEmpty {
                            Section(header: Text("search.areas")) {
                                ForEach(areas, id: \.self) { area in
                                    Button {
                                        dismiss()
                                        mapState.clearFilters()
                                        mapState.unselectCircuit()
                                        mapState.selectArea(area)
                                        mapState.centerOnArea(area)
                                    } label: {
                                        Text(area.name).foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                        
                        if !problems.isEmpty {
                            Section(header: Text("search.problems")) {
                                ForEach(problems, id: \.self) { problem in
                                    Button {
                                        dismiss()
                                        mapState.clearFilters()
                                        mapState.unselectCircuit()
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
            .navigationTitle("search.placeholder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("search.cancel")
                    }
                }
            }
        }
        .onAppear {
            isFocused = true
        }
    }
    
    private var problems: [Problem] {
        Problem.search(query)
    }
    
    private var areas: [Area] {
        Area.search(query)
    }
}
