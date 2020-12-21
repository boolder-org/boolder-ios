//
//  GeolocatePhotoView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 21/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct GeolocatePhotoView: View {
    @State private var presentImagePicker = false
    @State private var capturedPhoto = UIImage()
    
    let problemId: Int
    
    @StateObject var locationFetcher = LocationFetcher()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Dev mode")
                .font(.title)
                .fontWeight(.bold)
            
            HStack(alignment: .center) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Problem #\(String(problemId))")
                    Text(locationText)
                }
                .font(.system(size: 14, design: .monospaced))
                
                Spacer()
                
                Button(action: {
                    presentImagePicker = true
                }) {
                    Image(systemName: "camera.circle.fill")
                        .font(.title)
                }
                .fullScreenCover(isPresented: $presentImagePicker) {
                    ImagePicker(sourceType: .camera, location: locationFetcher.location, problemId: problemId, selectedImage: $capturedPhoto)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                        .edgesIgnoringSafeArea(.all)
                }

            }
        }
        .padding(.top, 16)
        .foregroundColor(.gray)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                locationFetcher.start()
            }
        }
    }
    
    var locationText: String {
        if let location = locationFetcher.location {
            return String(format: "%.6f", location.coordinate.latitude) + " " + String(format: "%.6f", location.coordinate.longitude) + " (±" + String(format: "%.0f", location.horizontalAccuracy) + "m)"
        }
        else {
            return "Waiting for gps..."
        }
    }
}

struct GeolocatePhotoView_Previews: PreviewProvider {
    static var previews: some View {
        GeolocatePhotoView(problemId: 1234)
    }
}
