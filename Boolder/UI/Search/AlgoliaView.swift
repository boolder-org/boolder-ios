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

struct ProblemItem: Codable, Hashable {
    let objectID: String
    let name: String
    let grade: String
    let area_name: String
}

struct AreaItem: Codable, Hashable {
    let objectID: String
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
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var searchBoxController: SearchBoxObservableController
     @ObservedObject var problemHitsController: HitsObservableController<ProblemItem>
    @ObservedObject var areaHitsController: HitsObservableController<AreaItem>
    @State private var isEditing = false
    
    
    var body: some View {
        VStack(spacing: 7) {
//            SearchBar(text: $searchBoxController.query,
//                      isEditing: $isEditing,
//                      onSubmit: searchBoxController.submit)
            
            List {
                if(areaHitsController.hits.count > 0) {
                    Section(header: Text("Areas")) {
                        ForEach(areaHitsController.hits, id: \.self) { hit in
                            Text(hit?.name ?? "")
                        }
                    }
                }
                if(problemHitsController.hits.count > 0) {
                    Section(header: Text("Problems")) {
                        ForEach(problemHitsController.hits, id: \.self) { hit in
                            if let id = Int(hit?.objectID ?? ""), let problem = Problem.loadProblem(id: id) {
                                HStack {
                                    ProblemCircleView(problem: problem)
                                    Text(hit?.name ?? "")
                                    Text(hit?.grade ?? "").foregroundColor(.gray).padding(.leading, 2)
                                    Spacer()
                                    Text(hit?.area_name ?? "").foregroundColor(.gray).font(.caption)
                                }
                            }
                        }
                    }
                }
//                .headerProminence(.increased)
            }
            .listStyle(.grouped)
            
          }
        .navigationBarTitle(Text("Search"), displayMode: .inline)
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
                  $0.searchable(text: $searchBoxController.query).disableAutocorrection(true)
              }
              else {
                  $0 // FIXME: show a searchbar on iOS 14
              }
          }
        
    }
}

//struct AlgoliaView_Previews: PreviewProvider {
//    static var previews: some View {
//        AlgoliaView()
//    }
//}
