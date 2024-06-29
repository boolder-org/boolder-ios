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
    
    var body: some View {
        NavigationView {
            List {
                
                Section {
                    
                    if let area = mapState.selectedArea {
                        HStack {
                            Image(systemName: "circle")
                                .font(Font.body.weight(.bold)).frame(width: 20, height: 20).foregroundColor(.appGreen)
                            
                            Text(area.name)
                            
                            Spacer()
                            Text("\(Int(area.photosSize.rounded())) Mo").foregroundStyle(.gray)
                        }
                    }
                    
                    
                    
                    if let cluster = mapState.selectedCluster {
                        
                        HStack {
                            Image(systemName: "circle")
                                .font(Font.body.weight(.bold)).frame(width: 20, height: 20).foregroundColor(.appGreen)
                            
                            VStack(alignment: .leading) {
                                Text("Zone \(cluster.name)")
                                Text("\(cluster.areas.first?.name ?? "") + \(cluster.areas.count-1) secteurs").font(.caption).foregroundStyle(.gray)
                            }
                            
                            
                            Spacer()
                            Text("\(Int(cluster.areas.reduce(0) { $0 + $1.photosSize }.rounded())) Mo").foregroundStyle(.gray)
                        }
                        
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
                                Image(systemName: "circle")
                                    .font(Font.body.weight(.bold)).frame(width: 20, height: 20).foregroundColor(.appGreen)
                                
                                
                                VStack(alignment: .leading) {
                                    Text("Personnalisé")
                                }
                                
                                Spacer()
//                                Text("\(Int(cluster.areas.reduce(0) { $0 + $1.photosSize }.rounded())) Mo").foregroundStyle(.gray)
                            }
                        }
                    }
                    
                }
                    
                Section {
                    
                    HStack {
                        Spacer()
                        Text("Télécharger")
                        Image(systemName: "arrow.down.circle").font(.title2)
                        Spacer()
                    }
                    .foregroundStyle(Color.appGreen)
                    
                }
                
                
            }
            .navigationTitle("Télécharger")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(action: {
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
