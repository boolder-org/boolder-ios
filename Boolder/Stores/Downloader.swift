//
//  Downloader.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 12/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation

class Downloader : ObservableObject {
    @Published var progress: Double = 0
    private let maxRetries: Int
    private let topos: [TopoData]
    private var count: Int = 0
    
    init(maxRetries: Int, topos: [TopoData]) {
        self.maxRetries = maxRetries
        self.topos = topos
    }
    
    func downloadFiles() async {
        await withTaskGroup(of: Void.self) { group in
            for topo in topos {
                try? await Task.sleep(nanoseconds: 100_000_000) // FIXME: remove
                group.addTask {
                    await self.downloadFile(topo: topo, retriesLeft: self.maxRetries)
                }
            }
        }
        progress = 1.0
        print("All downloads completed")
    }
    
    private func downloadFile(topo: TopoData, retriesLeft: Int) async {
        let session = URLSession(configuration: .ephemeral) // TODO: use URLSession.shared in production
        if let (data, response) = try? await session.data(from: topo.url) {
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                save(data: data, for: topo)
                count += 1
                progress = min(1.0, Double(count) / Double(topos.count))
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
