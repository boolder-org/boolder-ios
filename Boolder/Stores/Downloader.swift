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
        
        // TODO: raise if topos array is empty
    }
    
    func downloadFiles(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) async {
        
        Array(Set(topos.map{$0.areaId})).forEach { id in
            createFolderInCachesDirectory(folderName: "area-\(id)")
        }
        
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
                        return await self.downloadFile(topo: topo, retriesLeft: self.maxRetries)
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
    
    private func downloadFile(topo: TopoData, retriesLeft: Int) async -> Bool {
        print("downloading topo \(topo.id)")
        
//        try? await Task.sleep(nanoseconds: 1_000_000_000*UInt64(Int.random(in: 0...5))) // FIXME: remove
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
//        config.waitsForConnectivity = false
        let session = URLSession(configuration: config) 
        
        do {
        
            
            let (data, response) = try await session.data(from: topo.url)
            
//            if Int.random(in: 0...30) == 0 {
//                print("BUGG for topo \(topo.id)")
//                try? await Task.sleep(nanoseconds: 3_000_000_000) // FIXME: remove
//                return false
//            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                save(data: data, for: topo)
                count += 1
                progress = min(1.0, Double(count) / Double(topos.count))
                return true
//                print("Downloaded and saved \(topo.url)")
            } else if retriesLeft > 0 {
                print("Retrying \(topo.url), retries left: \(retriesLeft)")
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                return await downloadFile(topo: topo, retriesLeft: retriesLeft - 1)
            } else {
                print("Failed to download \(topo.url) after maximum retries")
            }
        }
        catch {
            // TODO: exception or cancelation
            print(error)
//            print(error.localizedDescription)
        }
        
        return false
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
