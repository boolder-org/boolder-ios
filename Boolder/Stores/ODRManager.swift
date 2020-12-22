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
    
    func requestResources(tag: String, onSuccess: @escaping () -> Void, onFailure: @escaping (NSError) -> Void) {
        odrRequest = NSBundleResourceRequest(tags: [tag])
        guard let request = odrRequest else { return }
        
        // track download progress
        cancellable = request.progress.publisher(for: \.fractionCompleted)
            .throttle(for: .seconds(2), scheduler: DispatchQueue.main, latest: true) // without this the navbar buttons freeze (too many renders?), but not sure why
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
}
