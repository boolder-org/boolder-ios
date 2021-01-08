//
//  ProblemRecordView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 08/01/2021.
//  Copyright © 2021 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ProblemRecordView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var selectedSteepness = Steepness.SteepnessType.other
    @State private var selectedLandingDifficulty = Difficulty.easy
    @State private var selectedDescentDifficulty = Difficulty.easy
    @State private var selectedHeight: Double = 0
    @State private var comments = ""
    
    let problem: Problem
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Picker(selection: $selectedSteepness, label: Text("Steepness")) {
                            ForEach(Steepness.SteepnessType.allCases, id: \.self) { value in
                                Text(Steepness(value).name)
                                    .tag(value)
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
                            ForEach(Difficulty.allCases, id: \.self) { value in
                                Text(value.rawValue)
                                    .tag(value)
                            }
                        }
                    }
                    
                    HStack {
                        Picker(selection: $selectedDescentDifficulty, label: Text("Descent")) {
                            ForEach(Difficulty.allCases, id: \.self) { value in
                                Text(value.rawValue)
                                    .tag(value)
                            }
                        }
                    }
                }
                
                Section(header: Text("Comments")) {
                    TextEditor(text: $comments)
                }
            }
            .navigationBarTitle(Text("Edit"), displayMode: .inline)
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
                    Text("OK")
                        .font(.body)
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .padding(.leading)
                }
            )
            .onAppear {
                selectedSteepness = problem.steepness
                
                if let height = problem.height {
                    selectedHeight = Double(height)
                }
            }
        }
    }
    
    func save() {
        let record = ProblemRecord(
            problemId: problem.id,
            steepness: Steepness(selectedSteepness).name,
            height: Int(selectedHeight),
            landingDifficulty: selectedLandingDifficulty.rawValue,
            descentDifficulty: selectedDescentDifficulty.rawValue,
            comments: comments
        )
        let jsonData = try! JSONEncoder().encode(record)
        let filename = store.timestamp() + ".json"
        
        store.save(data: jsonData, directory: "problems", filename: filename)
        
        // TODO: create tick
    }
    
    let store = MapMakerStore()
}

enum Difficulty: String, CaseIterable {
    case easy
    case medium
    case hard
}

struct ProblemRecord: Codable {
    var problemId: Int
    var steepness: String
    var height: Int
    var landingDifficulty: String
    var descentDifficulty: String
    var comments: String
}

struct ProblemRecordView_Previews: PreviewProvider {
    static var previews: some View {
        ProblemRecordView(problem: Problem())
    }
}
