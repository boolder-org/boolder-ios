//
//  TopoStore.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 09/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import Foundation

class TopoStore : ObservableObject {
    var lineCollection = LineCollection(lines: nil)
    
    private var areaId: Int
    
    init(areaId: Int) {
        self.areaId = areaId
        loadData()
    }
    
    private func loadData() {
        if let linejsonUrl = Bundle.main.url(forResource: "area-\(areaId)-topo-lines", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: linejsonUrl)
                lineCollection = try! JSONDecoder().decode(LineCollection.self, from: jsonData)

            } catch {
                print("Error decoding topos json: \(error).")
            }
        }
    }
    
    struct LineCollection: Decodable {
        let lines: [Line]?
        
        func line(withId id: Int) -> Line? {
            return lines?.first(where: { line in
                line.id == id
            })
        }
    }
    
    // MARK: On Demand Resources
    
    var odrRequest: NSBundleResourceRequest?
    private var observer: NSKeyValueObservation?
    @Published var downloadProgress: Double = 0
    
    
    // inspired by https://www.raywenderlich.com/520-on-demand-resources-in-ios-tutorial#c-rate
    func requestResources(onSuccess: @escaping () -> Void, onFailure: @escaping (NSError) -> Void) {
        odrRequest = NSBundleResourceRequest(tags: [areaTag])
        guard let request = odrRequest else { return }
        
        observer = request.progress.observe(\.fractionCompleted, options: .new) { progress, change in
            self.downloadProgress = progress.fractionCompleted
        }
        
        request.beginAccessingResources { (error: Error?) in
            if let error = error {
                onFailure(error as NSError)
                return
            }
            
            onSuccess()
        }
    }
    
    private var areaTag: String {
        "area-\(areaId)"
    }
}
