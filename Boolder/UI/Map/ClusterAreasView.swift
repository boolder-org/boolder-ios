//
//  ClusterAreasView.swift
//  Boolder
//
//  Created by Marcus Kuquert on 2025-02-09.
//  Copyright © 2025 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ClusterAreasView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let cluster: Cluster
    @EnvironmentObject var appState: AppState
    
    @State private var areas = [Area]()
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(areasFilteredBySearch) { area in
                        Button {
                            appState.tab = .map
                            appState.selectedArea = area
                        } label: {
                            HStack {
                                Text(area.name)
                                Spacer()
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    
                }
            }
        }
        .task {
            areas = cluster.areas
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("area.problems.search_prompt")).autocorrectionDisabled()
        .navigationTitle("area.problems")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var areasFilteredBySearch: [Area] {
        if searchText.isEmpty {
            return areas
        } else {
            return areas.filter { ($0.name.normalized).contains(searchText.normalized) }
        }
    }
}
