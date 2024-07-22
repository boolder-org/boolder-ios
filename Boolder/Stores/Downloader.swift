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
    private var count: Int = 0
    var totalCount: Int = 0
    
    func downloadFiles(topos: [Topo], onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) async {
        
        // TODO: refactor
        Array(Set(topos.map{$0.areaId})).forEach { id in
            createFolderInCachesDirectory(folderName: "area-\(id)")
        }
        
        totalCount = topos.count
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
                        let result = await self.downloadFile(topo: topo)
                        
                        if result == .success || result == .notFound {
                            // we treat a 404 not found error the same as success because it's probably because the user is using an old app version and the topo has been deleted on the server => we can just ignore it
                            self.count += 1
                            progress = min(1.0, Double(self.count) / Double(topos.count))
                            
                            return true
                        }
                    }
                    
                    return false
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
    
    private func alreadyExists(topo: Topo) -> Bool {
        topo.offlinePhotoExists
    }
    
    func downloadFile(topo: Topo) async -> DownloadResult {
        print("downloading topo \(topo.id)")
        
        createFolderInCachesDirectory(folderName: "area-\(topo.areaId)")
        
        if let (localURL, response) = try? await session.download(from: topo.remoteFile) {
            print(localURL)
            print(response)
            
            guard let response = response as? HTTPURLResponse else { return .error }
            
            if response.statusCode == 200 {
                // TODO: check if file is an image?
                save(localURL: localURL, for: topo)
                return .success
            }
            else if response.statusCode == 404 {
                return .notFound
            }
        }
        
        return .error
    }
    
    enum DownloadResult {
        case success
        case notFound
        case error
    }
    
    private var session: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        return URLSession(configuration: config)
    }
    
    private func save(localURL: URL, for topo: Topo) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsURL.appendingPathComponent("area-\(topo.areaId)").appendingPathComponent("topo-\(topo.id).jpg")
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            try? fileManager.removeItem(at: destinationURL)
        }
        
        // TODO: don't use bang
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
