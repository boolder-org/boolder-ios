//
//  DownloadManager.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 17/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation
import Combine

class DownloadManager {
    private var cancellables = Set<AnyCancellable>()
    private let queue = OperationQueue()
    private let maxRetries = 3
    private let maxConcurrentDownloads = 5
    
    @Published var progress: Double = 0.0
    
    init() {
        queue.maxConcurrentOperationCount = maxConcurrentDownloads
    }
    
    func downloadPhotos(urls: [URL]) {
        let total = urls.count
        var completed = 0
        
        for url in urls {
            let operation = DownloadOperation(url: url, retries: maxRetries)
            operation.progressPublisher
                .sink { _ in }
                receiveValue: { [weak self] success in
                    if success {
                        completed += 1
                        self?.progress = Double(completed) / Double(total)
                    }
                }
                .store(in: &cancellables)
            
            queue.addOperation(operation)
        }
    }
}

class DownloadOperation: Operation {
    private let url: URL
    private let retries: Int
    private var currentRetry = 0
    private var downloadTask: URLSessionDataTask?
    
    let progressPublisher = PassthroughSubject<Bool, Never>()
    
    init(url: URL, retries: Int) {
        self.url = url
        self.retries = retries
    }
    
    override func start() {
        if isCancelled {
            return
        }
        
        download()
    }
    
    private func download() {
        let urlSession = URLSession(configuration: .default)
        downloadTask = urlSession.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Download failed with error: \(error)")
                self.currentRetry += 1
                if self.currentRetry <= self.retries {
                    self.download()
                } else {
                    self.progressPublisher.send(false)
                    self.finish()
                }
                return
            }
            
            if let data = data {
                // Handle the downloaded data (e.g., save to disk)
                print("Downloaded data: \(data)")
                self.progressPublisher.send(true)
                self.finish()
            }
        }
        
        downloadTask?.resume()
    }
    
    private func finish() {
        downloadTask?.cancel()
        downloadTask = nil
        progressPublisher.send(completion: .finished)
    }
}

