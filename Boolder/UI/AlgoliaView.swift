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

class AlgoliaController {
  
  let searcher: HitsSearcher

  let searchBoxInteractor: SearchBoxInteractor
  let searchBoxController: SearchBoxObservableController

  let hitsInteractor: HitsInteractor<ProblemItem>
  let hitsController: HitsObservableController<ProblemItem>
  
  init() {
    self.searcher = HitsSearcher(appID: "XNJHVMTGMF",
                                 apiKey: "765db6917d5c17449984f7c0067ae04c",
                                 indexName: "Problem")
      self.searcher.shouldTriggerSearchForQuery = {
        return $0.query.query != ""
      }
      
    self.searchBoxInteractor = .init()
    self.searchBoxController = .init()
    self.hitsInteractor = .init()
    self.hitsController = .init()
    setupConnections()
  }
  
  func setupConnections() {
    searchBoxInteractor.connectSearcher(searcher)
    searchBoxInteractor.connectController(searchBoxController)
    hitsInteractor.connectSearcher(searcher)
    hitsInteractor.connectController(hitsController)
  }
      
}

struct AlgoliaView: View {
    @ObservedObject var searchBoxController: SearchBoxObservableController
     @ObservedObject var hitsController: HitsObservableController<ProblemItem>
    @State private var isEditing = false
    
    
    var body: some View {
        VStack(spacing: 7) {
            SearchBar(text: $searchBoxController.query,
                      isEditing: $isEditing,
                      onSubmit: searchBoxController.submit)
            HitsList(hitsController) { (hit, _) in
              VStack(alignment: .leading, spacing: 10) {
                Text(hit?.name ?? "")
                  .padding(.all, 10)
                Divider()
              }
            } noResults: {
              Text("No Results")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
