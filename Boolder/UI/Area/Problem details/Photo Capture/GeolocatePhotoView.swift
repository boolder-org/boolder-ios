//
//  GeolocatePhotoView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 21/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct GeolocatePhotoView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var presentImagePicker = false
    @Binding var capturedPhoto: UIImage?
    
    @Binding var mapModeSelectedProblems: [Problem]
    @Binding var recordMode: Bool
    
    @StateObject var locationFetcher = LocationFetcher()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("GPS")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(locationText)
                    .font(.system(size: 14, design: .monospaced))
                
                Text("Photo")
                    .font(.title)
                    .fontWeight(.bold)
                
                Button(action: {
                    presentImagePicker = true
                }) {
                    
                    if let photo = capturedPhoto {
                        Image(uiImage: photo)
                            .resizable()
                            .aspectRatio(4/3, contentMode: .fit)
                    }
                    else {
                        ZStack {
                            Color.init(white: 0.9)
                                .aspectRatio(4/3, contentMode: .fit)
                                .frame(maxWidth: .infinity)
                            
                            Image(systemName: "camera")
                                .font(.system(size: 60))
                                .foregroundColor(Color.gray)
                        }
                        
                    }
                }
                .fullScreenCover(isPresented: $presentImagePicker) {
                    ImagePicker(sourceType: .camera, location: locationFetcher.location, problemId: 0, selectedImage: $capturedPhoto)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                        .edgesIgnoringSafeArea(.all)
                }
                
                Text("Problems")
                    .font(.title)
                    .fontWeight(.bold)
                
                if mapModeSelectedProblems.count > 0 {
                    VStack {
                        HStack {
                            ForEach(mapModeSelectedProblems) { problem in
                                ProblemCircleView(problem: problem)
                            }
                            
                            Spacer()
                        }
                        Button(action : {
                            mapModeSelectedProblems = []
                        }) {
                            HStack {
                                Text("Reset")
                                Spacer()
                            }
                        }
                    }
                }
                else {
                    Button(action : {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text("Choose")
                            Spacer()
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle(Text("New Topo"), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    mapModeSelectedProblems = []
                    recordMode = false
                    capturedPhoto = nil
                    
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .font(.body)
                        .padding(.vertical)
                        .padding(.trailing)
                },
                trailing: Button(action: {
                    save()
                    
                    mapModeSelectedProblems = []
                    recordMode = false
                    capturedPhoto = nil
                    
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("OK")
                        .font(.body)
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .padding(.leading)
                }
            )
            .onAppear {
                recordMode = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    locationFetcher.start()
                }
            }
        }
    }

    let store = MapMakerStore()
    
    fileprivate func save() {
        do {
            let timestamp = store.timestamp()
            
            let topoRecord = TopoRecord(
                latitude: locationFetcher.location?.coordinate.latitude ?? 0,
                longitude: locationFetcher.location?.coordinate.longitude ?? 0,
                horizontalAccuracy: locationFetcher.location?.horizontalAccuracy ?? 0,
                problem_ids: mapModeSelectedProblems.map{$0.id}
            )
            
            store.save(
                data: try JSONEncoder().encode(topoRecord),
                directory: "topos",
                filename: timestamp + ".json"
            )
            
            if let photo = capturedPhoto {
                store.save(
                    data: photo.jpegData(compressionQuality: 1.0)!,
                    directory: "topos",
                    filename: timestamp + ".jpg"
                )
            }
        }
        catch {
            print(error)
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

struct TopoRecord: Codable {
    var latitude: Double
    var longitude: Double
    var horizontalAccuracy: Double
    var problem_ids: [Int]
}

struct GeolocatePhotoView_Previews: PreviewProvider {
    static var previews: some View {
        GeolocatePhotoView(capturedPhoto: .constant(nil), mapModeSelectedProblems: .constant([]), recordMode: .constant(true))
    }
}
