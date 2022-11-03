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

struct ProblemItem: Codable {
  let name: String
}

struct AreaItem: Codable {
  let name: String
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

struct AlgoliaView: View {
    @ObservedObject var searchBoxController: SearchBoxObservableController
     @ObservedObject var problemHitsController: HitsObservableController<ProblemItem>
    @ObservedObject var areaHitsController: HitsObservableController<AreaItem>
    @State private var isEditing = false
    
    
    var body: some View {
        VStack(spacing: 7) {
            SearchBar(text: $searchBoxController.query,
                      isEditing: $isEditing,
                      onSubmit: searchBoxController.submit)
            
            HitsList(areaHitsController) { (hit, _) in
              VStack(alignment: .leading, spacing: 10) {
                Text(hit?.name ?? "")
                  .padding(.all, 10)
                Divider()
              }
            } noResults: {
              Text("No Results")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            HitsList(problemHitsController) { (hit, _) in
              VStack(alignment: .leading, spacing: 10) {
                Text(hit?.name ?? "")
                  .padding(.all, 10)
                Divider()
              }
            }
          }
          .navigationBarTitle("Search")
//        .modify {
//              if #available(iOS 15, *) {
//                  $0.searchable(text: $searchBoxController.query)
//              }
//              else {
//                  $0
//              }
//          }
    }
}

//struct AlgoliaView_Previews: PreviewProvider {
//    static var previews: some View {
//        AlgoliaView()
//    }
//}
