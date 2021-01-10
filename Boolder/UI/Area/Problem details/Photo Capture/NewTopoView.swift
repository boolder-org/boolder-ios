//
//  NewTopoView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 21/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import CoreLocation

struct NewTopoView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var presentImagePicker = false
    @Binding var capturedPhoto: UIImage?
    @State private var comments = ""
    
    @Binding var mapModeSelectedProblems: [Problem]
    @Binding var recordMode: Bool
    
    @StateObject var locationFetcher = LocationFetcher()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("GPS")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading) {
                        Text(locationText)
                            .font(.system(size: 14, design: .monospaced))
                        
                        Text(headingText)
                            .font(.system(size: 14, design: .monospaced))
                    }
                    
                    Text("Photo")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Button(action: {
                        presentImagePicker = true
                        locationFetcher.stop()
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
                        ImagePicker(sourceType: .camera, selectedImage: $capturedPhoto)
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
                    
                    Text("Comments")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    TextEditor(text: $comments)
                        .frame(height: 80)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.init(white: 0.9), lineWidth: 1)
                        )
                }
                .padding()
            }
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
                    if let photo = capturedPhoto, let location = locationFetcher.location, let heading = locationFetcher.heading {
                        save(photo: photo, location: location, heading: heading)
                        
                        mapModeSelectedProblems = []
                        recordMode = false
                        capturedPhoto = nil
                        
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Save")
                        .font(.body)
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .padding(.leading)
                }
            )
            .onAppear {
                UITextView.appearance().backgroundColor = .clear
                recordMode = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    locationFetcher.start()
                }
            }
        }
    }
    
    var locationText: String {
        if let location = locationFetcher.location {
            return String(format: "%.6f", location.coordinate.latitude) + " " + String(format: "%.6f", location.coordinate.longitude) + " (±" + String(format: "%.0f", location.horizontalAccuracy) + "m)"
        }
        else {
            return "Waiting..."
        }
    }
    
    var headingText: String {
        if let heading = locationFetcher.heading {
            return String(format: "%.1f", heading.trueHeading) + "° (±" + String(format: "%.0f", heading.headingAccuracy) + ")"
        }
        else {
            return "Waiting..."
        }
    }

    let store = MapMakerStore()
    
    // FIXME: add heading
    struct TopoRecord: Codable {
        var latitude: Double
        var longitude: Double
        var altitude: Double
        var horizontalAccuracy: Double
        var verticalAccuracy: Double
        var heading: Double
        var headingAccuracy: Double
        var problem_ids: [Int]
        var comments: String
    }
    
    fileprivate func save(photo: UIImage, location: CLLocation, heading: CLHeading) {
        do {
            let timestamp = store.timestamp()
            
            let topoRecord = TopoRecord(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                altitude: location.altitude,
                horizontalAccuracy: location.horizontalAccuracy,
                verticalAccuracy: location.verticalAccuracy,
                heading: heading.trueHeading,
                headingAccuracy: heading.headingAccuracy,
                problem_ids: mapModeSelectedProblems.map{$0.id},
                comments: comments
            )
            
            store.save(
                data: try JSONEncoder().encode(topoRecord),
                directory: "topos",
                filename: timestamp + ".json"
            )
            
            store.save(
                data: photo.jpegData(compressionQuality: 1.0)!,
                directory: "topos",
                filename: timestamp + ".jpg"
            )
        }
        catch {
            print(error)
        }
    }
}

struct NewTopoView_Previews: PreviewProvider {
    static var previews: some View {
        NewTopoView(capturedPhoto: .constant(nil), mapModeSelectedProblems: .constant([]), recordMode: .constant(true))
    }
}
