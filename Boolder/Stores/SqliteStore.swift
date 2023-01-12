//
//  SqliteStore.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import Foundation
import SQLite

class SqliteStore {
    static let shared = SqliteStore()
    
    let db: Connection
    
    private init() {
        let databaseURL = Bundle.main.url(forResource: "boolder", withExtension: "db")!
        db = try! Connection(databaseURL.path) // TODO: catch errors
    }
}
