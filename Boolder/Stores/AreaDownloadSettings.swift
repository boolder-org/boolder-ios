//
//  RequestedAreas.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 04/01/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation

class AreaDownloadSettings : ObservableObject {
    static let shared = AreaDownloadSettings()
    
    // TODO: rename
    @Published var downloadAreasIds: Set<Int> {
        didSet {
            saveToDisk()
        }
    }
    
    private init() {
        downloadAreasIds = Set()
        loadFromDisk()
    }
    
    func addArea(areaId: Int) {
        downloadAreasIds.insert(areaId)
    }
    
    func removeArea(areaId: Int) {
        downloadAreasIds.remove(areaId)
    }
    
    private func saveToDisk() {
        if let encodedData = try? JSONEncoder().encode(downloadAreasIds) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
    }
    
    private func loadFromDisk() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
            let decodedSet = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            downloadAreasIds = decodedSet
        }
    }
    
    let userDefaultsKey = "offline/requestedAreasIds"
}
