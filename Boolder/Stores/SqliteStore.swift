//
//  SqliteStore.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import Foundation
import SQLite

class SqliteStore : ObservableObject {
    var db: Connection
    
    init() {
        let databaseURL = Bundle.main.url(forResource: "boolder", withExtension: "db")!
        db = try! Connection(databaseURL.path) // FIXME: catch errors
    }
}
