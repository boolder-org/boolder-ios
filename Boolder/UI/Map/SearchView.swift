//
//  AlgoliaView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 01/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import InstantSearchSwiftUI
import InstantSearch

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var searchBoxController: SearchBoxObservableController
    @ObservedObject var problemHitsController: HitsObservableController<ProblemItem>
    @ObservedObject var areaHitsController: HitsObservableController<AreaItem>
    
    @State private var isEditing = false
    
    let mapState: MapState
    
    var body: some View {
        VStack(spacing: 7) {
            if #available(iOS 15, *) { }
            else {
                SearchBar(text: $searchBoxController.query,
                          isEditing: $isEditing,
                          onSubmit: searchBoxController.submit)
                .disableAutocorrection(true)
                .padding(.horizontal)
                .padding(.top)
            }
            
            if searchBoxController.query.count == 0 {
                //                VStack {
                //                    Text("Recherchez un nom de secteur")
                //                    Text("ou un nom de voie")
                //                }
                //                .foregroundColor(.gray)
                Spacer()
            }
            else if(areaHitsController.hits.count == 0 && problemHitsController.hits.count == 0) {
                Spacer()
                Text("search.no_results").foregroundColor(.gray)
                Spacer()
            }
            else {
                Results()
            }
        }
        .navigationBarTitle(Text("search.title"), displayMode: .inline)
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
        //        .animation(.easeInOut(duration: 0), value: searchBoxController.query)
        .modify {
            if #available(iOS 15, *) {
                $0.searchable(text: $searchBoxController.query, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("search.placeholder"))
                    .disableAutocorrection(true)
            }
            else {
                $0 // FIXME: show a searchbar on iOS 14
            }
        }
    }
    
    private func Results() -> some View {
        List {
            if(areaHitsController.hits.count > 0) {
                Section(header: Text("search.areas")) {
                    ForEach(areaHitsController.hits, id: \.self) { (hit: AreaItem?) in
                        //                            let _ = print(hit)
                        if let id = Int(hit?.objectID ?? "") {
                            
                            Button {
                                presentationMode.wrappedValue.dismiss()
                                
                                mapState.centerOnArea = Area.load(id: id)
                                mapState.centerOnAreaCount += 1
                                
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
                                presentationMode.wrappedValue.dismiss()
                                
                                mapState.centerOnProblem = problem
                                mapState.centerOnProblemCount += 1 // triggers a map refresh
                                
                                var wait = 0.1
                                if #available(iOS 15, *) { }
                                else {
                                    wait = 1.0 // weird bug with iOS 14 https://stackoverflow.com/questions/63293531/swiftui-crash-sheetbridge-abandoned-presentation-detected-when-dismiss-a-she
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
                                    mapState.selectedProblem = problem
                                    mapState.presentProblemDetails = true
                                }
                            } label: {
                                HStack {
                                    ProblemCircleView(problem: problem)
                                    Text(hit.name).foregroundColor(.primary)
                                    Text(hit.grade).foregroundColor(.gray).padding(.leading, 2)
                                    Spacer()
                                    Text(hit.area_name).foregroundColor(.gray).font(.caption)
                                }
                            }
                            
                            
                        }
                    }
                }
            }
            //                .headerProminence(.increased)
        }
        .listStyle(.grouped)
    }
}

struct ProblemItem: Codable, Hashable {
    let objectID: String
    let name: String
    let grade: String
    let area_name: String
}

// TODO: rename to something like AlgoliaArea
struct AreaItem: Codable, Hashable {
    let objectID: String
    let name: String
    let bounds : Bounds
    
    struct Bounds: Codable, Hashable {
        let south_west: AlgoliaPoint
        let north_east: AlgoliaPoint
        
        struct AlgoliaPoint: Codable, Hashable {
            let lat: Double
            let lng: Double
        }
    }
}

class AlgoliaController {
    let searcher: MultiSearcher
    
    let searchBoxInteractor: SearchBoxInteractor
    let searchBoxController: SearchBoxObservableController
    
    let problemHitsInteractor: HitsInteractor<ProblemItem>
    let problemHitsController: HitsObservableController<ProblemItem>
    let areaHitsInteractor: HitsInteractor<AreaItem>
    let areaHitsController: HitsObservableController<AreaItem>
    
    init() {
        self.searcher = MultiSearcher(appID: "XNJHVMTGMF",
                                      apiKey: "765db6917d5c17449984f7c0067ae04c")
        
        
        //      self.searcher.shouldTriggerSearchForQuery = {
        //        return $0.query.query != ""
        //      }
        
        
        
        self.searchBoxInteractor = .init()
        self.searchBoxController = .init()
        
        self.problemHitsInteractor = .init()
        self.problemHitsController = .init()
        self.areaHitsInteractor = .init()
        self.areaHitsController = .init()
        setupConnections()
    }
    
    func setupConnections() {
        searchBoxInteractor.connectSearcher(searcher)
        searchBoxInteractor.connectController(searchBoxController)
        
        let problemHitsSearcher = searcher.addHitsSearcher(indexName: "Problem")
        problemHitsInteractor.connectSearcher(problemHitsSearcher)
        problemHitsInteractor.connectController(problemHitsController)
        
        let areaHitsSearcher = searcher.addHitsSearcher(indexName: "Area")
        areaHitsInteractor.connectSearcher(areaHitsSearcher)
        areaHitsInteractor.connectController(areaHitsController)
    }
}

//struct AlgoliaView_Previews: PreviewProvider {
//    static var previews: some View {
//        AlgoliaView()
//    }
//}
