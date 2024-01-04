//
//  ODRManager.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 22/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import Foundation
import Combine

// On Demand Resource (ODR) Manager
// inspired by https://www.raywenderlich.com/520-on-demand-resources-in-ios-tutorial
class ODRManager : ObservableObject {
    var odrRequest: NSBundleResourceRequest?
    var cancellable: Cancellable?
    @Published var downloadProgress: Double = 0
    
    func requestResources(tags: Set<String>, onSuccess: @escaping () -> Void, onFailure: @escaping (NSError) -> Void) {
        odrRequest = NSBundleResourceRequest(tags: tags)
        guard let request = odrRequest else { return }
        
        // track download progress
        cancellable = request.progress.publisher(for: \.fractionCompleted)
            .receive(on: DispatchQueue.main)
            .sink() { fractionCompleted in
                self.downloadProgress = fractionCompleted
            }
        
        // actually request resources
        request.beginAccessingResources { (error: Error?) in
            if let error = error {
                onFailure(error as NSError)
                return
            }
            
            onSuccess()
        }
    }
    
    func checkResources(tags: Set<String>, onSuccess: @escaping (Bool) -> Void) {
        odrRequest = NSBundleResourceRequest(tags: tags)
        guard let request = odrRequest else { return }
        
        request.conditionallyBeginAccessingResources(completionHandler: onSuccess)
    }
    
    func stop() {
        odrRequest?.endAccessingResources()
        cancellable = nil
    }
    
    func cancel() {
        odrRequest?.progress.cancel()
        cancellable = nil
    }
}
