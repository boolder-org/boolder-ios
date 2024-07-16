//
//  RequestedAreas.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 04/01/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation

// TODO: remove?
class DownloadSettings : ObservableObject {
    static let shared = DownloadSettings()
    
    @Published var areaIds: Set<Int> {
        didSet {
            saveToDisk()
        }
    }
    
    private init() {
        areaIds = Set()
        loadFromDisk()
    }
    
    func addArea(areaId: Int) {
        areaIds.insert(areaId)
    }
    
    func removeArea(areaId: Int) {
        areaIds.remove(areaId)
    }
    
    private func saveToDisk() {
        if let encodedData = try? JSONEncoder().encode(areaIds) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
    }
    
    private func loadFromDisk() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
            let decodedSet = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            areaIds = decodedSet
        }
    }
    
    let userDefaultsKey = "offline-photos-v2/areasIds"
}
