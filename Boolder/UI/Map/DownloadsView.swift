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
    let area: Area
    
    var body: some View {
        NavigationView {
            List {
                
                Section {
                    
                    Button {
                        //
                    } label: {
                        HStack {
                            
                            VStack(alignment: .leading) {
                                Text(area.name).foregroundColor(.primary)
                                Text("\(Int(area.photosSize.rounded())) Mo").foregroundStyle(.gray).font(.caption)
                            }
                            
                            
                            Spacer()
                            
                            Image(systemName: "arrow.down.circle").font(.title2)
                            
                        }
                    }
                    
                }
                
                // FIXME: use area's cluster
                if let cluster = mapState.selectedCluster {
                    
                    Section {
                        NavigationLink {
                            List {
                                ForEach(cluster.areas) { area in
                                    HStack {
                                        Text(area.name)
                                        Spacer()
                                        Text("\(Int(area.photosSize.rounded())) Mo").foregroundStyle(.gray)
                                        //                                        Spacer()
                                        //                                        DownloadAreaButtonView(area: area, presentRemoveDownloadSheet: .constant(false), presentCancelDownloadSheet: .constant(false))
                                    }
                                }
                            }
                        } label: {
                            HStack {
//                                Image(systemName: "circle")
//                                    .font(Font.body.weight(.bold)).frame(width: 20, height: 20)
//                                
//                                
                                VStack(alignment: .leading) {
                                    Text("Secteurs voisins")
                                }
                                
                                Spacer()
                                
                                Text("\(cluster.areas.count)").foregroundStyle(.gray)
                                //                                Text("\(Int(cluster.areas.reduce(0) { $0 + $1.photosSize }.rounded())) Mo").foregroundStyle(.gray)
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
