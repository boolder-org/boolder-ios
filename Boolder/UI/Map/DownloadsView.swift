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
    
    var body: some View {
        NavigationView {
            List {
                
                if let area = mapState.selectedArea {
                    
                    Section {
                        
                        Button {
                            //
                        } label: {
                            HStack {
                                
                                VStack(alignment: .leading) {
                                    Text(area.name).foregroundColor(.primary)
                                    //                                Text("\(Int(area.photosSize.rounded())) Mo").foregroundStyle(.gray).font(.caption)
                                }
                                
                                
                                Spacer()
                                
                                Text("\(Int(area.photosSize.rounded())) Mo").foregroundStyle(.gray)
                                
                                Image(systemName: "arrow.down.circle").font(.title2)
                                
                            }
                        }
                    }
                    
                    if area.otherAreasOnSameCluster.count > 2 {
                        Section {
                            NavigationLink {
                                List {
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
                                .navigationTitle(area.cluster?.name ?? "Zone")
                            } label: {
                                HStack {
                                    
                                    VStack(alignment: .leading) {
                                        Text("Secteurs voisins")
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(area.otherAreasOnSameCluster.count)").foregroundStyle(.gray)
                                    
                                }
                            }
                            
                        }
                    }
                    else if area.otherAreasOnSameCluster.count > 0 {
                        Section(header: Text("Secteurs voisins")) {
                            ForEach(area.otherAreasOnSameClusterSorted) { a in
                                Button {
                                    //
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(a.area.name).foregroundColor(.primary)
                                            //                                        Text("\(Int(a.distance.rounded())) meters").foregroundStyle(.gray).font(.caption)
                                            //                                        Text("\(Int(a.photosSize.rounded())) Mo").foregroundStyle(.gray).font(.caption)
                                        }
                                        Spacer()
                                        Text("\(Int(a.area.photosSize.rounded())) Mo").foregroundStyle(.gray)
                                        Image(systemName: "arrow.down.circle").font(.title2)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    Text(cluster.name)
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
