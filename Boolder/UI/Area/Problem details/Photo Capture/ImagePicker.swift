//
//  ImagePicker.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 12/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import UIKit
import SwiftUI
import CoreLocation

struct ImagePicker: UIViewControllerRepresentable {
    
    var sourceType: UIImagePickerController.SourceType = .camera
    var location: CLLocation?
    var problemId: Int
    
    @Binding var selectedImage: UIImage
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // MARK: UIImagePickerControllerDelegate methods
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
                saveImage(image)
                
//                if let data = image.jpegData(compressionQuality: 1.0) {
//                    let filename = getDocumentsDirectory().appendingPathComponent("test.jpg")
//
//                    do {
//                        try data.write(to: filename)
//                        print("image saved")
//                    }
//                    catch {
//                        print(error.localizedDescription)
//                    }
//                }
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        
        // inspired by https://dev.to/nemecek_f/ios-saving-files-into-user-s-icloud-drive-using-filemanager-4kpm
        func saveImage(_ image: UIImage) {
            // create filename
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd-HH.mm.ss"
            let now = Date()
            let dateTime = dateFormatter.string(from: now)
            
            let fileName:String = "your_image_"+dateTime+"_problem_\(parent.problemId)"+".jpg" // name your file the way you want
            var temporaryFolder:URL = getDocumentsDirectory()
            
            // FIXME: do it async
            if let driveURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                temporaryFolder = driveURL
            }
            
            
            let temporaryFileURL:URL = temporaryFolder.appendingPathComponent(fileName)

            // save the image to chosen path
            let jpeg = image.jpegData(compressionQuality: 1.0)! // set JPG quality here (1.0 is best)
            let src = CGImageSourceCreateWithData(jpeg as CFData, nil)!
            let uti = CGImageSourceGetType(src)!
            let cfPath = CFURLCreateWithFileSystemPath(nil, temporaryFileURL.path as CFString, CFURLPathStyle.cfurlposixPathStyle, false)
            let dest = CGImageDestinationCreateWithURL(cfPath!, uti, 1, nil)
            
            if let gpsLocation = parent.location {

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
        
        func getDocumentsDirectory() -> URL {
            // find all possible documents directories for this user
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

            // just send back the first one, which ought to be the only one
            return paths[0]
        }
    }
}
