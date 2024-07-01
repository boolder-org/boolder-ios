//
//  DownloadsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/06/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct DownloadsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let mapState: MapState
    let cluster: Cluster
    
//    private func otherClusters(except: Cluster) -> [Cluster] {
//        Cluster.troisPignons
//        
//        return Array(
//            Set(Cluster.troisPignons).subtracting(Set([except]))
//        )
//    }
    
    var body: some View {
        NavigationView {
            List {
                
                if let area = mapState.selectedArea {
                    
                    
                    
                    
                    ForEach(area.otherAreasOnSameClusterSorted) { a in
                        Button {
                            //
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(a.area.name).foregroundColor(.primary)
                                    //                                                Text("\(Int(a.distance.rounded())) meters").foregroundStyle(.gray).font(.caption)
                                    //                                        Text("\(Int(a.photosSize.rounded())) Mo").foregroundStyle(.gray).font(.caption)
                                }
                                Spacer()
                                Text("\(Int(a.area.photosSize.rounded())) Mo").foregroundStyle(.gray)
                                Image(systemName: "arrow.down.circle").font(.title2)
                                
                            }
                        }
                    }
                    
                }
                
                else if cluster.troisPignons {
                    Section {
                        ForEach(Cluster.troisPignons) { cluster in
                            NavigationLink {
                                List {
                                    Section {
                                        ForEach(cluster.areasSorted) { a in
                                            Button {
                                                //
                                            } label: {
                                                HStack {
                                                    VStack(alignment: .leading) {
                                                        Text(a.name).foregroundColor(.primary)
                                                        //                                        Text("\(Int(a.distance.rounded())) meters").foregroundStyle(.gray).font(.caption)
                                                        //                                        Text("\(Int(a.photosSize.rounded())) Mo").foregroundStyle(.gray).font(.caption)
                                                    }
                                                    Spacer()
                                                    Text("\(Int(a.photosSize.rounded())) Mo").foregroundStyle(.gray)
                                                    Image(systemName: "arrow.down.circle").font(.title2)
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                                .navigationTitle(cluster.name)
                                
                            } label: {
                                HStack {
                                    
                                    VStack(alignment: .leading) {
                                        Text("\(cluster.name)")
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(cluster.areas.count)").foregroundStyle(.gray)
                                    
                                }
                            }
                        }
                    }
                }
                
                else {
                    Section {
                        
                        ForEach(cluster.areasSorted) { a in
                            Button {
                                //
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(a.name).foregroundColor(.primary)
                                        //                                        Text("\(Int(a.distance.rounded())) meters").foregroundStyle(.gray).font(.caption)
                                        //                                        Text("\(Int(a.photosSize.rounded())) Mo").foregroundStyle(.gray).font(.caption)
                                    }
                                    Spacer()
                                    Text("\(Int(a.photosSize.rounded())) Mo").foregroundStyle(.gray)
                                    Image(systemName: "arrow.down.circle").font(.title2)
                                    
                                }
                            }
                        }
                    }
                }
                
            }
            .navigationTitle("Télécharger")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Fermer")
                        .padding(.vertical)
                        .font(.body)
                }
            )
        }
    }
}

//#Preview {
//    DownloadsView()
//}
