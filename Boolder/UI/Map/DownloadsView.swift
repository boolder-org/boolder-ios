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
                if let cluster = mapState.selectedCluster {
                    ForEach(cluster.areas) { area in
                        HStack {
                            Text(area.name)
                            Spacer()
                            DownloadAreaButtonView(area: area, presentRemoveDownloadSheet: .constant(false), presentCancelDownloadSheet: .constant(false))
                        }
                    }
                }
            }
            .navigationTitle("Téléchargements")
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
