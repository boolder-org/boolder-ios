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
//                                Text("\(Int(area.photosSize.rounded())) Mo").foregroundStyle(.gray).font(.caption)
                            }
                            
                            
                            Spacer()
                            
                            Text("\(Int(area.photosSize.rounded())) Mo").foregroundStyle(.gray)
                            
                            Image(systemName: "arrow.down.circle").font(.title2)
                            
                        }
                    }
                }
            
                if area.otherAreasOnSameCluster.count > 0 {
                    Section {
                        NavigationLink {
                            List {
                                ForEach(area.otherAreasOnSameCluster) { a in
                                    Button {
                                        //
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(a.name).foregroundColor(.primary)
                                                //                                        Text("\(Int(a.photosSize.rounded())) Mo").foregroundStyle(.gray).font(.caption)
                                            }
                                            Spacer()
                                            Text("\(Int(a.photosSize.rounded())) Mo").foregroundStyle(.gray)
                                            Image(systemName: "arrow.down.circle").font(.title2)
                                            
                                        }
                                    }
                                }
                            }
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
                
                
            }
            .navigationTitle("Mode hors-connexion")
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
