//
//  DownloadButtonPlaceholderView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreLocation

struct DownloadButtonPlaceholderView: View {
    @Binding var presentDownloadsPlaceholder: Bool
    
    var body: some View {
        Button {
            presentDownloadsPlaceholder = true
        } label: {
            Image(systemName: "icloud.and.arrow.down")
                .frame(width: 44, height: 44)
        }
//        .buttonStyle(FabButton())
        .sheet(isPresented: $presentDownloadsPlaceholder) {
            placeholderView
                .presentationDetents([.fraction(0.3)])
        }
    }
    
    var placeholderView: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            Text("download.zoom").foregroundColor(.gray).font(.body)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(Color.secondary)
        .padding(.horizontal)
        .background(Color(UIColor.systemGroupedBackground))
        
    }
}
