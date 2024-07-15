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
    
    func downloadFiles(urls: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    await self.downloadFile(url: url, retriesLeft: self.maxRetries)
                }
            }
        }
        print("All downloads completed")
    }
    
    private func downloadFile(url: URL, retriesLeft: Int) async {
        if let (data, response) = try? await URLSession.shared.data(from: url) {
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                save(data: data, for: url)
                print("Downloaded and saved \(url)")
            } else if retriesLeft > 0 {
                print("Retrying \(url), retries left: \(retriesLeft)")
                await downloadFile(url: url, retriesLeft: retriesLeft - 1)
            } else {
                print("Failed to download \(url) after maximum retries")
            }
        }
        else {
            print("Failed to download \(url) after maximum retries")
        }
    }
    
    private func save(data: Data, for url: URL) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("topo-534.jpg")
        
        do {
            try data.write(to: fileURL)
            print("File saved: \(fileURL)")
        } catch {
            print("Failed to save file \(url): \(error)")
        }
    }
}

//// Usage
//let urls: [URL] = [
//    // Add your file URLs here
//]
//
//let downloader = Downloader(maxRetries: 3)
//Task {
//    await downloader.downloadFiles(urls: urls)
//}
