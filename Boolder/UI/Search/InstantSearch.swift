//
//  InstantSearch.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 03/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import Foundation
import AlgoliaSearchClient

extension SearchClient {
    static let instantSearch = Self(appID: "XNJHVMTGMF", apiKey: "765db6917d5c17449984f7c0067ae04c")
}

extension IndexName {
    static let problems: IndexName = "Problem"
    static let areas: IndexName = "Area"
}
