//
//  ImagePicker.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 12/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import UIKit
import SwiftUI
import Photos

struct ImagePicker: UIViewControllerRepresentable {
    
    var sourceType: UIImagePickerController.SourceType = .camera
    
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
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
                
                PHPhotoLibrary.shared().performChanges {
                    let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    
                    let coordinate = CLLocationCoordinate2D(latitude: 48.8841702, longitude: 2.3404837)
                    let location = CLLocation(coordinate: coordinate, altitude: 138, horizontalAccuracy: 10, verticalAccuracy: 0, timestamp: Date())
                    
                    request.location = location
                }
                completionHandler: { success, error in
                    if !success, let error = error {
                        print("error creating asset: \(error)")
                    }
                }
                
//                if let imageURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
//                    print("imageURL")
//                    print(imageURL)
//
//                      let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
//                      if let asset = result.firstObject, let location = asset.location {
//                          let lat = location.coordinate.latitude
//                          let lon = location.coordinate.longitude
//                          print("Here's the lat and lon \(lat) + \(lon)")
//                      }
//                }
                
//                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
