//
//  EditProblemView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 08/01/2021.
//  Copyright © 2021 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct EditProblemView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    let problem: Problem
    
    @State var selectedSteepness: Steepness
    @State var selectedHeight: Double
    @State private var selectedLandingDifficulty = Difficulty.easy
    @State private var selectedDescentDifficulty = Difficulty.easy
    @State private var comments = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Picker(selection: $selectedSteepness, label: Text("Steepness")) {
                            ForEach(Steepness.allCases, id: \.self) { steepness in
                                Text(steepness.rawValue)
                                    .tag(steepness)
                            }
                        }
                    }
                    
                    VStack {
                        HStack {
                            Text("Height")
                            Spacer()
                            Text(String(format: "%.0f m", selectedHeight))
                                .foregroundColor(.gray)
                        }
                        Slider(value: $selectedHeight, in: 0...10, step: 1.0)
                    }
                    
                    HStack {
                        Picker(selection: $selectedLandingDifficulty, label: Text("Landing")) {
                            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                Text(difficulty.rawValue)
                                    .tag(difficulty)
                            }
                        }
                    }
                    
                    HStack {
                        Picker(selection: $selectedDescentDifficulty, label: Text("Descent")) {
                            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                Text(difficulty.rawValue)
                                    .tag(difficulty)
                            }
                        }
                    }
                }
                
                Section(header: Text("Comments")) {
                    TextEditor(text: $comments)
                }
            }
            .navigationBarTitle(Text(problem.nameWithFallback()), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .font(.body)
                        .padding(.vertical)
                        .padding(.trailing)
                },
                trailing: Button(action: {
                    save()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .font(.body)
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .padding(.leading)
                }
            )
        }
    }
    
    let store = MapMakerStore()
    
    func save() {
        let record = ProblemJson(
            problemId: problem.id,
            steepness: selectedSteepness.rawValue,
            height: Int(selectedHeight),
            landingDifficulty: selectedLandingDifficulty.rawValue,
            descentDifficulty: selectedDescentDifficulty.rawValue,
            comments: comments
        )
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        
        let jsonData = try! jsonEncoder.encode(record)
        let filename = store.timestamp() + ".json"
        
        store.save(data: jsonData, directory: "problems", filename: filename)
        
        // we piggy-back on the existing tick mechanism to keep track of what's done / what's left to do
        createTick()
    }
    
   // MARK: CoreData
    
    func createTick() {
        let tick = Tick(context: managedObjectContext)
        tick.id = UUID()
        tick.problemId = Int64(problem.id)
        tick.createdAt = Date()
        
        do {
            try managedObjectContext.save()
        } catch {
            // handle the Core Data error
        }
    }
}

enum Difficulty: String, CaseIterable {
    case easy
    case medium
    case hard
}

struct ProblemJson: Codable {
    var problemId: Int
    var steepness: String
    var height: Int
    var landingDifficulty: String
    var descentDifficulty: String
    var comments: String
    // TODO: add version number
}

//struct ProblemRecordView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditProblemView(problem: Problem(), selectedSteepness: Steepness.other, selectedHeight: 0)
//    }
//}
