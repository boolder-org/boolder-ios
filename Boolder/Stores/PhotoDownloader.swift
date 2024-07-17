//
//  PhotoDownloader.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 17/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Combine
import Foundation

class PhotoDownloader {
    @Published var downloadProgress: [URL: Double] = [:]
    @Published private(set) var totalProgress: Double = 0.0
    
    private var cancellables = Set<AnyCancellable>()
    private let maxConcurrentDownloads = 5
    private let maxRetries = 3

    func downloadPhotos(urls: [URL]) {
        let downloadQueue = DispatchQueue(label: "photoDownloadQueue", attributes: .concurrent)
        
        urls.publisher
            .flatMap(maxPublishers: .max(maxConcurrentDownloads)) { url -> AnyPublisher<(URL, Double), Never> in
                self.downloadPhoto(url: url)
                    .retry(self.maxRetries)
                    .map { (url, progress) in (url, progress) }
                    .catch { _ in Just((url, -1.0)) }
                    .eraseToAnyPublisher()
            }
            .receive(on: downloadQueue)
            .sink { [weak self] (url, progress) in
                guard let self = self else { return }
                self.downloadProgress[url] = progress
                self.updateTotalProgress()
            }
            .store(in: &cancellables)
    }
    
    private func downloadPhoto(url: URL) -> AnyPublisher<(URL, Double), Error> {
        Future { promise in
            let task = URLSession.shared.downloadTask(with: url) { location, response, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    print("downloaded")
                    promise(.success((url, 1.0)))
                }
            }
            
            task.resume()
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    private func updateTotalProgress() {
        let completedDownloads = downloadProgress.values.filter { $0 == 1.0 }.count
        let totalDownloads = downloadProgress.count
        totalProgress = totalDownloads > 0 ? Double(completedDownloads) / Double(totalDownloads) : 0.0
    }
}
