//
//  ODRManager.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 22/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import Foundation

// inspired by https://www.raywenderlich.com/520-on-demand-resources-in-ios-tutorial
class ODRManager : ObservableObject {
        
    var odrRequest: NSBundleResourceRequest?
    private var observer: NSKeyValueObservation?
    @Published var downloadProgress: Double = 0
    
    func requestResources(tag: String, onSuccess: @escaping () -> Void, onFailure: @escaping (NSError) -> Void) {
        odrRequest = NSBundleResourceRequest(tags: [tag])
        guard let request = odrRequest else { return }
        
        observer = request.progress.observe(\.fractionCompleted, options: .new) { progress, change in
            print(progress.fractionCompleted)
//            DispatchQueue.main.async {
                self.downloadProgress = progress.fractionCompleted
//            }
        }
        
        request.beginAccessingResources { (error: Error?) in
            if let error = error {
                onFailure(error as NSError)
                return
            }
            
            onSuccess()
        }
    }
}
