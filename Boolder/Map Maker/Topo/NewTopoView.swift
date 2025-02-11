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
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    @State private var presentImagePicker = false
    @ObservedObject var topoEntry: TopoEntry
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
                        topoEntry.location = locationFetcher.location
                        topoEntry.heading = locationFetcher.heading
                    }) {
                        
                        if let photo = topoEntry.photo {
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
                        
#if targetEnvironment(simulator)
                        ImagePickerView(sourceType: .photoLibrary, selectedImage: $topoEntry.photo)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                            .edgesIgnoringSafeArea(.all)
#else
                        ImagePickerView(sourceType: .camera, selectedImage: $topoEntry.photo)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                            .edgesIgnoringSafeArea(.all)
#endif
                    }
                    
                    Text("Problems")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if topoEntry.problems.count > 0 {
                        VStack {
                            HStack {
                                ForEach(topoEntry.problems) { problem in
                                    ProblemCircleView(problem: problem)
                                }
                                
                                Spacer()
                            }
                            Button(action : {
                                topoEntry.problems = []
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
                    
                    TextEditor(text: $topoEntry.comments)
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
                    topoEntry.reset()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .font(.body)
                        .padding(.vertical)
                        .padding(.trailing)
                },
                trailing: Button(action: {
                    if let photo = topoEntry.photo, let location = topoEntry.location, let heading = topoEntry.heading {
                        save(photo: photo, location: location, heading: heading)
                        topoEntry.reset()
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
            .task {
                UITextView.appearance().backgroundColor = .clear
                topoEntry.pickerModeEnabled = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    locationFetcher.start()
                }
            }
        }
    }
    
    var locationText: String {
        let displayedLocation = topoEntry.location ?? locationFetcher.location
        
        if let displayedLocation = displayedLocation {
            return String(format: "%.6f", displayedLocation.coordinate.latitude) + " " + String(format: "%.6f", displayedLocation.coordinate.longitude) + " (±" + String(format: "%.0f", displayedLocation.horizontalAccuracy) + "m)"
        }
        else {
            return "Waiting..."
        }
    }
    
    var headingText: String {
        let displayedHeading = topoEntry.heading ?? locationFetcher.heading
        
        if let displayedHeading = displayedHeading {
            return String(format: "%.1f", displayedHeading.trueHeading) + "° (±" + String(format: "%.0f", displayedHeading.headingAccuracy) + "°)"
        }
        else {
            return "Waiting..."
        }
    }

    let store = MapMakerStore()
    
    struct TopoJson: Codable {
        var latitude: Double
        var longitude: Double
        var altitude: Double
        var horizontalAccuracy: Double
        var verticalAccuracy: Double
        var heading: Double
        var headingAccuracy: Double
        var problem_ids: [Int]
        var comments: String
        // TODO: add version number
    }
    
    fileprivate func save(photo: UIImage, location: CLLocation, heading: CLHeading) {
        do {
            let timestamp = store.timestamp()
            
            let topoRecord = TopoJson(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                altitude: location.altitude,
                horizontalAccuracy: location.horizontalAccuracy,
                verticalAccuracy: location.verticalAccuracy,
                heading: heading.trueHeading,
                headingAccuracy: heading.headingAccuracy,
                problem_ids: topoEntry.problems.map{$0.id},
                comments: topoEntry.comments
            )
            
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            
            store.save(
                data: try jsonEncoder.encode(topoRecord),
                directory: "topos",
                filename: timestamp + ".json"
            )
            
            store.save(
                data: photo.jpegData(compressionQuality: 1.0)!,
                directory: "topos",
                filename: timestamp + ".jpg"
            )
            
            // we piggy-back on the existing favorite mechanism to keep track of what's done / what's left to do
            for problem in topoEntry.problems {
                createFavorite(problem)
            }
        }
        catch {
            print(error)
        }
    }
    
    // MARK: CoreData
    
    func createFavorite(_ problem: Problem) {
        let favorite = Favorite(context: managedObjectContext)
        favorite.id = UUID()
        favorite.problemId = Int64(problem.id)
        favorite.createdAt = Date()
        
        do {
            try managedObjectContext.save()
        } catch {
            // handle the Core Data error
        }
    }
}

//struct NewTopoView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewTopoView(capturedPhoto: .constant(nil), location: .constant(nil), heading: .constant(nil), comments: .constant(""), mapModeSelectedProblems: .constant([]), recordMode: .constant(true))
//    }
//}
