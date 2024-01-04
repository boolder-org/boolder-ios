//
//  RequestedAreas.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 04/01/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation

class AreaSettings : ObservableObject {
    static let shared = AreaSettings()
    
    // TODO: rename
    @Published var ids: Set<Int> {
        didSet {
            saveToDisk()
        }
    }
    
    private init() {
        ids = Set()
        loadFromDisk()
    }
    
    private func saveToDisk() {
        if let encodedData = try? JSONEncoder().encode(ids) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
    }
    
    private func loadFromDisk() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
            let decodedSet = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            ids = decodedSet
        }
    }
    
    let userDefaultsKey = "offline/requestedAreasIds"
}
