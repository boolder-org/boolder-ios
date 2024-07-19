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
    private let maxRetries: Int // TODO: remove
    private let topos: [TopoData]
    private var count: Int = 0
    
    init(maxRetries: Int, topos: [TopoData]) {
        self.maxRetries = maxRetries
        self.topos = topos
        
        // TODO: raise if topos array is empty
    }
    
    func downloadFiles(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) async {
        
        // TODO: refactor
        Array(Set(topos.map{$0.areaId})).forEach { id in
            createFolderInCachesDirectory(folderName: "area-\(id)")
        }
        
        count = 0
        
        let success = await withTaskGroup(of: Bool.self) { group -> Bool in
            
            for topo in topos {
//                try? await Task.sleep(nanoseconds: 100_000_000) // FIXME: remove
                group.addTask { [self] in
                    //                    try Task.checkCancellation()
                    
                    if self.alreadyExists(topo: topo) {
                        print("topo \(topo.id) already exists")
                        self.count += 1
                        progress = min(1.0, Double(self.count) / Double(topos.count))
                        return true
                    }
                    else {
                        return await self.downloadFile(topo: topo)
                    }
                    
                }
            }
            
            var results = [Bool]()
            
            for await success in group {
                results.append(success)
                if !success {
                    group.cancelAll()
                }
            }
            
            print(results)
            
//            try await group.waitForAll()
            
            // FIXME: fail if one fails
            return results.allSatisfy{$0}
        }
        
        print("result = \(success)")
        
        if Task.isCancelled {
            print("cancelled")
        }
        else
        {
            if success {
                onSuccess()
                print("All downloads completed")
            }
            else {
                print("failure")
                // TODO
                onFailure()
            }
        }
    }
    
    private func alreadyExists(topo: TopoData) -> Bool {
        FileManager.default.fileExists(atPath: topo.fileUrl.path)
    }
    
    func downloadFile(topo: TopoData) async -> Bool {
        print("downloading topo \(topo.id)")
        
        createFolderInCachesDirectory(folderName: "area-\(topo.areaId)")
        
        //        try? await Task.sleep(nanoseconds: 1_000_000_000*UInt64(Int.random(in: 0...5))) // FIXME: remove
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        //        config.waitsForConnectivity = false
        let session = URLSession(configuration: config)
        
        if let (localURL, _) = try? await session.download(from: topo.url) {
            save(localURL: localURL, for: topo)
            count += 1
            progress = min(1.0, Double(count) / Double(topos.count))
            return true
        }
        
        return false
        
        
    }
    
    private func save(localURL: URL, for topo: TopoData) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsURL.appendingPathComponent("area-\(topo.areaId)").appendingPathComponent("topo-\(topo.id).jpg")
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            try? fileManager.removeItem(at: destinationURL)
        }
        
        // Move the downloaded file to the destination URL
        try! fileManager.moveItem(at: localURL, to: destinationURL)
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
