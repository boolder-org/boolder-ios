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
    
    func downloadFiles(onSuccess: @escaping () -> Void, onFailure: @escaping (NSError) -> Void) async {
        
        Array(Set(topos.map{$0.areaId})).forEach { id in
            createFolderInCachesDirectory(folderName: "area-\(id)")
        }
        
        await withThrowingTaskGroup(of: Void.self) { group in
            
            for topo in topos {
                try? await Task.sleep(nanoseconds: 100_000_000) // FIXME: remove
                group.addTask { [self] in
                    //                    try Task.checkCancellation()
                    
                    if self.alreadyExists(topo: topo) {
                        self.count += 1
                        progress = min(1.0, Double(self.count) / Double(topos.count))
                    }
                    else {
                        await self.downloadFile(topo: topo, retriesLeft: self.maxRetries)
                    }
                    
                }
            }
        }
        
        if Task.isCancelled {
            print("canceled")
        }
        else
        {
            onSuccess()
            print("All downloads completed")
        }
    }
    
    private func alreadyExists(topo: TopoData) -> Bool {
        FileManager.default.fileExists(atPath: topo.fileUrl.path)
    }
    
    private func downloadFile(topo: TopoData, retriesLeft: Int) async {
        let session = URLSession(configuration: .ephemeral) // TODO: use URLSession.shared in production
        if let (data, response) = try? await session.data(from: topo.url) {
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                save(data: data, for: topo)
                count += 1
                progress = min(1.0, Double(count) / Double(topos.count))
//                print("Downloaded and saved \(topo.url)")
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
        let fileURL = documentsURL.appendingPathComponent("area-\(topo.areaId)").appendingPathComponent("topo-\(topo.id).jpg")
        
        do {
            try data.write(to: fileURL)
//            print("File saved: \(fileURL)")
        } catch {
            print("Failed to save file \(topo.url): \(error)")
        }
    }
    
    func createFolderInCachesDirectory(folderName: String) {
        // Get the path to the Caches directory
        if let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            
            // Create a URL for the new folder
            let newFolderURL = cachesDirectory.appendingPathComponent(folderName)
            
            // Check if the folder already exists
            if !FileManager.default.fileExists(atPath: newFolderURL.path) {
                do {
                    // Create the folder at the specified URL
                    try FileManager.default.createDirectory(at: newFolderURL, withIntermediateDirectories: true, attributes: nil)
                    print("Folder created at: \(newFolderURL.path)")
                } catch {
                    print("Error creating folder: \(error.localizedDescription)")
                }
            } else {
                print("Folder already exists at: \(newFolderURL.path)")
            }
        } else {
            print("Could not find Caches directory")
        }
    }
}
