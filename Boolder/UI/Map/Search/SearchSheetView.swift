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
    @State private var isSearchFocused = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if query.isEmpty {
                    List {
                        Section(header: Text("search.popular_areas")) {
                            ForEach(Array(Area.popularAreas.prefix(3)), id: \.self) { area in
                                searchAreaRow(area: area)
                            }
                        }
                        
                        Section(header: Text("search.popular_problems")) {
                            ForEach(Problem.popular(limit: 10), id: \.self) { problem in
                                searchProblemRow(problem: problem)
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
                                    searchAreaRow(area: area)
                                }
                            }
                        }
                        
                        if !problems.isEmpty {
                            Section(header: Text("search.problems")) {
                                ForEach(problems, id: \.self) { problem in
                                    searchProblemRow(problem: problem)
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
            .navigationTitle("search.title")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, isPresented: $isSearchFocused, placement: .navigationBarDrawer, prompt: "search.placeholder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if #available(iOS 26, *) {
                        Button(role: .close) {
                            dismiss()
                        }
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isSearchFocused = true
            }
        }
    }
    
    private var problems: [Problem] {
        Problem.search(query)
    }
    
    private var areas: [Area] {
        Area.search(query)
    }
    
    @ViewBuilder
    private func searchAreaRow(area: Area) -> some View {
        Button {
            selectArea(area)
        } label: {
            Text(area.name).foregroundColor(.primary)
        }
    }
    
    @ViewBuilder
    private func searchProblemRow(problem: Problem) -> some View {
        Button {
            selectProblem(problem)
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
    
    private func selectArea(_ area: Area) {
        dismiss()
        mapState.clearFilters()
        mapState.unselectCircuit()
        mapState.selectArea(area)
        mapState.centerOnArea(area)
    }
    
    private func selectProblem(_ problem: Problem) {
        dismiss()
        mapState.clearFilters()
        mapState.unselectCircuit()
        mapState.selectAndPresentAndCenterOnProblem(problem)
    }
}
