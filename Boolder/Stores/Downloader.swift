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
        if let (file, response) = try? await session.download(from: topo.remoteFile) {
            guard let response = response as? HTTPURLResponse, let mimeType = response.mimeType else { return .error }
            
            if response.statusCode == 200 && mimeType.hasPrefix("image") {
                save(file, for: topo)
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
    
    private func save(_ file: URL, for topo: Topo) {
        if FileManager.default.fileExists(atPath: topo.onDiskURL.path) {
            try? FileManager.default.removeItem(at: topo.onDiskURL)
        }
        
        createDirectoryForArea(areaId: topo.areaId)
        
        do {
            try FileManager.default.moveItem(at: file, to: topo.onDiskURL)
        }
        catch {
            // TODO: handle error
        }
    }
    
    // TODO: make it DRY with Topo
    func createDirectoryForArea(areaId: Int) {
        let folderName = "area-\(areaId)"
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let newFolderURL = cachesDirectory.appendingPathComponent(folderName)
        
        if !FileManager.default.fileExists(atPath: newFolderURL.path) {
            try? FileManager.default.createDirectory(at: newFolderURL, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
