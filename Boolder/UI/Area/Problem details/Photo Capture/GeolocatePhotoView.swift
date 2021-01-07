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
    @State private var capturedPhoto: UIImage? = nil
    
    @StateObject var locationFetcher = LocationFetcher()
    
    var body: some View {
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
            
            Button(action: {
                save()
                
            }) {
                HStack(alignment: .center, spacing: 16) {
                    Spacer()
                    Text("Save")
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .fixedSize(horizontal: true, vertical: true)
                    Spacer()
                }
                .padding(.horizontal)
            }
            .buttonStyle(BoolderButtonStyle())
            .padding(.vertical, 32)
            
            Spacer()
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                locationFetcher.start()
            }
        }
    }
    
    fileprivate func save() {
        if let driveURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
            do {
                let fileName = "test3"
                
                let fileURL = driveURL.appendingPathComponent(fileName + ".json")
                
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(lineRecord())
                try jsonData.write(to: fileURL, options: [.atomicWrite])
                
                if let photo = capturedPhoto {
                    saveImage(photo, fileName: fileName)
                }
                
                presentationMode.wrappedValue.dismiss()
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func lineRecord() -> LineRecord {
        LineRecord(problem_ids: [48, 32])
    }
    
    // inspired by https://dev.to/nemecek_f/ios-saving-files-into-user-s-icloud-drive-using-filemanager-4kpm
    func saveImage(_ image: UIImage, fileName: String) {

        let temporaryFolder:URL = (FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents"))! // FIXME: do not force unwrap
        
        let temporaryFileURL:URL = temporaryFolder.appendingPathComponent(fileName + ".jpg")

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
        GeolocatePhotoView()
    }
}
