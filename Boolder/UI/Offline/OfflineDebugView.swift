//
//  OfflineView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/11/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct OfflineDebugView: View {
//    @State private var offlineAreas = [OfflineManager.OfflineArea]()
    @StateObject private var offlineManager = OfflinePhotosManager.shared
    
    var body: some View {
        NavigationView {
            

            List {
                Button {
                    print(Double(getSizeOfDocumentsFolder()) / 1_000_000)
                    print(Double(getAvailableDiskSpace()) / 1_000_000)
                    print(Double(getTotalDiskSpace()) / 1_000_000)
                } label: {
                    Text("stats")
                }
                
                ForEach(offlineManager.requestedAreas.indices, id: \.self) { index in
                    OfflineAreaRow(offlineArea: offlineManager.requestedAreas[index])
                }
            }
            .navigationTitle(Text("Offline"))
            .onAppear {
//                offlineManager.start()
            }
        }
    }
    
    func getSizeOfDocumentsFolder() -> Int64 {
        let documentsFolderUrl = FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask).first!
        let fileEnumerator = FileManager.default.enumerator(at: documentsFolderUrl, includingPropertiesForKeys: [.fileSizeKey])!
        
        var totalSize: Int64 = 0
        for case let fileURL as NSURL in fileEnumerator {
            var fileSize: AnyObject?
            try? fileURL.getResourceValue(&fileSize, forKey: .fileSizeKey)
            totalSize += fileSize as? Int64 ?? 0
        }
        
        return totalSize
    }
    
    func getAvailableDiskSpace() -> Int64 {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            if let capacity = values.volumeAvailableCapacityForImportantUsage {
                return capacity
            }
        } catch {
            print("Error retrieving disk space: \(error.localizedDescription)")
        }
        return 0
    }

    func getTotalDiskSpace() -> Int64 {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey])
            if let capacity = values.volumeTotalCapacity {
                return Int64(capacity)
            }
        } catch {
            print("Error retrieving total disk space: \(error.localizedDescription)")
        }
        return 0
    }

}

struct OfflineAreaRow: View {
    @ObservedObject var offlineArea: OfflineArea
    
    var body: some View {
        
        HStack {
            Text(offlineArea.area.name)
            Spacer()
            Text("\(packSize) Mo").foregroundColor(.gray)
            
        }
    }
    
    var packSize: Int {
        // TODO: improve estimation
        Int(Double(offlineArea.area.problemsCount)*0.7*150.0/1000.0)
    }
}

#Preview {
    OfflineDebugView()
}
