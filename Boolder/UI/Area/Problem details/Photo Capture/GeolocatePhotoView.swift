//
//  GeolocatePhotoView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 21/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct LineRecord: Codable {
    var problem_ids: [Int]
}

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
    
    private var baseURL: URL {
        FileManager.default.url(forUbiquityContainerIdentifier: nil)! // FIXME: do not force unwrap
            .appendingPathComponent("Documents")
    }
    
    private var recordSessionsURL: URL {
        let url = baseURL.appendingPathComponent("map-records").appendingPathComponent("topos")

        if !FileManager.default.fileExists(atPath: url.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error);
            }
        }

        return url
    }
    
    fileprivate func save() {
        do {
            let f = DateFormatter()
//            f.timeZone = TimeZone(abbreviation: "UTC")
            f.dateFormat = "yyyy-MM-dd_HH.mm.ss"
            let fileName = f.string(from: Date())
            
            // FIXME: raise if file name already exists
            
            let fileURL = recordSessionsURL.appendingPathComponent(fileName + ".json")
            
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(lineRecord())
            try jsonData.write(to: fileURL, options: [.atomicWrite])
            
            if let photo = capturedPhoto {
                saveImage(photo, fileName: fileName)
            }
            
            mapModeSelectedProblems = []
            recordMode = false
            capturedPhoto = nil
            
            presentationMode.wrappedValue.dismiss()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func lineRecord() -> LineRecord {
        LineRecord(problem_ids: mapModeSelectedProblems.map{$0.id})
    }
    
    // inspired by https://dev.to/nemecek_f/ios-saving-files-into-user-s-icloud-drive-using-filemanager-4kpm
    func saveImage(_ image: UIImage, fileName: String) {
        
        let temporaryFileURL:URL = recordSessionsURL.appendingPathComponent(fileName + ".jpg")

        // save the image to chosen path
        let jpeg = image.jpegData(compressionQuality: 1.0)! // set JPG quality here (1.0 is best)
        let src = CGImageSourceCreateWithData(jpeg as CFData, nil)!
        let uti = CGImageSourceGetType(src)!
        let cfPath = CFURLCreateWithFileSystemPath(nil, temporaryFileURL.path as CFString, CFURLPathStyle.cfurlposixPathStyle, false)
        let dest = CGImageDestinationCreateWithURL(cfPath!, uti, 1, nil)
        
        if let gpsLocation = locationFetcher.location {

        // create GPS metadata from current location
        let gpsMeta = gpsLocation.exifMetadata()
        let tiffProperties = [
            kCGImagePropertyTIFFMake as String: "Camera vendor test",
            kCGImagePropertyTIFFModel as String: "Camera model test"
            // --(insert other properties here if required)--
        ] as CFDictionary

        let properties = [
            kCGImagePropertyTIFFDictionary as String: tiffProperties,
            kCGImagePropertyGPSDictionary: gpsMeta as Any
            // --(insert other dictionaries here if required)--
        ] as CFDictionary

        CGImageDestinationAddImageFromSource(dest!, src, 0, properties)
        if (CGImageDestinationFinalize(dest!)) {
            print("Saved image with metadata!")
        } else {
            print("Error saving image with metadata")
        }
        }
        else {
            print("no location")
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
        GeolocatePhotoView(capturedPhoto: .constant(nil), mapModeSelectedProblems: .constant([]), recordMode: .constant(true))
    }
}
