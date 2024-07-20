//
//  Topo.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 15/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation
import UIKit

class Topo {
    let id: Int
    let areaId: Int
    var remoteFile: URL?
    
    init(id: Int, areaId: Int, remoteFile: URL? = nil) {
        self.id = id
        self.areaId = areaId
        self.remoteFile = remoteFile
    }
    
    var offlinePhoto: UIImage? {
        UIImage(contentsOfFile: localFile.path)
    }
    
    var offlinePhotoExists: Bool {
        FileManager.default.fileExists(atPath: localFile.path)
    }
    
    private var localFile: URL {
        let documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent("area-\(areaId)").appendingPathComponent("topo-\(id).jpg")
    }
}

// MARK: API calls
extension Topo {
    func getRemoteUrl() async throws {
        let (data, _) = try await URLSession.shared.data(from: apiUrl)
        let decodedResponse = try JSONDecoder().decode(Response.self, from: data)
        
        self.remoteFile = URL(string: decodedResponse.url)
    }
    
    private var apiUrl: URL {
        URL(string: "https://www.boolder.com/api/v1/topos/\(id)")!
    }
    
    private struct Response: Codable {
        var url: String
    }
}
