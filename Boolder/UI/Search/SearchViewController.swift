//
//  SearchViewController.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import Foundation
import InstantSearch
import UIKit

struct Movie: Codable {
    let name: String
}

struct Actor: Codable {
    let name: String
}

// Inspired by https://github.com/algolia/instantsearch-ios/tree/master/Examples/MultiIndex
class SearchViewController: UIViewController {
    
    let searchController: UISearchController
    
    let queryInputConnector: SearchBoxConnector
    let textFieldController: TextFieldController
    
    let searcher: MultiSearcher
    let actorHitsInteractor: HitsInteractor<Hit<Actor>>
    let movieHitsInteractor: HitsInteractor<Hit<Movie>>
    
    let searchResultsController: SearchResultsController
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        searcher = .init(client: .instantSearch)
        searchResultsController = .init()
        actorHitsInteractor = .init(infiniteScrolling: .off)
        movieHitsInteractor = .init(infiniteScrolling: .off)
        searchController = .init(searchResultsController: searchResultsController)
        textFieldController = .init(searchBar: searchController.searchBar)
        queryInputConnector = .init(searcher: searcher,
                                    controller: textFieldController)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(searchController.view)
        
        configureUI()
        
        let actorsSearcher = searcher.addHitsSearcher(indexName: .areas)
        actorHitsInteractor.connectSearcher(actorsSearcher)
        searchResultsController.actorsHitsInteractor = actorHitsInteractor
        
        let moviesSearcher = searcher.addHitsSearcher(indexName: .problems)
        movieHitsInteractor.connectSearcher(moviesSearcher)
        searchResultsController.moviesHitsInteractor = movieHitsInteractor
        
        searcher.search()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
    }
    
    func configureUI() {
        title = "Multi-Index Search"
        view.backgroundColor = .white
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.showsSearchResultsController = true
        searchController.automaticallyShowsCancelButton = false
        navigationItem.searchController = searchController
    }
    
}

