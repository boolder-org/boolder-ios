//
//  SearchView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 12/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    @Environment(AppState.self) private var appState: AppState
    @Environment(MapState.self) private var mapState: MapState
//    @State private var isEditing = false
    @State private var query = ""
//    @FocusState private var isFocused: Bool

    var body: some View {
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
                                    
                                    appState.tab = .map
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // FIXME
                                        mapState.selectArea(area)
                                        mapState.centerOnArea(area)
                                    }
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
                                    
                                    appState.tab = .map
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // FIXME
                                        mapState.selectAndPresentAndCenterOnProblem(problem)
                                    }
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
        .searchable(text: $query)
    }
    
    private var problems : [Problem] {
        Problem.search(query)
    }
    
    private var areas : [Area] {
        Area.search(query)
    }
    
    func dismiss() {
//        isEditing =  false
//        isFocused = false
//        query = ""
//        
//        UIApplication.shared.dismissKeyboard()
    }
}

//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchView(mapState: MapState.init())
//    }
//}
