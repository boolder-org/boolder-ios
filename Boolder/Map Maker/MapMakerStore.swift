//
//  MapMakerStore.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 08/01/2021.
//  Copyright © 2021 Nicolas Mondollot. All rights reserved.
//

import Foundation

class MapMakerStore {
    func save(data: Data, directory: String, filename: String) {
        let fileURL = directoryURL(directory: directory).appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL, options: [.withoutOverwriting])
        }
        catch {
            print(error)
        }
    }
    
    func timestamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd_HH.mm.ss"
        return f.string(from: Date())
    }
    
    private var baseURL: URL {
        FileManager.default.url(forUbiquityContainerIdentifier: nil)! // FIXME: do not force unwrap
            .appendingPathComponent("Documents") // mandatory for icloud drive
    }
    
    private func directoryURL(directory: String) -> URL {
        let url = baseURL.appendingPathComponent("map-maker").appendingPathComponent(directory)

        if !FileManager.default.fileExists(atPath: url.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error);
            }
        }

        return url
    }
}
