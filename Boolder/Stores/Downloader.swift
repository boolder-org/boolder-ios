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
    private var totalCount: Int = 0
    
    func downloadFiles(topos: [Topo], onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) async {
        
        // TODO: refactor
        Array(Set(topos.map{$0.areaId})).forEach { id in
            createFolderInCachesDirectory(folderName: "area-\(id)")
        }
        
        totalCount = topos.count
        count = 0
        
        let success = await withTaskGroup(of: Bool.self) { group -> Bool in
            
            for topo in topos {
                group.addTask { [self] in
                    if topo.onDiskPhotoExists {
                        self.addCount(toposCount: topos.count)
                        return true
                    }
                    else {
                        let result = await self.downloadFile(topo: topo)
                        
                        // Note: we tolerate "404 not found"
                        // probable reason: the topo has been deleted on the server the user is using an old app version
                        if result == .success || result == .notFound {
                            self.addCount(toposCount: topos.count)
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
            
            return results.allSatisfy{$0}
        }
        
        if Task.isCancelled {
            // TODO: do something?
        }
        else
        {
            if success {
                onSuccess()
            }
            else {
                onFailure()
            }
        }
    }
    
    func downloadFile(topo: Topo) async -> DownloadResult {
        
        // TODO: refactor
        createFolderInCachesDirectory(folderName: "area-\(topo.areaId)")
        
        if let (onDiskURL, response) = try? await session.download(from: topo.remoteFile) {
            guard let response = response as? HTTPURLResponse, let mimeType = response.mimeType else { return .error }
            
            if response.statusCode == 200 && mimeType.hasPrefix("image") {
                save(localURL: onDiskURL, for: topo)
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
    
    private func addCount(toposCount: Int) {
        self.count += 1
        progress = min(1.0, Double(self.count) / Double(toposCount))
    }
    
    private var session: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        return URLSession(configuration: config)
    }
    
    private func save(localURL: URL, for topo: Topo) {
        let fileManager = FileManager.default
        let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let destinationURL = cachesURL.appendingPathComponent("area-\(topo.areaId)").appendingPathComponent("topo-\(topo.id).jpg")
        
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
