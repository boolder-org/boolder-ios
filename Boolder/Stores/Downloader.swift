//
//  Downloader.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 12/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation



class Downloader {
    private let maxRetries: Int
    
    init(maxRetries: Int) {
        self.maxRetries = maxRetries
    }
    
    func downloadFiles(_ topos: [TopoData]) async {
        await withTaskGroup(of: Void.self) { group in
            for topo in topos {
                group.addTask {
                    await self.downloadFile(topo: topo, retriesLeft: self.maxRetries)
                }
            }
        }
        print("All downloads completed")
    }
    
    private func downloadFile(topo: TopoData, retriesLeft: Int) async {
        if let (data, response) = try? await URLSession.shared.data(from: topo.url) {
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                save(data: data, for: topo)
                print("Downloaded and saved \(topo.url)")
            } else if retriesLeft > 0 {
                print("Retrying \(topo.url), retries left: \(retriesLeft)")
                await downloadFile(topo: topo, retriesLeft: retriesLeft - 1)
            } else {
                print("Failed to download \(topo.url) after maximum retries")
            }
        }
        else {
            // TODO
        }
    }
    
    private func save(data: Data, for topo: TopoData) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("topo-\(topo.id).jpg")
        
        do {
            try data.write(to: fileURL)
            print("File saved: \(fileURL)")
        } catch {
            print("Failed to save file \(topo.url): \(error)")
        }
    }
}
