//
//  AlgoliaController.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 10/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import Foundation
import InstantSearchSwiftUI
import InstantSearch

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
    
    let errorController: AlgoliaErrorController
    
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
        
        self.errorController = AlgoliaErrorController()
        
        setupConnections()
        
        searcher.onError.subscribe(with: self.errorController) { (errorController, error) in
            if let _ = error as? MultiSearcher.RequestError {
                DispatchQueue.main.async {
                    errorController.requestError = true
                }
            }
        }
        
        searcher.onSearch.subscribe(with: self.errorController) { (errorController, error) in
            DispatchQueue.main.async {
                errorController.requestError = false
            }
        }
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
